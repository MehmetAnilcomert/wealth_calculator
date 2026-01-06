import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

class SwipableAppBar extends StatefulWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final VoidCallback onAddPressed;
  final dynamic bloc;
  final List<Widget> pages;

  const SwipableAppBar({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.onAddPressed,
    required this.bloc,
    required this.pages,
  });

  @override
  _SwipableAppBarState createState() => _SwipableAppBarState();
}

class _SwipableAppBarState extends State<SwipableAppBar> {
  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: widget.expandedHeight,
      collapsedHeight: widget.collapsedHeight,
      pinned: true,
      flexibleSpace: Stack(
        children: [
          FlexibleSpaceBar(
            background: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: widget.pages,
            ),
          ),
          // Swipe indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index
                        ? Colors.white
                        : Colors.white.withAlpha(128),
                  ),
                ),
              ),
            ),
          ),
          // Swipe arrows
          if (widget.pages.length > 1) ...[
            // Left arrow
            if (currentPage > 0)
              Positioned(
                left: 8,
                bottom: MediaQuery.of(context).size.height * 0.15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            // Right arrow
            if (currentPage < widget.pages.length - 1)
              Positioned(
                right: 8,
                bottom: MediaQuery.of(context).size.height * 0.15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
          ],
          // Swipe hint animation
          if (currentPage == 0)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.12,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 10),
                duration: const Duration(seconds: 1),
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(value, 0),
                    child: child,
                  );
                },
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.swipe.tr(),
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withAlpha(204),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
