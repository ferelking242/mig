import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import 'package:flixquest/flixquest_main.dart';
import '../models/translation.dart';
import '../provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:media_kit/media_kit.dart';
import 'constants/app_constants.dart';
import 'functions/function.dart';
import 'provider/bookmark_provider.dart';
import 'provider/recently_watched_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'provider/settings_provider.dart';
import 'provider/wellness_provider.dart';
import 'services/bookmark_sync_service.dart';
import 'services/recently_watched_sync_service.dart';
import 'services/media_link_navigation_service.dart';
import 'services/home_widget_navigation_service.dart';
import 'singleton/sharedpreferences_singleton.dart';
import 'tv/platform/device_presentation.dart';
import 'tv/platform/device_presentation_detector.dart';

bool isTablet(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double threshold = 1000.0;
  return screenWidth > threshold;
}

SettingsProvider settingsProvider = SettingsProvider();
RecentProvider recentProvider = RecentProvider();
BookmarkProvider bookmarkProvider = BookmarkProvider();
AppDependencyProvider appDependencyProvider = AppDependencyProvider();
WellnessProvider wellnessProvider = WellnessProvider.instance;
bool _isRecoverableImageError(FlutterErrorDetails details) {
  final context = details.context?.toString() ?? '';
  final stack = details.stack?.toString() ?? '';

  // cached_network_image reports failed downloads and evicted cache files
  // through Flutter's image error channel. These are expected per-image
  // failures and widgets already provide their own fallback content.
  return context.contains('resolving an image codec') ||
      context.contains('loading an image') ||
      stack.contains('MultiImageStreamCompleter');
}

Future<DevicePresentation> appInitialize({
  DevicePresentationDetector? devicePresentationDetector,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Let Flutter paint behind Android's transparent gesture-navigation area.
  // Individual surfaces remain responsible for applying SafeArea padding to
  // interactive content.
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } catch (error) {
    debugPrint('Unable to configure edge-to-edge mode: $error');
  }

  // Surface uncaught Dart and platform errors without requiring a cloud
  // service. The visual app remains usable in fully local/offline mode.
  FlutterError.onError = (details) {
    if (_isRecoverableImageError(details)) return;
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    debugPrint('Unhandled platform error: $error');
    debugPrintStack(stackTrace: stackTrace);
    return true;
  };

  final devicePresentation = await resolveDevicePresentation(
    detector: devicePresentationDetector,
  );

  // Initialize MediaKit for video playback with multiple codec support
  // MediaKit.ensureInitialized();

  // Reset orientation to all orientations on app start
  // This is CRITICAL for handling ungraceful app termination (force-close, system kill)
  // When the app is killed while streaming in landscape mode, this ensures
  // orientation is reset on next app launch since dispose() never gets called
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ByteData data =
  //     await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  // SecurityContext.defaultContext
  //     .setTrustedCertificatesBytes(data.buffer.asUint8List());
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('Optional .env file is unavailable: $error');
  }
  await EasyLocalization.ensureInitialized();
  sharedPrefsSingleton = await SharedPreferencesSingleton.getInstance();
  await clearVideoPlaybackCache();
  try {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  } catch (error) {
    debugPrint('Flutter downloader is unavailable: $error');
  }

  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.getCurrentMaterial3Mode();
  await settingsProvider.initMixpanel();
  await settingsProvider.getCurrentAdultMode();
  await settingsProvider.getCurrentDefaultScreen();
  await settingsProvider.getCurrentImageQuality();
  await settingsProvider.getCurrentWatchCountry();
  await settingsProvider.getCurrentViewType();
  await settingsProvider.getSeekDuration();
  await settingsProvider.getMaxBufferDuration();
  await settingsProvider.getVideoResolution();
  await settingsProvider.getSubtitleLanguage();
  await settingsProvider.getSubtitleMode();
  await settingsProvider.getViewMode();
  await settingsProvider.getSubtitleSize();
  await settingsProvider.getForegroundSubtitleColor();
  await settingsProvider.getBackgroundSubtitleColor();
  await settingsProvider.getAppLanguage();
  await settingsProvider.getAppColorIndex();
  await settingsProvider.getCustomAppColor();
  await settingsProvider.getStreamProviderOrder();
  await settingsProvider.getPlayerTimeStyle();
  await settingsProvider.getUseProxyMode();
  await settingsProvider.getSubtitleStyle();
  await settingsProvider.getEnableNextEpisodeButton();
  await settingsProvider.getIntroDbSettings();
  await settingsProvider.getPlayerAmbientGlowEnabled();
  await settingsProvider.getAutoLoadSources();
  settingsProvider.completeHydration();
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await bookmarkProvider.fetchBookmarks();
  await wellnessProvider.initialize();
  await appDependencyProvider.getFlixQuestLogo();
  await appDependencyProvider.getOccasionalTheme();
  await appDependencyProvider.getAmbientMode();
  await appDependencyProvider.getFQUrl();
  await appDependencyProvider.getTmdbProxy();
  await appDependencyProvider.getUpdateConfiguration();

  await BookmarkSyncService.instance.init();
  await RecentlyWatchedSyncService.instance.init();

  return devicePresentation;
}

Future<DevicePresentation> _initializeApp() async {
  final devicePresentation = await appInitialize();
  HttpOverrides.global = MyHttpOverrides();
  HomeWidgetNavigationService.configure(
    source: () => (
      language: settingsProvider.appLanguage,
      useProxy: settingsProvider.enableProxy,
      proxy: appDependencyProvider.tmdbProxy,
    ),
  );
  await MediaLinkNavigationService.initialize();
  return devicePresentation;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _StartupApp());
}

class _StartupApp extends StatefulWidget {
  const _StartupApp();

  @override
  State<_StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<_StartupApp> {
  late Future<DevicePresentation> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  void _retry() {
    setState(() {
      _initialization = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DevicePresentation>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _StartupFailure(
            error: snapshot.error,
            onRetry: _retry,
          );
        }

        return EasyLocalization(
          supportedLocales: Translation.all,
          path: 'assets/translations',
          fallbackLocale: Translation.all[0],
          startLocale: Locale(settingsProvider.appLanguage),
          child: FlixQuest(
            settingsProvider: settingsProvider,
            recentProvider: recentProvider,
            bookmarkProvider: bookmarkProvider,
            appDependencyProvider: appDependencyProvider,
            devicePresentation: snapshot.data!,
          ),
        );
      },
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF161716),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}

class _StartupFailure extends StatelessWidget {
  const _StartupFailure({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF161716),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FlixQuest could not start',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
