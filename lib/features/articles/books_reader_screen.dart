import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';

class BooksReaderScreen extends StatefulWidget {
  const BooksReaderScreen({super.key});

  @override
  State<BooksReaderScreen> createState() => _BooksReaderScreenState();
}

class _BooksReaderScreenState extends State<BooksReaderScreen> {
  final List<BookItem> _books = [
    BookItem(
      title: 'कबीर के दोहे',
      author: 'संत कबीर दास',
      description: 'जीवन दर्शन, प्रेम और भक्ति पर आधारित संत कबीर के कालजयी दोहे।',
      assetPath: 'assets/books/kabir_ke_dohe.txt',
      coverColor: const Color(0xFFE65100),
      icon: Icons.auto_stories,
      imageUrl: 'assets/books/kabir_ke_dohe.jpg',
    ),
    BookItem(
      title: 'विनय पत्रिका',
      author: 'गोस्वामी तुलसीदास',
      description: 'भक्ति, समर्पण और वैराग्य के पदों का अद्भुत संग्रह।',
      assetPath: 'assets/books/vinay_patrika.txt',
      coverColor: const Color(0xFFB71C1C),
      icon: Icons.menu_book_rounded,
      imageUrl: 'assets/books/vinay_patrika.jpg',
    ),
    BookItem(
      title: 'गीतांजलि (हिंदी)',
      author: 'रवीन्द्रनाथ ठाकुर',
      description: 'प्रकृति, ईश्वर और मानवता के प्रति प्रेम का काव्यमय निवेदन।',
      assetPath: 'assets/books/gitanjali.txt',
      coverColor: const Color(0xFF00695C),
      icon: Icons.spa,
      imageUrl: 'assets/books/gitanjali.jpg',
    ),
    BookItem(
      title: 'Meditations',
      author: 'Marcus Aurelius',
      description: 'Stoic philosophy on life, virtue, and inner peace. One of the greatest works of philosophy.',
      assetPath: 'assets/books/meditations.txt',
      coverColor: const Color(0xFF8B4513),
      icon: Icons.auto_stories,
      imageUrl: 'assets/books/meditations.jpg',
    ),
    BookItem(
      title: 'As a Man Thinketh',
      author: 'James Allen',
      description: 'The power of thought and its profound impact on character, health, and circumstances.',
      assetPath: 'assets/books/as_a_man_thinketh.txt',
      coverColor: const Color(0xFF607D8B),
      icon: Icons.psychology,
      imageUrl: 'assets/books/as_a_man_thinketh.jpg',
    ),
    BookItem(
      title: 'The Prophet',
      author: 'Kahlil Gibran',
      description: 'Poetic wisdom on love, marriage, joy, sorrow, work, freedom, and death.',
      assetPath: 'assets/books/the_prophet.txt',
      coverColor: const Color(0xFF7C3AED),
      icon: Icons.menu_book_rounded,
      imageUrl: 'assets/books/the_prophet.jpg',
    ),
    BookItem(
      title: 'The Art of War',
      author: 'Sun Tzu',
      description: 'Ancient strategy and mental discipline. Timeless wisdom on focus and decision-making.',
      assetPath: 'assets/books/art_of_war.txt',
      coverColor: const Color(0xFFB71C1C),
      icon: Icons.shield,
      imageUrl: 'assets/books/art_of_war.jpg',
    ),
    BookItem(
      title: 'Saathi & Gemini',
      author: 'Aari AI',
      description: 'A futuristic guide to leveraging AI for mental resilience and emotional intelligence.',
      assetPath: 'assets/books/saathi_gemini.txt',
      coverColor: const Color(0xFF6C63FF),
      icon: Icons.auto_awesome,
      imageUrl: 'assets/books/saathi_gemini.jpg',
    ),
    BookItem(
      title: 'The Dhammapada',
      author: 'Teachings of Buddha',
      description: 'Essential Buddhist teachings on mind, happiness, self-mastery, and the path to peace.',
      assetPath: 'assets/books/dhammapada.txt',
      coverColor: const Color(0xFFFF8F00),
      icon: Icons.spa,
      imageUrl: 'assets/books/dhammapada.jpg',
    ),
  ];

  // Localization instance
  late AppLocalizations localization;

  void _navigateToReader(BookItem book) async {
    await Navigator.push(
      context,
      smoothPageRoute(page: BookDetailScreen(book: book)),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _showReadingHistory(BuildContext context, AppLocalizations localization) {
    // Implement showing reading history
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.translate('reading_history') ?? 'Reading History')),
    );
  }

  Widget _buildDefaultCover(BookItem book) {
    return Center(
      child: Icon(book.icon, color: Colors.white.withOpacity(0.9), size: 40),
    );
  }

  Widget _buildBookCard(BookItem book, {bool isContinue = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _navigateToReader(book),
      child: Container(
        width: isContinue ? 280 : 160,
        margin: const EdgeInsets.only(right: 20, bottom: 8),
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Image Container with Spine effect
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: book.coverColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                            ? Image.asset(
                                book.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultCover(book),
                              )
                            : _buildDefaultCover(book),
                      ),
                    ),
                    // Decorative Spine Line
                    Positioned(
                      left: 0, top: 0, bottom: 0,
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withOpacity(0.15), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6, top: 0, bottom: 0,
                      child: Container(width: 1, color: Colors.white.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
              // Book Info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(book.author, style: TextStyle(color: book.coverColor, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (isContinue) ...[
                      const SizedBox(height: 14),
                      FutureBuilder<double>(
                        future: SharedPreferences.getInstance().then((prefs) => prefs.getDouble('progress_${book.title}') ?? 0.0),
                        builder: (context, snapshot) {
                          final progress = snapshot.data ?? 0.0;
                          final percent = (progress * 100).toInt();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(localization.translate('progress') ?? 'Progress', style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold)),
                                  Text('$percent%', style: TextStyle(fontSize: 11, color: book.coverColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress > 0 ? progress : 0.001,
                                  backgroundColor: book.coverColor.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(book.coverColor),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibrarySection(String title, List<BookItem> books, AppLocalizations localization, {bool isContinue = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 4, height: 24,
                  decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface, letterSpacing: -0.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: isContinue ? 240 : 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return _buildBookCard(books[index], isContinue: isContinue);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: CustomScrollView(
          slivers: [
            // Premium illustrative header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () => _showReadingHistory(context, localization),
                          icon: const Icon(Icons.history_rounded, color: Colors.white, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, color: Colors.white, size: 40),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(localization.translate('mindful_library') ?? 'Mindful Library', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                              Text(localization.translate('feed_your_mind') ?? 'Feed your mind with wisdom', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Colors.white70),
                          const SizedBox(width: 12),
                          Text(localization.translate('search_library') ?? 'Search library...', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            
            // Library Content Sections
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FutureBuilder<String?>(
                    future: SharedPreferences.getInstance().then((p) => p.getString('last_read_book')),
                    builder: (context, snapshot) {
                      final lastReadTitle = snapshot.data;
                      final continueBook = _books.firstWhere(
                        (b) => b.title == lastReadTitle,
                        orElse: () => _books.first,
                      );
                      return _buildLibrarySection(
                        localization.translate('continue_reading') ?? 'Continue Reading',
                        [continueBook],
                        localization,
                        isContinue: true,
                      );
                    },
                  ),
                  _buildLibrarySection(
                    localization.translate('classics') ?? 'Mental Health Classics',
                    _books,
                    localization,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailScreen extends StatefulWidget {
  final BookItem book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  String? _bookContent;
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 16.0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadBook();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _saveBookmark(silent: true);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveBookmark(silent: true);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    try {
      final content = await rootBundle.loadString(widget.book.assetPath);
      // Strip Gutenberg header/footer
      String cleaned = _stripGutenbergBoilerplate(content);
      if (mounted) {
        setState(() {
          _bookContent = cleaned;
          _isLoading = false;
        });
        // Jump to saved bookmark after content is rendered
        _loadBookmark();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load book: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOffset = prefs.getDouble('bookmark_${widget.book.title}') ?? 0.0;
      if (savedOffset > 0 && mounted) {
        // Wait for rendering to complete before jumping
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _performJump(savedOffset);
        });
      }
    } catch (_) {}
  }

  void _performJump(double offset) async {
    // Sometimes one frame isn't enough for the text to layout completely
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients && mounted) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final safeOffset = offset.clamp(0.0, maxExtent);
        _scrollController.jumpTo(safeOffset);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('resumed_bookmark')),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveBookmark({bool silent = false}) async {
    if (_scrollController.hasClients) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final offset = _scrollController.offset;
        final maxExtent = _scrollController.position.maxScrollExtent;
        final progress = maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 0.0;
        
        await prefs.setDouble('bookmark_${widget.book.title}', offset);
        await prefs.setDouble('progress_${widget.book.title}', progress);
        await prefs.setString('last_read_book', widget.book.title);
        
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).t('bookmark_saved')),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (_) {}
    }
  }

  String _stripGutenbergBoilerplate(String text) {
    // Remove Project Gutenberg header
    final startMarkers = [
      '*** START OF THE PROJECT GUTENBERG EBOOK',
      '*** START OF THIS PROJECT GUTENBERG EBOOK',
      '*END*THE SMALL PRINT',
    ];
    final endMarkers = [
      '*** END OF THE PROJECT GUTENBERG EBOOK',
      '*** END OF THIS PROJECT GUTENBERG EBOOK',
      'End of the Project Gutenberg',
      'End of Project Gutenberg',
    ];

    String result = text;

    for (final marker in startMarkers) {
      final idx = result.toUpperCase().indexOf(marker.toUpperCase());
      if (idx != -1) {
        final newlineAfter = result.indexOf('\n', idx);
        if (newlineAfter != -1) {
          result = result.substring(newlineAfter + 1);
        }
        break;
      }
    }

    for (final marker in endMarkers) {
      final idx = result.toUpperCase().indexOf(marker.toUpperCase());
      if (idx != -1) {
        result = result.substring(0, idx);
        break;
      }
    }

    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: widget.book.coverColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white),
            onPressed: () => _saveBookmark(),
            tooltip: AppLocalizations.of(context).t('save_bookmark'),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease, size: 20, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_fontSize > 12) _fontSize -= 2;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase, size: 20, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_fontSize < 28) _fontSize += 2;
              });
            },
          ),
        ],
      ),
      body: ZenAuraBackground(
        child: _isLoading
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: widget.book.coverColor),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).t('loading_book'), style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(_error!, style: TextStyle(color: Colors.grey.shade700), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Hero header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.book.coverColor,
                              widget.book.coverColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(widget.book.icon, color: Colors.white, size: 36),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.book.title,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                                letterSpacing: 0.5, height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(width: 36, height: 2, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text(
                              widget.book.author.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8), fontSize: 12,
                                fontWeight: FontWeight.w500, letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quote card
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.format_quote_rounded, color: widget.book.coverColor, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.book.description,
                                style: TextStyle(
                                 color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13,
                                  fontStyle: FontStyle.italic, height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Book text
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: SelectableText(
                          _bookContent!,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.85),
                            fontSize: _fontSize, height: 1.85,
                            letterSpacing: 0.3, fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      // End
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          children: [
                            Divider(color: widget.book.coverColor.withOpacity(0.2), indent: 40, endIndent: 40),
                            const SizedBox(height: 16),
                            Icon(Icons.auto_stories, color: widget.book.coverColor.withOpacity(0.3), size: 28),
                            const SizedBox(height: 8),
                            Text(
                              '— End of Book —',
                              style: TextStyle(color: widget.book.coverColor.withOpacity(0.4), fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      floatingActionButton: _bookContent != null
          ? FloatingActionButton.small(
              backgroundColor: widget.book.coverColor.withOpacity(0.9),
              onPressed: () {
                _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              },
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
}

class BookItem {
  final String title;
  final String author;
  final String description;
  final String assetPath;
  final Color coverColor;
  final IconData icon;
  final String? imageUrl;

  BookItem({
    required this.title,
    required this.author,
    required this.description,
    required this.assetPath,
    required this.coverColor,
    required this.icon,
    this.imageUrl,
  });
}
