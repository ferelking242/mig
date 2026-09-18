import 'dart:convert';

import '../models/banner_ad.dart';

class AppRemoteConfig {
  const AppRemoteConfig._();

  static const occasionalThemeKey = 'occasional_theme';
  static const appLogoKey = 'app_logo_url';
  static const legacyAppLogoKey = 'cinemax_logo';
  static const flixquestApiInstancesKey = 'flixquest_api_instances';
  static const flixquestApiUrlKey = 'flixquest_api_url_v2';
  static const tmdbApiKey = 'tmdb_api_key';
  static const enableWatchNowKey = 'enable_stream';
  static const enableDownloadKey = 'enable_download';
  static const enableLiveTvKey = 'enable_live_tv';
  static const bannersKey = 'banners';
  static const bannerAdNetworkKey = 'banner_ad_network';
  static const unityGameIdAndroidKey = 'unity_game_id_android';
  static const unityBannerPlacementIdKey = 'unity_banner_placement_id';
  static const unityTestModeKey = 'unity_test_mode';

  /// Live TV used to ride on the OTT flag before it got a dedicated key.
  static const legacyEnableLiveTvKey = 'enable_ott';

  static List<String> parseApiInstances(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic> && decoded['instances'] is List) {
        return (decoded['instances'] as List)
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
      } else if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // Malformed JSON falls back gracefully.
    }
    return const [];
  }

  static Map<String, BannerDisplayConfig> parseBannerConfigs(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) return const {};
    try {
      final decoded = jsonDecode(trimmed);
      final rawBanners =
          decoded is Map<String, dynamic> ? decoded['banners'] : decoded;
      final configs = <String, BannerDisplayConfig>{};
      if (rawBanners is List) {
        for (final item in rawBanners.whereType<Map>()) {
          for (final entry in item.entries) {
            if (entry.value is Map) {
              configs[entry.key.toString()] = BannerDisplayConfig.fromJson(
                entry.key.toString(),
                Map<String, dynamic>.from(entry.value as Map),
              );
            }
          }
        }
      } else if (rawBanners is Map) {
        for (final entry in rawBanners.entries) {
          if (entry.value is Map) {
            configs[entry.key.toString()] = BannerDisplayConfig.fromJson(
              entry.key.toString(),
              Map<String, dynamic>.from(entry.value as Map),
            );
          }
        }
      }
      return configs;
    } catch (_) {
      return const {};
    }
  }

}
