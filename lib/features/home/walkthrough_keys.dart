import 'package:flutter/material.dart';

/// Shared GlobalKeys used by the guided walkthrough to locate real widgets
/// on-screen so the spotlight can highlight them.
class WalkthroughKeys {
  WalkthroughKeys._();
  static final blockRow = GlobalKey();
  static final addSubjectBtn = GlobalKey();
}
