import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../models/news_source.dart';
import '../services/rss_service.dart';
import '../services/translation_service.dart';
import '../utils/relative_time.dart';

/// Displays a pull-to-refresh list of articles fetched from [sources].
///
/// Embedded as one tab's content by [HomeScreen]; has no [Scaffold] or
/// [AppBar] of its own so it can live inside a [TabBarView].
class NewsFeedView extends StatefulWidget {
  const NewsFeedView({
    super.key,
    this.sources = const [],
    this.fetchArticles,
    this.translate,
    this.loadingLabel = '최신 뉴스를 불러오는 중...',
  });

  final List<NewsSource> sources;
  final Future<List<Article>> Function()? fetchArticles;
  final Translator? translate;
  final String loadingLabel;

  @override
  State<NewsFeedView> createState() => NewsFeedViewState();
}

class NewsFeedViewState extends State<NewsFeedView> {
  late final Future<List<Article>> Function() _fetchArticles =
      widget.fetchArticles ?? () => RssService().fetchAll(widget.sources);
  final _translationService = TranslationService();
  late final Translator _translate = widget.translate ?? _translationService.translate;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // null while the very first load is in flight; kept populated with the
  // previous results during a refresh so the list doesn't flash empty.
  List<Article>? _articles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _translationService.close();
    super.dispose();
  }

  Future<void> _load() async {
    final articles = await _fetchArticles();
    if (!mounted) return;
    setState(() => _articles = articles);
  }

  Future<void> _refresh() => _load();

  /// Triggers the same visible refresh animation as a pull gesture.
  void triggerRefresh() {
    _refreshIndicatorKey.currentState?.show();
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Builder(
        builder: (context) {
          final articles = _articles;
          if (articles == null) {
            return _LoadingState(label: widget.loadingLabel);
          }
          if (articles.isEmpty) {
            return _EmptyState(onRetry: _refresh);
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return _ArticleCard(
                key: ValueKey(articles[index].link),
                article: articles[index],
                translate: _translate,
                onTap: () => _openArticle(articles[index].link),
              );
            },
          );
        },
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});

  final String? imageUrl;

  static const double _size = 84;

  static const _placeholder = Image(
    image: AssetImage('assets/icon/icon.png'),
    width: _size,
    height: _size,
    fit: BoxFit.cover,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl == null
          ? _placeholder
          : Image.network(
              imageUrl!,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder,
            ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  const _ArticleCard({
    super.key,
    required this.article,
    required this.translate,
    required this.onTap,
  });

  final Article article;
  final Translator translate;
  final VoidCallback onTap;

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  late final Future<(String, String)> _translated = _translateArticle();

  Future<(String, String)> _translateArticle() async {
    final article = widget.article;
    if (article.isKorean) return (article.title, article.summary);

    final title = widget.translate(article.title);
    final summary = widget.translate(article.summary);
    return (await title, await summary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final article = widget.article;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(imageUrl: article.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      if (article.summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      FutureBuilder<(String, String)>(
                        future: _translated,
                        builder: (context, snapshot) {
                          final translated = snapshot.data;
                          if (translated == null) {
                            return const SizedBox.shrink();
                          }
                          final (translatedTitle, translatedSummary) = translated;
                          if (translatedTitle == article.title &&
                              translatedSummary == article.summary) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.tertiaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.translate_rounded,
                                      size: 12,
                                      color: colors.onTertiaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '번역',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colors.onTertiaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  translatedTitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (translatedSummary.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    translatedSummary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Tooltip(
                              message: article.isUnverified
                                  ? '검증되지 않은 루머성 정보가 포함될 수 있어요'
                                  : '',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: article.isUnverified
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : colors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (article.isUnverified) ...[
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 3),
                                    ],
                                    Flexible(
                                      child: Text(
                                        article.sourceName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: article.isUnverified
                                              ? Colors.amber.shade100
                                              : colors.onSecondaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            relativeTime(article.publishedAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
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

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '표시할 기사가 없습니다.\n네트워크 연결을 확인해 주세요.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: onRetry,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
