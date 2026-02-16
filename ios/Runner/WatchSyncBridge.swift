import Foundation
import WatchConnectivity

final class WatchSyncBridge: NSObject {
  private let config: WatchSyncConfig

  init(config: WatchSyncConfig = .default) {
    self.config = config
    super.init()
  }

  func start() {
    guard WCSession.isSupported() else { return }

    let session = WCSession.default
    session.delegate = self
    session.activate()

    Task {
      await pushSnapshotIfPossible()
    }
  }

  @MainActor
  func pushSnapshotIfPossible() async {
    guard WCSession.isSupported() else { return }
    guard WCSession.default.activationState == .activated else { return }

    do {
      let snapshot = try await buildSnapshotPayload()
      try WCSession.default.updateApplicationContext(snapshot)
    } catch {
      // Non-fatal: the watch can still load data directly from API.
    }
  }

  private func buildSnapshotPayload() async throws -> [String: Any] {
    let days = try await fetchDays()

    let encodedDays: [[String: Any]] = days.map { day in
      [
        "slug": day.slug,
        "name": day.name,
        "startsAt": day.startsAt?.toISO8601String() as Any,
        "processionEventsCount": day.processionEventsCount,
      ]
    }

    return [
      "citySlug": config.citySlug,
      "editionYear": config.editionYear,
      "mode": config.mode,
      "syncedAt": Date().toISO8601String(),
      "days": encodedDays,
    ]
  }

  private func fetchDays() async throws -> [WatchDayPayload] {
    var components = URLComponents(
      url: config.baseURL.appendingPathComponent("\(config.citySlug)/\(config.editionYear)/days"),
      resolvingAgainstBaseURL: false
    )
    components?.queryItems = [URLQueryItem(name: "mode", value: config.mode)]

    guard let url = components?.url else {
      throw URLError(.badURL)
    }

    let (data, response) = try await URLSession.shared.data(from: url)
    guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)

      if let date = ISO8601DateFormatter.withFractional.date(from: rawValue) {
        return date
      }
      if let date = ISO8601DateFormatter.standard.date(from: rawValue) {
        return date
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid date format: \(rawValue)"
      )
    }

    let envelope = try decoder.decode(WatchDaysEnvelope.self, from: data)
    return envelope.data
  }
}

extension WatchSyncBridge: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    guard activationState == .activated else { return }

    Task {
      await pushSnapshotIfPossible()
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    guard (message["type"] as? String) == "requestSnapshot" else { return }

    Task {
      await pushSnapshotIfPossible()
    }
  }
}

private struct WatchDaysEnvelope: Decodable {
  let data: [WatchDayPayload]
}

private struct WatchDayPayload: Decodable {
  let slug: String
  let name: String
  let startsAt: Date?
  let processionEventsCount: Int

  private enum CodingKeys: String, CodingKey {
    case slug
    case name
    case startsAt = "starts_at"
    case processionEventsCount = "procession_events_count"
  }
}

private extension Date {
  func toISO8601String() -> String {
    ISO8601DateFormatter.withFractional.string(from: self)
  }
}

private extension ISO8601DateFormatter {
  static let withFractional: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  static let standard: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
}
