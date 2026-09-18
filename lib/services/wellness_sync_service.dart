import 'package:flutter/foundation.dart';

import '../controllers/wellness_database_controller.dart';
import 'auth_session_controller.dart';

enum WellnessSyncStatus { idle, syncing, success, error }

/// Local-only wellness persistence facade.
class WellnessSyncService {
  WellnessSyncService({
    WellnessDatabaseController? database,
  }) : _database = database ?? WellnessDatabaseController.instance;

  WellnessSyncService.local({
    WellnessDatabaseController? database,
  }) : _database = database ?? WellnessDatabaseController.instance;

  final WellnessDatabaseController _database;

  final ValueNotifier<WellnessSyncStatus> status =
      ValueNotifier<WellnessSyncStatus>(WellnessSyncStatus.idle);
  final ValueNotifier<DateTime?> lastSynced = ValueNotifier<DateTime?>(null);

  LocalUser? get currentUser => null;
  bool get canSync => false;
  String? get currentUid => null;

  Future<bool> syncNow() async => false;

  Future<void> deleteRemoteAccountData(String uid) async {}
}