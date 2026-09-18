import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_session_controller.dart';

enum SyncStatus { idle, syncing, success, error }

/// Keeps the existing bookmark-sync API available while this build is local.
///
/// Bookmarks continue to use the local database and the same screens. Cloud
/// synchronization is disabled so no cloud service is required at startup.
class BookmarkSyncService {
  BookmarkSyncService._internal();

  static final BookmarkSyncService instance = BookmarkSyncService._internal();

  final ValueNotifier<SyncStatus> statusNotifier =
      ValueNotifier<SyncStatus>(SyncStatus.idle);
  final ValueNotifier<DateTime?> lastSyncedNotifier =
      ValueNotifier<DateTime?>(null);

  static const String _lastSyncedKey = 'flixquest_last_bookmark_sync';

  LocalUser? get currentUser => null;
  bool get canSync => false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastSyncedKey);
    if (millis != null) {
      lastSyncedNotifier.value = DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }

  Future<bool> checkIfDocExists(String uid) async => false;

  Future<void> autoSyncIfSignedIn() async {}

  Future<void> onBookmarkChanged() async {}

  Future<bool> syncNow({bool force = false}) async {
    debugPrint('Bookmark cloud sync is disabled in local visual mode.');
    return false;
  }

  Future<bool> pushLocalToCloud() async => false;

  Future<bool> pullCloudToLocal() async => false;

  Future<bool> deleteMovieFromCloud(int movieId) async => false;

  Future<bool> deleteTVFromCloud(int tvId) async => false;
}