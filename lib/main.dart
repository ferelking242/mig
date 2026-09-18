import 'package:flutter/material.dart';

void main() {
  runApp(const MigScreensApp());
}

class MigScreensApp extends StatelessWidget {
  const MigScreensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIG Screens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB6E600),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Figtree',
        useMaterial3: true,
      ),
      home: const ScreenGallery(),
    );
  }
}

class _ScreenItem {
  const _ScreenItem({
    required this.title,
    required this.asset,
    this.landscape = false,
  });

  final String title;
  final String asset;
  final bool landscape;
}

class ScreenGallery extends StatefulWidget {
  const ScreenGallery({super.key});

  @override
  State<ScreenGallery> createState() => _ScreenGalleryState();
}

class _ScreenGalleryState extends State<ScreenGallery> {
  static const _screens = <_ScreenItem>[
    _ScreenItem(
      title: 'Movies home',
      asset: 'assets/screens/movies-home.jpg',
    ),
    _ScreenItem(
      title: 'Series',
      asset: 'assets/screens/series-detail.jpg',
    ),
    _ScreenItem(
      title: 'Episodes',
      asset: 'assets/screens/episodes.jpg',
    ),
    _ScreenItem(
      title: 'Movie details',
      asset: 'assets/screens/movie-detail.jpg',
    ),
    _ScreenItem(
      title: 'Season details',
      asset: 'assets/screens/season-detail.jpg',
    ),
    _ScreenItem(
      title: 'Episode details',
      asset: 'assets/screens/episode-detail.jpg',
    ),
    _ScreenItem(
      title: 'Live TV',
      asset: 'assets/screens/live-tv.jpg',
    ),
    _ScreenItem(
      title: 'Downloads',
      asset: 'assets/screens/downloads.jpg',
    ),
    _ScreenItem(
      title: 'Player',
      asset: 'assets/screens/player.jpg',
      landscape: true,
    ),
  ];

  final _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectScreen(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIG Screens'),
        centerTitle: false,
        backgroundColor: const Color(0xFF08090C),
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${_selectedIndex + 1} / ${_screens.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final navigation = _ScreenNavigation(
            screens: _screens,
            selectedIndex: _selectedIndex,
            onSelected: _selectScreen,
            vertical: wide,
          );
          final preview = Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _screens.length,
              onPageChanged: (index) {
                if (_selectedIndex != index) {
                  setState(() => _selectedIndex = index);
                }
              },
              itemBuilder: (context, index) {
                return _ScreenPreview(screen: _screens[index]);
              },
            ),
          );

          if (wide) {
            return Row(
              children: [
                SizedBox(width: 260, child: navigation),
                preview,
              ],
            );
          }
          return preview;
        },
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 820
          ? null
          : _ScreenNavigation(
              screens: _screens,
              selectedIndex: _selectedIndex,
              onSelected: _selectScreen,
            ),
    );
  }
}

class _ScreenNavigation extends StatelessWidget {
  const _ScreenNavigation({
    required this.screens,
    required this.selectedIndex,
    required this.onSelected,
    this.vertical = false,
  });

  final List<_ScreenItem> screens;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (var index = 0; index < screens.length; index++)
        _ScreenNavigationItem(
          screen: screens[index],
          selected: selectedIndex == index,
          onTap: () => onSelected(index),
        ),
    ];

    if (vertical) {
      return Material(
        color: const Color(0xFF101217),
        child: SafeArea(
          right: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            children: children,
          ),
        ),
      );
    }

    return Material(
      color: const Color(0xFF101217),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _ScreenNavigationItem extends StatelessWidget {
  const _ScreenNavigationItem({
    required this.screen,
    required this.selected,
    required this.onTap,
  });

  final _ScreenItem screen;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.white.withValues(alpha: 0.74);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  screen.landscape
                      ? Icons.play_circle_outline_rounded
                      : Icons.smartphone_rounded,
                  color: foreground,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Text(
                  screen.title,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenPreview extends StatelessWidget {
  const _ScreenPreview({required this.screen});

  final _ScreenItem screen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final maxWidth = screen.landscape ? 1080.0 : 420.0;
        final maxHeight = screen.landscape ? 500.0 : 760.0;
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    screen.asset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: const Color(0xFF17191F),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Unable to load ${screen.title}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}