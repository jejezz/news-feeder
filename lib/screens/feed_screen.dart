import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../models/news_source.dart';
import '../services/rss_service.dart';
import '../services/translation_service.dart';
import '../utils/relative_time.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, this.fetchArticles, this.translate});

  final Future<List<Article>> Function()? fetchArticles;
  final Translator? translate;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final Future<List<Article>> Function() _fetchArticles =
      widget.fetchArticles ?? () => RssService().fetchAll(usEconomyNewsSources);
  final _translationService = TranslationService();
  late final Translator _translate = widget.translate ?? _translationService.translate;
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _fetchArticles();
  }

  @override
  void dispose() {
    _translationService.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = _fetchArticles();
    setState(() => _articlesFuture = future);
    await future;
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('미국 경제 뉴스'),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Article>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _LoadingState();
            }

            final articles = snapshot.data ?? [];
            if (articles.isEmpty) {
              return _EmptyState(onRetry: _refresh);
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return _ArticleCard(
                  article: articles[index],
                  translate: _translate,
                  onTap: () => _openArticle(articles[index].link),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  const _ArticleCard({
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
    final title = widget.translate(widget.article.title);
    final summary = widget.translate(widget.article.summary);
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
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      article.imageUrl!,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(width: 84, height: 84),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                article.sourceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
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
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('최신 경제 뉴스를 불러오는 중...'),
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
