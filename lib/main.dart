import 'package:flutter/material.dart';

void main() {
  runApp(const MigScreensApp());
}

class MigScreensApp extends StatelessWidget {
  const MigScreensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Figtree',
        useMaterial3: true,
      ),
      home: const FlixQuestScreens(),
    );
  }
}

class FlixQuestScreens extends StatefulWidget {
  const FlixQuestScreens({super.key});

  @override
  State<FlixQuestScreens> createState() => _FlixQuestScreensState();
}

class _FlixQuestScreensState extends State<FlixQuestScreens> {
  static const _screenAssets = <String>[
    'assets/screens/movies-home.jpg',
    'assets/screens/series-detail.jpg',
    'assets/screens/episodes.jpg',
    'assets/screens/movie-detail.jpg',
    'assets/screens/season-detail.jpg',
    'assets/screens/episode-detail.jpg',
    'assets/screens/live-tv.jpg',
    'assets/screens/downloads.jpg',
    'assets/screens/player.jpg',
  ];

  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _screenAssets.length,
        itemBuilder: (context, index) {
          return SizedBox.expand(
            child: Image.asset(
              _screenAssets[index],
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Screen unavailable',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}