import 'package:flutter/material.dart';
import '../models/in_app_message_payload.dart';
import '../ui_components/in_app_message_dialog.dart';

class InAppMessagingService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void initialize() {
    // Kept as a local extension point for screens that use the navigator key.
  }

  /// Helper to manually trigger an in-app message (for testing or internal events)
  static void showMessage(InAppMessagePayload payload) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        InAppMessageDialog.show(context, payload);
      }
    });
  }
}
