import 'package:flutter/material.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/projects/controllers/project_controller.dart';
import 'package:frontend/features/notifications/controllers/notification_controller.dart';

class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String category;
  final Color categoryColor;
  final String timeAgo;
  final String location;
  final String imageUrl;
  final String? videoDuration;
  final bool isTopStory;
  final String fullContent;
  final String source;
  bool isBookmarked;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryColor,
    required this.timeAgo,
    required this.location,
    required this.imageUrl,
    this.videoDuration,
    this.isTopStory = false,
    required this.fullContent,
    required this.source,
    this.isBookmarked = false,
  });
}

class DashboardScreen extends StatefulWidget {
  final AuthController authController;
  final ProjectController projectController;
  final NotificationController notificationController;
  final VoidCallback onNavigateToProjects;
  final VoidCallback onNavigateToChat;

  const DashboardScreen({
    super.key,
    required this.authController,
    required this.projectController,
    required this.notificationController,
    required this.onNavigateToProjects,
    required this.onNavigateToChat,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Top News',
    'Politics',
    'Business',
    'Technology',
    'Sports',
    'Entertainment',
    'Health',
    'Science',
    'World',
  ];

  late NewsArticle _topStory;
  late List<NewsArticle> _allArticles;

  @override
  void initState() {
    super.initState();
    _initNewsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initNewsData() {
    _topStory = NewsArticle(
      id: 'top_1',
      title: 'Government Announces Major Economic Reforms to Boost Growth',
      description:
          'The new policy aims to strengthen key sectors, create more jobs and attract foreign investment.',
      category: 'Top Story',
      categoryColor: const Color(0xFFE53935),
      timeAgo: '2 hours ago',
      location: 'India',
      imageUrl:
          'https://images.unsplash.com/photo-1597042034960-49666ec46782?q=80&w=1200&auto=format&fit=crop',
      isTopStory: true,
      source: 'National Press Bureau',
      fullContent:
          'In a landmark announcement today, the government unveiled a comprehensive economic reform package designed to accelerate industrial production, expand digital infrastructure, and streamline foreign direct investment across key manufacturing sectors. Industry leaders and global analysts have welcomed the forward-looking initiatives.',
    );

    _allArticles = [
      NewsArticle(
        id: 'news_1',
        title: 'India Successfully Launches New Communication Satellite',
        description:
            'The satellite will enhance connectivity and strengthen the country\'s space capabilities.',
        category: 'Technology',
        categoryColor: const Color(0xFF2563EB), // Blue
        timeAgo: '3 hours ago',
        location: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1517976487507-580da3a82928?q=80&w=600&auto=format&fit=crop',
        videoDuration: '02:15',
        source: 'Space Research Agency',
        fullContent:
            'The latest high-throughput communication satellite was flawlessly placed into geosynchronous transfer orbit today. The satellite will provide ultra-broadband connectivity across rural corridors and support maritime emergency communications.',
      ),
      NewsArticle(
        id: 'news_2',
        title: 'India Clinches Thrilling Victory in T20 Series',
        description:
            'A fantastic team performance helps India win the series in a nail-biting final match.',
        category: 'Sports',
        categoryColor: const Color(0xFF16A34A), // Green
        timeAgo: '5 hours ago',
        location: 'Sports',
        imageUrl:
            'https://images.unsplash.com/photo-1531415074968-036ba1b575da?q=80&w=600&auto=format&fit=crop',
        source: 'Sports Desk',
        fullContent:
            'With just 6 runs needed off the final delivery, a sensational boundary sealed a dramatic series win for India in front of an electrifying home crowd. The captain lauded the young squad for staying composed under extreme pressure.',
      ),
      NewsArticle(
        id: 'news_3',
        title: 'Global Tech Giants Invest Heavily in Artificial Intelligence',
        description:
            'Major companies announce multi-billion dollar investments to accelerate AI innovation.',
        category: 'Business',
        categoryColor: const Color(0xFF7C3AED), // Purple
        timeAgo: '6 hours ago',
        location: 'World',
        imageUrl:
            'https://images.unsplash.com/photo-1677442136019-21780efad99a?q=80&w=600&auto=format&fit=crop',
        source: 'Global Tech Wire',
        fullContent:
            'Leading tech giants have pledged over \$50 billion towards next-generation artificial intelligence research centers and energy-efficient data clusters. The breakthroughs are expected to transform automated software development and cloud operations.',
      ),
      NewsArticle(
        id: 'news_4',
        title: 'Renewable Energy Milestone: Solar Power Grid Capacity Crosses 80GW',
        description:
            'Clean energy installations reach new heights with record solar rooftop additions across states.',
        category: 'Technology',
        categoryColor: const Color(0xFF2563EB),
        timeAgo: '7 hours ago',
        location: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=600&auto=format&fit=crop',
        source: 'Energy Bureau',
        fullContent:
            'India reached a historic clean energy milestone today as total operational solar capacity crossed 80 gigawatts, driven by rapid industrial adoption and community rooftop solar incentives.',
      ),
      NewsArticle(
        id: 'news_5',
        title: 'Parliamentary Committee Reviews National Digital Infrastructure Bill',
        description:
            'Bipartisan discussions advance new framework for secure data networks and cyber sovereignty.',
        category: 'Politics',
        categoryColor: const Color(0xFFDC2626),
        timeAgo: '8 hours ago',
        location: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1541872703-74c5e44368f9?q=80&w=600&auto=format&fit=crop',
        source: 'Parliament Press',
        fullContent:
            'The comprehensive Digital Security and Citizen Privacy bill entered its committee consultation phase, receiving constructive input from tech industry representatives and consumer rights advocates.',
      ),
    ];
  }

  List<NewsArticle> get _filteredArticles {
    return _allArticles.where((article) {
      final matchesCategory = _selectedCategory == 'All' ||
          _selectedCategory == 'Top News' ||
          article.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _toggleBookmark(NewsArticle article) {
    setState(() {
      article.isBookmarked = !article.isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          article.isBookmarked
              ? 'Saved to Bookmarks'
              : 'Removed from Bookmarks',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openArticleDetails(NewsArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.newspaper_rounded, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: article.categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.category,
                      style: TextStyle(
                        color: article.categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${article.timeAgo}  •  ${article.location}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Source: ${article.source}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Divider(height: 28),
              Text(
                article.fullContent,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => _toggleBookmark(article),
                      icon: Icon(
                        article.isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
                        color: const Color(0xFFE53935),
                      ),
                      label: Text(
                        article.isBookmarked ? 'Bookmarked' : 'Save Story',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Done Reading',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFE53935),
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFE53935),
          selectionColor: Color(0x4DE53935),
          selectionHandleColor: Color(0xFFE53935),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildTopHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildCategoriesRow(),
                const SizedBox(height: 18),
                if (_searchQuery.isEmpty && (_selectedCategory == 'All' || _selectedCategory == 'Top News')) ...[
                  _buildTopStoryHeroCard(),
                  const SizedBox(height: 24),
                ],
                _buildTopNewsSectionHeader(),
                const SizedBox(height: 12),
                _buildNewsArticlesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // App Logo Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // App Brand & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'News',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'Hub',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE53935),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Latest News, Always With You',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Notification Bell Button with Red Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF1F2937),
                    size: 22,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('You have 3 unread news alerts', style: TextStyle(color: Colors.white)),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // User Avatar Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF6B7280),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF9CA3AF),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xFFE53935),
                textAlignVertical: TextAlignVertical.center,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search news, topics, or keywords...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              )
            else
              const Icon(
                Icons.mic_none_rounded,
                color: Color(0xFF6B7280),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE53935) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStoryHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _openArticleDetails(_topStory),
        child: Container(
          height: 235,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.network(
                  _topStory.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Gradient dark overlay for crystal-clear readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.88),
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.8, 1.0],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
                // Content inside hero banner
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Story Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Top Story',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Headline
                      Text(
                        _topStory.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle / snippet
                      Text(
                        _topStory.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Time & Location metadata
                      Text(
                        '${_topStory.timeAgo}  |  ${_topStory.location}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildTopNewsSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Top News',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = 'All';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Color(0xFFE53935),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsArticlesList() {
    final articles = _filteredArticles;

    if (articles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No news found for "$_searchQuery"',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _buildNewsCard(articles[index]);
      },
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return GestureDetector(
      onTap: () => _openArticleDetails(article),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Thumbnail with optional duration pill
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 115,
                height: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 28,
                        ),
                      ),
                    ),
                    if (article.videoDuration != null)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.videoDuration!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Middle & Right Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Bookmark Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.category,
                        style: TextStyle(
                          color: article.categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleBookmark(article),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          article.isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: article.isBookmarked
                              ? const Color(0xFFE53935)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Headline
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Snippet
                  Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Footer Meta
                  Text(
                    '${article.timeAgo}  |  ${article.location}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
