import 'package:flutter/material.dart';

import '../models/news_source.dart';
import 'feed_screen.dart';

/// Top-level screen: a shared app bar (text size control, refresh) over a
/// swipeable [TabBarView] switching between the economy and IT news feeds.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.textScaleIndex = 1,
    this.onTextScaleChanged,
  });

  final int textScaleIndex;
  final ValueChanged<int>? onTextScaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  final _economyFeedKey = GlobalKey<NewsFeedViewState>();
  final _itFeedKey = GlobalKey<NewsFeedViewState>();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshCurrentTab() {
    final key = _tabController.index == 0 ? _economyFeedKey : _itFeedKey;
    key.currentState?.triggerRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          if (widget.onTextScaleChanged case final onTextScaleChanged?)
            PopupMenuButton<int>(
              tooltip: '글자 크기',
              icon: const Icon(Icons.format_size_rounded),
              initialValue: widget.textScaleIndex,
              onSelected: onTextScaleChanged,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 0, child: Text('작게')),
                PopupMenuItem(value: 1, child: Text('보통')),
                PopupMenuItem(value: 2, child: Text('크게')),
              ],
            ),
          IconButton(
            onPressed: _refreshCurrentTab,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '새로고침',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '경제 뉴스'), Tab(text: 'IT 뉴스')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewsFeedView(
            key: _economyFeedKey,
            sources: economyNewsSources,
            loadingLabel: '최신 경제 뉴스를 불러오는 중...',
          ),
          NewsFeedView(
            key: _itFeedKey,
            sources: itNewsSources,
            loadingLabel: '최신 IT 뉴스를 불러오는 중...',
          ),
        ],
      ),
    );
  }
}
