import 'package:flutter/material.dart';

class CardListTile extends StatelessWidget {
  const CardListTile({
    super.key,
    this.color,
    this.selected = false,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Color? color;
  final bool selected;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: ListTile(
        selected: selected,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
