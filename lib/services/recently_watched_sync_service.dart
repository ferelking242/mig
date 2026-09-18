import 'dart:async';

import 'package:flutter/foundation.dart';

import '../controllers/recently_watched_database_controller.dart';

enum RecentSyncStatus { idle, syncing, success, error }

Set<int> resolveCloudWinners({
  required Map<int, int> cloudVersions,
  required Map<int, int> localVersions,
  Set<int> cloudDeleted = const <int>{},
}) {
  final winners = <int>{};
  for (final entry in cloudVersions.entries) {
    final localVersion = localVersions[entry.key];
    if (localVersion == null) {
      if (!cloudDeleted.contains(entry.key)) winners.add(entry.key);
      continue;
    }
    if (entry.value > localVersion) winners.add(entry.key);
  }
  return winners;
}

/// Local-only replacement for the cloud progress synchronizer.
class RecentlyWatchedSyncService {
  RecentlyWatchedSyncService._internal();

  static final RecentlyWatchedSyncService instance =
      RecentlyWatchedSyncService._internal();

  final ValueNotifier<RecentSyncStatus> statusNotifier =
      ValueNotifier<RecentSyncStatus>(RecentSyncStatus.idle);
  final ValueNotifier<DateTime?> lastSyncedNotifier =
      ValueNotifier<DateTime?>(null);

  Timer? _pushTimer;
  final RecentlyWatchedMoviesController _movieDb =
      RecentlyWatchedMoviesController();
  final RecentlyWatchedEpisodeController _episodeDb =
      RecentlyWatchedEpisodeController();

  bool get canSync => false;

  Future<void> init() async {}

  Future<void> autoSyncIfSignedIn() async {}

  void onRecentChanged() {
    _pushTimer?.cancel();
  }

  Future<void> flushPending() async {
    _pushTimer?.cancel();
    _pushTimer = null;
  }

  Future<bool> pushPendingNow() async => false;

  Future<bool> syncNow({bool force = false}) async => false;

  Future<void> deleteAccountData(String uid) async {
    await _movieDb.clear();
    await _episodeDb.clear();
    statusNotifier.value = RecentSyncStatus.idle;
    statusNotifier.value = RecentSyncStatus.success;
  }

  Future<void> deleteRemoteAccountData(String uid) async {}

  @visibleForTesting
  void dispose() {
    _pushTimer?.cancel();
    _pushTimer = null;
  }
}