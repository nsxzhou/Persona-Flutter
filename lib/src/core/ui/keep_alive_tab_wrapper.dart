import 'package:flutter/material.dart';

/// Wraps a [child] widget so that [AutomaticKeepAliveClientMixin] keeps it
/// alive inside a [TabBarView] or [PageView].
class KeepAliveTabWrapper extends StatefulWidget {
  const KeepAliveTabWrapper({required this.child, super.key});
  final Widget child;

  @override
  State<KeepAliveTabWrapper> createState() => _KeepAliveTabWrapperState();
}

class _KeepAliveTabWrapperState extends State<KeepAliveTabWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
