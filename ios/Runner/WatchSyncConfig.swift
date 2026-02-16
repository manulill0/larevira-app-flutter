import Foundation

struct WatchSyncConfig {
  let baseURL: URL
  let citySlug: String
  let editionYear: Int
  let mode: String

  static let `default` = WatchSyncConfig(
    baseURL: URL(string: "http://192.168.1.89:8001/api/v1")!,
    citySlug: "sevilla",
    editionYear: 2026,
    mode: "all"
  )
}
