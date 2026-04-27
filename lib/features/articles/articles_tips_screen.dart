import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smooth_page_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';

class ArticlesTipsScreen extends StatefulWidget {
  const ArticlesTipsScreen({super.key});

  @override
  State<ArticlesTipsScreen> createState() => _ArticlesTipsScreenState();
}

class _ArticlesTipsScreenState extends State<ArticlesTipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _bookmarkedIds = {};
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('article_bookmarks') ?? [];
      setState(() {
        _bookmarkedIds.addAll(bookmarks);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBookmark(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (_bookmarkedIds.contains(id)) {
          _bookmarkedIds.remove(id);
        } else {
          _bookmarkedIds.add(id);
        }
      });
      await prefs.setStringList('article_bookmarks', _bookmarkedIds.toList());
    } catch (e) {
      debugPrint('Error saving bookmark: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          localization.translate('articles') ?? 'Articles & Tips',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          tabs: [
            Tab(text: localization.translate('all') ?? 'All'),
            Tab(text: localization.translate('articles') ?? 'Articles'),
            Tab(text: localization.translate('tips') ?? 'Tips'),
          ],
        ),
      ),
      body: ZenAuraBackground(
        child: Column(
          children: [
            const SizedBox(height: 140), // Push content down below AppBar+TabBar
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: localization.translate('search') ?? 'Search...',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.5)),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildContentList(_getAllContent(), localization),
                        _buildContentList(_getArticles(), localization),
                        _buildContentList(_getTips(), localization),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookmarks(context, localization),
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.bookmark, color: colorScheme.onPrimary),
        label: Text(
          localization.translate('bookmarks') ?? 'Bookmarks',
          style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContentList(List<ContentItem> items, AppLocalizations? localization) {
    final filteredItems = items.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.excerpt.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              localization?.translate('no_results') ?? 'No results found',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildContentCard(filteredItems[index], localization);
      },
    );
  }

  Widget _buildContentCard(ContentItem item, AppLocalizations? localization) {
    final isBookmarked = _bookmarkedIds.contains(item.id);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          smoothPageRoute(
            page: ContentDetailScreen(
              item: item,
              isBookmarked: isBookmarked,
              onBookmarkToggle: () => _toggleBookmark(item.id),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  item.imageUrl ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [item.categoryColor.withOpacity(0.3), item.categoryColor.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(child: Icon(item.icon, color: item.categoryColor, size: 48)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.categoryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: TextStyle(color: item.categoryColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${item.readTime} min read',
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), height: 1.5, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                          child: Icon(Icons.person, size: 14, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.author,
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
                            size: 20,
                          ),
                          onPressed: () => _toggleBookmark(item.id),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
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
    );
  }

  void _showBookmarks(BuildContext context, AppLocalizations? localization) {
    final bookmarkedItems = _getAllContent().where((item) => _bookmarkedIds.contains(item.id)).toList();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization?.translate('bookmarks') ?? 'Bookmarks',
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurface.withOpacity(0.5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (bookmarkedItems.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          localization?.translate('no_bookmarks') ?? 'No bookmarks yet',
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: bookmarkedItems.length,
                    itemBuilder: (context, index) {
                      return _buildContentCard(bookmarkedItems[index], localization);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<ContentItem> _getAllContent() {
    return [..._getArticles(), ..._getTips()];
  }

  List<ContentItem> _getArticles() {
    return [
      ContentItem(id: 'article_1', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.psychology, title: 'Understanding Anxiety: Causes, Symptoms, and Coping Strategies', excerpt: 'Learn about anxiety disorders and evidence-based techniques to manage symptoms.', content: '# Understanding Anxiety\n\nAnxiety is your body\'s natural response to stress. Common triggers include work challenges, financial concerns, health issues, and relationship problems.\n\n## Symptoms\n- Increased heart rate, rapid breathing, sweating\n- Persistent worry, restlessness, difficulty concentrating\n\n## Types\n1. Generalized Anxiety Disorder (GAD)\n2. Panic Disorder\n3. Social Anxiety Disorder\n4. Specific Phobias\n\n## Coping Strategies\n- Deep breathing (4-4-6 pattern)\n- Progressive muscle relaxation\n- Mindfulness meditation\n- Regular exercise (30 min/day)\n- Healthy sleep habits\n- Limit caffeine and alcohol\n- Connect with others\n\nAnxiety is highly treatable. You\'re not alone.', readTime: 8, imageUrl: 'assets/articles/anxiety.jpg'),
      ContentItem(id: 'article_2', type: ContentType.article, category: 'Mindfulness', categoryColor: const Color(0xFF4CAF50), icon: Icons.self_improvement, title: 'The Science of Mindfulness Meditation', excerpt: 'How mindfulness meditation transforms mental health, backed by science.', content: '# Mindfulness Meditation\n\nMindfulness is paying attention to the present moment without judgment.\n\n## Brain Changes\n- Increases gray matter density\n- Strengthens prefrontal cortex\n- Reduces amygdala activity\n\n## Benefits\n- 30-40% stress reduction\n- Significant anxiety reduction\n- As effective as antidepressants for preventing relapse\n- Improved focus and concentration\n\n## Getting Started\n1. Find a comfortable position\n2. Focus on your breath\n3. Notice when mind wanders\n4. Gently return attention\n5. Start with 5-10 minutes daily', readTime: 12, imageUrl: 'assets/articles/mindfulness.jpg'),
      ContentItem(id: 'article_3', type: ContentType.article, category: 'Sleep', categoryColor: const Color(0xFF2196F3), icon: Icons.bedtime, title: 'Sleep Hygiene: Complete Guide to Better Sleep', excerpt: 'Evidence-based strategies for quality sleep.', content: '# Sleep Hygiene Guide\n\n## Why Sleep Matters\n- Strengthens immunity\n- Regulates mood\n- Processes memory\n- 40% more productivity\n\n## Perfect Environment\n- Temperature: 60-67°F\n- Blackout curtains\n- Noise under 40 dB\n\n## Pre-Bed Routine\n- Night mode on devices\n- Warm bath\n- Read a physical book\n- Gentle stretching\n- Breathing exercises\n\n## Sleep-Promoting Foods\n- Turkey, eggs, cheese\n- Whole grains, sweet potatoes\n- Nuts, seeds, leafy greens\n- Tart cherries, tomatoes', readTime: 10, imageUrl: 'assets/articles/sleep.jpg'),
      ContentItem(id: 'article_4', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.healing, title: 'Depression: Signs, Science, and Recovery', excerpt: 'Understanding depression and evidence-based paths to recovery.', content: '# Understanding Depression\n\nDepression is more than sadness—it\'s a medical condition affecting brain chemistry.\n\n## Signs\n- Persistent low mood for 2+ weeks\n- Loss of interest in activities\n- Changes in sleep and appetite\n- Fatigue and difficulty concentrating\n- Feelings of worthlessness\n\n## Recovery Strategies\n- Behavioral activation: schedule enjoyable activities\n- Exercise: natural antidepressant\n- Social connection\n- Professional therapy (CBT)\n- Medication when appropriate\n\nRecovery is possible. One step at a time.', readTime: 10),
      ContentItem(id: 'article_5', type: ContentType.article, category: 'Stress', categoryColor: const Color(0xFFFF5722), icon: Icons.local_fire_department, title: 'Stress Management: The Complete Toolkit', excerpt: 'Master stress with proven techniques from psychology.', content: '# Stress Management Toolkit\n\n## Understanding Stress\nStress triggers fight-or-flight response. Chronic stress damages health.\n\n## Physical Techniques\n- Deep breathing exercises\n- Progressive muscle relaxation\n- Yoga and tai chi\n- Regular exercise\n\n## Mental Techniques\n- Cognitive reframing\n- Time management\n- Setting boundaries\n- Mindfulness practice\n\n## Lifestyle Changes\n- Prioritize sleep\n- Limit screen time\n- Spend time in nature\n- Nurture relationships\n- Practice gratitude', readTime: 8),
      ContentItem(id: 'article_6', type: ContentType.article, category: 'Relationships', categoryColor: const Color(0xFFE91E63), icon: Icons.people, title: 'Building Healthy Relationships', excerpt: 'Communication skills and boundaries for better connections.', content: '# Healthy Relationships\n\n## Foundation\n- Mutual respect and trust\n- Open communication\n- Healthy boundaries\n- Emotional support\n\n## Communication Skills\n- Active listening\n- "I" statements instead of blame\n- Expressing needs clearly\n- Empathy and validation\n\n## Setting Boundaries\n- Know your limits\n- Communicate them clearly\n- Be consistent\n- Respect others\' boundaries too\n\n## Warning Signs\n- Constant criticism\n- Isolation from friends\n- Controlling behavior\n- Lack of respect', readTime: 9),
      ContentItem(id: 'article_7', type: ContentType.article, category: 'Self-Care', categoryColor: const Color(0xFF00BCD4), icon: Icons.spa, title: 'The Art of Self-Care: Beyond Bubble Baths', excerpt: 'Meaningful self-care practices that truly nourish your wellbeing.', content: '# True Self-Care\n\n## Physical\n- Nourishing food\n- Regular movement\n- Adequate sleep\n- Health check-ups\n\n## Emotional\n- Processing feelings\n- Setting boundaries\n- Saying no without guilt\n- Seeking support\n\n## Mental\n- Learning new skills\n- Reading and growing\n- Digital detox\n- Creative expression\n\n## Social\n- Quality time with loved ones\n- Community involvement\n- Asking for help\n- Letting go of toxic relationships', readTime: 7),
      ContentItem(id: 'article_8', type: ContentType.article, category: 'Productivity', categoryColor: const Color(0xFF607D8B), icon: Icons.timer, title: 'Focus and Deep Work in a Distracted World', excerpt: 'Techniques for sustained concentration and meaningful productivity.', content: '# Deep Work & Focus\n\n## The Attention Crisis\nAverage person checks phone 96 times/day. Deep work requires uninterrupted focus.\n\n## Strategies\n- Time blocking (90-minute sessions)\n- Pomodoro Technique (25 min work, 5 min break)\n- Environment design\n- Digital minimalism\n\n## Building Focus\n- Start with 15 minutes, grow gradually\n- Meditation trains attention\n- Single-tasking over multitasking\n- Schedule deep work for peak energy hours\n\n## Eliminating Distractions\n- Phone in another room\n- Website blockers\n- Noise-canceling headphones\n- Clear workspace', readTime: 8),
      ContentItem(id: 'article_9', type: ContentType.article, category: 'Nutrition', categoryColor: const Color(0xFF8BC34A), icon: Icons.restaurant, title: 'Brain Food: Nutrition for Mental Health', excerpt: 'How diet impacts mood, focus, and mental wellbeing.', content: '# Brain Food\n\n## Gut-Brain Connection\n95% of serotonin produced in gut. Diet directly impacts mood.\n\n## Brain-Boosting Foods\n- Fatty fish (omega-3s)\n- Blueberries (antioxidants)\n- Nuts and seeds\n- Dark leafy greens\n- Dark chocolate\n- Fermented foods\n\n## Foods to Limit\n- Processed sugar\n- Refined carbs\n- Excessive caffeine\n- Alcohol\n- Ultra-processed foods\n\n## Meal Patterns\n- Regular meals prevent blood sugar crashes\n- Breakfast fuels morning focus\n- Hydration affects cognition\n- Mediterranean diet linked to lower depression', readTime: 9),
      ContentItem(id: 'article_10', type: ContentType.article, category: 'Resilience', categoryColor: const Color(0xFFFF9800), icon: Icons.shield, title: 'Building Mental Resilience', excerpt: 'Developing the psychological strength to bounce back from adversity.', content: '# Mental Resilience\n\n## What is Resilience?\nThe ability to adapt and bounce back from stress, adversity, and trauma.\n\n## Key Components\n- Emotional awareness\n- Optimistic thinking\n- Problem-solving skills\n- Strong social connections\n- Sense of purpose\n\n## Building Resilience\n- Reframe challenges as opportunities\n- Build a support network\n- Practice self-compassion\n- Set achievable goals\n- Learn from setbacks\n- Maintain routines during chaos\n\n## Daily Practices\n- Morning gratitude\n- Physical exercise\n- Journaling\n- Connecting with others\n- Setting boundaries', readTime: 10),
      ContentItem(id: 'article_11', type: ContentType.article, category: 'Emotional Intelligence', categoryColor: const Color(0xFF673AB7), icon: Icons.emoji_emotions, title: 'Emotional Intelligence: The Key to Success', excerpt: 'Understanding and managing emotions for better relationships and life outcomes.', content: '# Emotional Intelligence\n\n## Five Components (Goleman)\n1. Self-awareness\n2. Self-regulation\n3. Motivation\n4. Empathy\n5. Social skills\n\n## Developing EQ\n- Name your emotions precisely\n- Pause before reacting\n- Practice active listening\n- Consider others\' perspectives\n- Manage stress effectively\n\n## Benefits\n- Better relationships\n- Career success\n- Mental health\n- Conflict resolution\n- Leadership ability', readTime: 8),
      ContentItem(id: 'article_12', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.psychology_alt, title: 'PTSD and Trauma Recovery', excerpt: 'Understanding trauma responses and healing pathways.', content: '# Trauma Recovery\n\n## Understanding PTSD\nPost-traumatic stress disorder develops after experiencing or witnessing traumatic events.\n\n## Symptoms\n- Flashbacks and nightmares\n- Avoidance behaviors\n- Hypervigilance\n- Emotional numbness\n- Difficulty sleeping\n\n## Recovery Approaches\n- Trauma-focused CBT\n- EMDR therapy\n- Somatic experiencing\n- Support groups\n- Grounding techniques\n\n## Self-Help Strategies\n- Establish safety routines\n- Practice grounding (5-4-3-2-1)\n- Gentle movement and yoga\n- Creative expression\n- Patient self-compassion\n\nHealing is not linear, but it is possible.', readTime: 11),
      ContentItem(id: 'article_13', type: ContentType.article, category: 'Mindfulness', categoryColor: const Color(0xFF4CAF50), icon: Icons.nature, title: 'Nature Therapy: Healing Power of the Outdoors', excerpt: 'Scientific evidence for nature\'s impact on mental health.', content: '# Nature Therapy\n\n## The Science\n- 20 minutes in nature reduces cortisol by 13%\n- Forest bathing boosts immune system\n- Green spaces linked to lower depression rates\n- Natural light regulates circadian rhythm\n\n## Practices\n- Daily 20-minute nature walks\n- Forest bathing (shinrin-yoku)\n- Gardening\n- Outdoor exercise\n- Nature photography\n- Birdwatching\n\n## Urban Nature\n- Visit parks\n- Indoor plants\n- Nature sounds playlists\n- Open windows for fresh air\n- Walk barefoot on grass', readTime: 7),
      ContentItem(id: 'article_14', type: ContentType.article, category: 'Self-Care', categoryColor: const Color(0xFF00BCD4), icon: Icons.fitness_center, title: 'Exercise as Medicine for Mental Health', excerpt: 'How physical activity rivals medication for depression and anxiety.', content: '# Exercise as Medicine\n\n## The Evidence\n- 30 min exercise = as effective as antidepressants for mild-moderate depression\n- Reduces anxiety by 20%\n- Improves sleep by 65%\n- Boosts self-esteem and confidence\n\n## Types That Help\n- Aerobic: running, swimming, cycling\n- Yoga: combines movement and mindfulness\n- Strength training: builds confidence\n- Walking: most accessible form\n- Dance: social and joyful\n\n## Getting Started\n- Start with 10 minutes\n- Choose enjoyable activities\n- Set realistic goals\n- Find an exercise buddy\n- Be consistent, not intense', readTime: 8),
      ContentItem(id: 'article_15', type: ContentType.article, category: 'Stress', categoryColor: const Color(0xFFFF5722), icon: Icons.school, title: 'Student Mental Health: Thriving Under Pressure', excerpt: 'Managing academic stress, exam anxiety, and student burnout.', content: '# Student Mental Health\n\n## Common Challenges\n- Exam anxiety\n- Academic pressure\n- Social comparison\n- Sleep deprivation\n- Financial stress\n\n## Coping Strategies\n- Study planning and time management\n- Break tasks into smaller chunks\n- Active recall over passive reading\n- Regular breaks (Pomodoro)\n- Physical exercise\n\n## Exam Anxiety Tips\n- Prepare early, not last minute\n- Practice under test conditions\n- Use breathing techniques\n- Positive self-talk\n- Adequate sleep before exams\n\n## Seeking Help\n- Campus counseling services\n- Peer support groups\n- Mental health apps\n- Trusted mentors', readTime: 9),
      ContentItem(id: 'article_16', type: ContentType.article, category: 'Relationships', categoryColor: const Color(0xFFE91E63), icon: Icons.family_restroom, title: 'Family Mental Health: Breaking the Cycle', excerpt: 'How family dynamics shape mental health across generations.', content: '# Family Mental Health\n\n## Generational Patterns\n- Attachment styles are learned\n- Communication patterns repeat\n- Unresolved trauma passes down\n- Breaking cycles takes awareness\n\n## Healthy Family Dynamics\n- Open communication\n- Respect for individuality\n- Shared quality time\n- Constructive conflict resolution\n- Emotional validation\n\n## Breaking Toxic Patterns\n- Recognize unhealthy patterns\n- Seek therapy\n- Set boundaries with love\n- Model healthy behavior\n- Practice forgiveness', readTime: 10),
      ContentItem(id: 'article_17', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.mood, title: 'Understanding Bipolar Disorder', excerpt: 'Navigating the highs and lows of bipolar disorder.', content: '# Bipolar Disorder\n\n## Types\n- Bipolar I: severe mania and depression\n- Bipolar II: hypomania and depression\n- Cyclothymia: mild mood swings\n\n## Manic Symptoms\n- Elevated mood and energy\n- Reduced need for sleep\n- Racing thoughts\n- Impulsive behavior\n\n## Depressive Symptoms\n- Low mood and energy\n- Loss of interest\n- Sleep changes\n- Feelings of hopelessness\n\n## Management\n- Mood stabilizing medication\n- Therapy (CBT, IPSRT)\n- Regular sleep schedule\n- Mood tracking\n- Support network', readTime: 11),
      ContentItem(id: 'article_18', type: ContentType.article, category: 'Mindfulness', categoryColor: const Color(0xFF4CAF50), icon: Icons.auto_awesome, title: 'Gratitude Practice: Rewiring Your Brain for Happiness', excerpt: 'The neuroscience of gratitude and practical daily exercises.', content: '# Gratitude Practice\n\n## The Science\n- Gratitude activates dopamine and serotonin\n- Regular practice physically rewires neural pathways\n- 25% increase in happiness after 10 weeks\n- Improves sleep quality by 25%\n\n## Daily Practices\n- Morning gratitude (3 things)\n- Gratitude journal\n- Thank-you notes\n- Savoring positive moments\n- Gratitude meditation\n\n## Advanced Techniques\n- Gratitude for challenges (growth mindset)\n- Expressing appreciation to others\n- Gratitude walks\n- Photo gratitude journal\n- Bedtime reflection', readTime: 7),
      ContentItem(id: 'article_19', type: ContentType.article, category: 'Productivity', categoryColor: const Color(0xFF607D8B), icon: Icons.work, title: 'Burnout Recovery and Prevention', excerpt: 'Recognizing, recovering from, and preventing workplace burnout.', content: '# Burnout Recovery\n\n## Signs of Burnout\n- Emotional exhaustion\n- Cynicism and detachment\n- Reduced performance\n- Physical symptoms\n- Loss of motivation\n\n## Recovery Steps\n1. Acknowledge the burnout\n2. Set firm boundaries\n3. Take time off\n4. Reconnect with values\n5. Seek professional support\n\n## Prevention\n- Work-life boundaries\n- Regular breaks and vacations\n- Meaningful work connections\n- Exercise and sleep\n- Saying no to overcommitment\n- Delegating when possible', readTime: 9),
      ContentItem(id: 'article_20', type: ContentType.article, category: 'Sleep', categoryColor: const Color(0xFF2196F3), icon: Icons.nightlight_round, title: 'Dreams and Mental Health', excerpt: 'What your dreams reveal about your psychological state.', content: '# Dreams & Mental Health\n\n## Why We Dream\n- Memory consolidation\n- Emotional processing\n- Problem solving\n- Creativity enhancement\n\n## Dream Patterns\n- Anxiety dreams often reflect daily stress\n- Recurring dreams signal unresolved issues\n- Lucid dreaming can be therapeutic\n- Nightmares may indicate PTSD\n\n## Using Dreams\n- Keep a dream journal\n- Look for recurring themes\n- Discuss with therapist\n- Practice lucid dreaming\n- Use guided imagery before sleep', readTime: 8),
      ContentItem(id: 'article_21', type: ContentType.article, category: 'Self-Care', categoryColor: const Color(0xFF00BCD4), icon: Icons.palette, title: 'Art Therapy: Healing Through Creativity', excerpt: 'How creative expression promotes mental health and emotional processing.', content: '# Art Therapy\n\n## Benefits\n- Reduces stress and anxiety\n- Processes difficult emotions\n- Improves self-awareness\n- Builds confidence\n- No artistic skill required\n\n## Activities\n- Free drawing/painting\n- Mandala coloring\n- Collage making\n- Clay sculpting\n- Music creation\n- Creative writing\n- Photography\n\n## Getting Started\n- Set aside 15-30 minutes\n- No judgment on output\n- Focus on the process\n- Use colors that feel right\n- Let emotions guide you', readTime: 7),
      ContentItem(id: 'article_22', type: ContentType.article, category: 'Resilience', categoryColor: const Color(0xFFFF9800), icon: Icons.trending_up, title: 'Growth Mindset: Embracing Challenges', excerpt: 'How your beliefs about ability shape your potential.', content: '# Growth Mindset\n\n## Fixed vs Growth\n- Fixed: "I\'m not smart enough"\n- Growth: "I can learn this with effort"\n\n## Developing Growth Mindset\n- Embrace "yet" — "I can\'t do this yet"\n- View failures as learning\n- Value effort over talent\n- Seek challenges\n- Learn from criticism\n\n## Daily Practice\n- Reframe negative self-talk\n- Celebrate effort, not just results\n- Set learning goals\n- Embrace discomfort\n- Study how others overcame obstacles', readTime: 7),
      ContentItem(id: 'article_23', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.groups, title: 'Social Anxiety: From Avoidance to Connection', excerpt: 'Practical strategies for managing social anxiety.', content: '# Social Anxiety\n\n## Common Fears\n- Being judged by others\n- Embarrassing yourself\n- Being the center of attention\n- Small talk and conversations\n\n## Cognitive Strategies\n- Challenge catastrophic thoughts\n- Reality-test predictions\n- Focus outward, not inward\n- Accept imperfection\n\n## Behavioral Steps\n- Gradual exposure to social situations\n- Start with low-stakes interactions\n- Practice conversation skills\n- Join structured groups\n- Volunteer for a cause you care about\n\nSocial anxiety is one of the most treatable conditions.', readTime: 9),
      ContentItem(id: 'article_24', type: ContentType.article, category: 'Emotional Intelligence', categoryColor: const Color(0xFF673AB7), icon: Icons.volunteer_activism, title: 'The Power of Self-Compassion', excerpt: 'Why being kind to yourself is not weakness but strength.', content: '# Self-Compassion\n\n## Three Components (Kristin Neff)\n1. Self-kindness vs self-judgment\n2. Common humanity vs isolation\n3. Mindfulness vs over-identification\n\n## Benefits\n- Reduces anxiety and depression\n- Increases motivation\n- Improves relationships\n- Builds resilience\n- Enhances emotional wellbeing\n\n## Practices\n- Self-compassion break\n- Loving-kindness meditation\n- Writing yourself a letter\n- Treating yourself as a friend\n- Acknowledging suffering without judgment', readTime: 8),
      ContentItem(id: 'article_25', type: ContentType.article, category: 'Stress', categoryColor: const Color(0xFFFF5722), icon: Icons.phone_android, title: 'Digital Wellness: Managing Screen Time', excerpt: 'Balancing technology use for better mental health.', content: '# Digital Wellness\n\n## The Problem\n- Average 7+ hours screen time daily\n- Social media linked to depression\n- Blue light disrupts sleep\n- Information overload causes anxiety\n\n## Digital Boundaries\n- No-phone zones (bedroom, meals)\n- Screen-free first/last hour\n- App time limits\n- Notification management\n- Regular digital detox days\n\n## Healthy Tech Habits\n- Use apps mindfully, not mindlessly\n- Curate positive feeds\n- Real connections over virtual\n- Night mode/blue light filters\n- One screen at a time', readTime: 8),
      ContentItem(id: 'article_26', type: ContentType.article, category: 'Nutrition', categoryColor: const Color(0xFF8BC34A), icon: Icons.local_cafe, title: 'Mindful Eating for Mental Wellness', excerpt: 'Transform your relationship with food through mindfulness.', content: '# Mindful Eating\n\n## What is Mindful Eating?\nPaying full attention to the experience of eating without judgment.\n\n## Benefits\n- Reduces emotional eating\n- Improves digestion\n- Better food choices\n- Greater satisfaction from meals\n- Weight management\n\n## Practice Steps\n1. Eat without distractions\n2. Notice colors, smells, textures\n3. Chew slowly (20-30 times)\n4. Check hunger levels before eating\n5. Stop when 80% full\n6. Express gratitude for food', readTime: 6),
      ContentItem(id: 'article_27', type: ContentType.article, category: 'Relationships', categoryColor: const Color(0xFFE91E63), icon: Icons.handshake, title: 'Forgiveness: Freeing Yourself from Resentment', excerpt: 'The psychology of forgiveness and its healing power.', content: '# The Power of Forgiveness\n\n## What Forgiveness Is NOT\n- Condoning bad behavior\n- Forgetting what happened\n- Reconciliation required\n- A sign of weakness\n\n## What Forgiveness IS\n- Releasing resentment for YOUR peace\n- A process, not an event\n- A choice to stop suffering\n- Freedom from the past\n\n## Health Benefits\n- Lower blood pressure\n- Reduced anxiety/depression\n- Better immune function\n- Improved relationships\n- Greater life satisfaction\n\n## Steps to Forgiveness\n1. Acknowledge the hurt\n2. Process your emotions\n3. Choose to forgive\n4. Release bitterness\n5. Wish the person well (optional)', readTime: 9),
      ContentItem(id: 'article_28', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.diversity_3, title: 'OCD: Understanding Obsessive-Compulsive Disorder', excerpt: 'Beyond stereotypes—the reality of living with OCD.', content: '# Understanding OCD\n\n## What OCD Really Is\n- Intrusive, unwanted thoughts (obsessions)\n- Repetitive behaviors to reduce anxiety (compulsions)\n- NOT just liking things neat\n- A neurological condition\n\n## Common Types\n- Contamination fears\n- Checking behaviors\n- Symmetry/ordering\n- Intrusive thoughts\n- Hoarding\n\n## Treatment\n- ERP (Exposure and Response Prevention)\n- CBT therapy\n- Medication (SSRIs)\n- Mindfulness-based approaches\n- Support groups\n\nRecovery is absolutely possible with proper treatment.', readTime: 10),
      ContentItem(id: 'article_29', type: ContentType.article, category: 'Resilience', categoryColor: const Color(0xFFFF9800), icon: Icons.self_improvement, title: 'Stoic Philosophy for Modern Mental Health', excerpt: 'Ancient wisdom for navigating modern challenges.', content: '# Stoic Mental Health\n\n## Key Principles\n- Focus on what you can control\n- Accept what you cannot change\n- View obstacles as opportunities\n- Practice negative visualization\n- Live according to your values\n\n## Daily Stoic Practices\n- Morning reflection on the day ahead\n- Evening review of actions\n- Voluntary discomfort (cold showers, fasting)\n- Memento mori — remember mortality\n- Amor fati — love your fate\n\n## Modern Application\n- Reduce anxiety by accepting uncertainty\n- Build resilience through reframing\n- Find meaning in challenges\n- Practice emotional regulation', readTime: 8),
      ContentItem(id: 'article_30', type: ContentType.article, category: 'Self-Care', categoryColor: const Color(0xFF00BCD4), icon: Icons.music_note, title: 'Music Therapy: Healing Rhythms', excerpt: 'How music affects the brain and supports emotional wellbeing.', content: '# Music Therapy\n\n## How Music Affects the Brain\n- Activates dopamine release\n- Reduces cortisol (stress hormone)\n- Synchronizes brainwaves\n- Triggers emotional memories\n- Improves neural connectivity\n\n## Therapeutic Uses\n- Anxiety: slow tempo (60-80 BPM)\n- Depression: uplifting familiar songs\n- Insomnia: calming nature sounds\n- Focus: lo-fi, classical, ambient\n- Processing grief: meaningful songs\n\n## Creating Your Toolkit\n- Build mood-specific playlists\n- Try making music (no skill needed)\n- Sing — it releases endorphins\n- Dance freely to favorite songs\n- Practice mindful listening', readTime: 7),
      ContentItem(id: 'article_31', type: ContentType.article, category: 'Mindfulness', categoryColor: const Color(0xFF4CAF50), icon: Icons.air, title: 'Breathwork: Advanced Breathing Techniques', excerpt: 'Master various breathing patterns for different emotional states.', content: '# Advanced Breathwork\n\n## Techniques\n\n### Box Breathing (Calm)\n4-4-4-4 pattern. Used by Navy SEALs.\n\n### 4-7-8 Breathing (Sleep)\nInhale 4, hold 7, exhale 8. Promotes deep sleep.\n\n### Wim Hof Method (Energy)\n30 deep breaths, hold, recover. Boosts energy and immunity.\n\n### Alternate Nostril (Balance)\nBalances left and right brain hemispheres.\n\n### Pursed Lip (Anxiety)\nSlow exhale through pursed lips. Activates parasympathetic system.\n\n## When to Use\n- Morning: energizing techniques\n- Pre-meeting: box breathing\n- Before sleep: 4-7-8\n- During anxiety: pursed lip\n- Meditation: alternate nostril', readTime: 8),
      ContentItem(id: 'article_32', type: ContentType.article, category: 'Productivity', categoryColor: const Color(0xFF607D8B), icon: Icons.psychology, title: 'Cognitive Biases That Sabotage Happiness', excerpt: 'Mental shortcuts that distort thinking and how to overcome them.', content: '# Cognitive Biases\n\n## Common Biases\n- Negativity bias: focusing on bad over good\n- Catastrophizing: assuming worst outcome\n- Black-and-white thinking: no middle ground\n- Mind reading: assuming what others think\n- Emotional reasoning: feelings = facts\n\n## Impact on Mental Health\n- Fuel anxiety and depression\n- Damage relationships\n- Reduce self-esteem\n- Create self-fulfilling prophecies\n\n## Overcoming Biases\n- Awareness is the first step\n- Question your assumptions\n- Look for evidence\n- Consider alternative explanations\n- Practice cognitive restructuring\n- Keep a thought journal', readTime: 9),
      ContentItem(id: 'article_33', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.sentiment_very_dissatisfied, title: 'Anger Management: Channeling Your Fire', excerpt: 'Healthy ways to express and manage anger.', content: '# Anger Management\n\n## Understanding Anger\n- Anger is a normal, healthy emotion\n- It becomes a problem when destructive\n- Often masks hurt, fear, or frustration\n\n## Warning Signs\n- Clenched jaw/fists\n- Racing heart\n- Hot face\n- Raised voice\n- Tunnel vision\n\n## Healthy Expression\n- Name the emotion: "I feel angry because..."\n- Take a timeout (20 minutes minimum)\n- Physical release: exercise, punch a pillow\n- Write it out\n- Communicate assertively, not aggressively\n\n## Long-term Strategies\n- Identify triggers\n- Practice relaxation daily\n- Improve communication skills\n- Challenge irrational thoughts\n- Seek counseling if needed', readTime: 8),
      ContentItem(id: 'article_34', type: ContentType.article, category: 'Emotional Intelligence', categoryColor: const Color(0xFF673AB7), icon: Icons.balance, title: 'Emotional Regulation: Mastering Your Inner World', excerpt: 'Strategies for managing intense emotions effectively.', content: '# Emotional Regulation\n\n## What It Is\nThe ability to monitor, evaluate, and modify emotional reactions.\n\n## Strategies\n\n### In the Moment\n- STOP: Stop, Take a breath, Observe, Proceed\n- Name the emotion (reduces intensity by 50%)\n- Opposite action (act opposite to the urge)\n- Cold water on face (activates dive reflex)\n\n### Long-term\n- Regular mindfulness practice\n- Physical exercise\n- Adequate sleep\n- Reduce stressors\n- Therapy (DBT is excellent)\n\n## Key Insight\nYou can\'t control what you feel, but you CAN control how you respond.', readTime: 9),
      ContentItem(id: 'article_35', type: ContentType.article, category: 'Sleep', categoryColor: const Color(0xFF2196F3), icon: Icons.alarm, title: 'Circadian Rhythm: Your Body\'s Master Clock', excerpt: 'Optimizing your natural sleep-wake cycle for peak performance.', content: '# Circadian Rhythm\n\n## Your Internal Clock\n- 24-hour biological cycle\n- Controls sleep, hormones, temperature\n- Disruption linked to depression, obesity, heart disease\n\n## Optimizing Your Clock\n- Morning sunlight (first 30 minutes)\n- Consistent wake time (even weekends)\n- Avoid bright light at night\n- Exercise in morning/afternoon\n- Eat meals at regular times\n\n## Chronotypes\n- Lion (early bird): peak 6am-12pm\n- Bear (most people): peak 10am-2pm\n- Wolf (night owl): peak 5pm-12am\n- Dolphin (light sleeper): peak 3pm-9pm\n\nWork WITH your chronotype, not against it.', readTime: 8),
      ContentItem(id: 'article_36', type: ContentType.article, category: 'Stress', categoryColor: const Color(0xFFFF5722), icon: Icons.spa, title: 'Yoga for Mental Health', excerpt: 'How yoga combines movement, breathing, and mindfulness for emotional healing.', content: '# Yoga for Mental Health\n\n## Evidence\n- Reduces cortisol by 25%\n- Increases GABA (anti-anxiety neurotransmitter)\n- Improves HRV (stress resilience)\n- As effective as medication for some anxiety disorders\n\n## Best Styles for Mental Health\n- Yin yoga: deep relaxation\n- Hatha: gentle and accessible\n- Restorative: total relaxation\n- Vinyasa: energizing and mood-lifting\n- Yoga Nidra: guided deep relaxation\n\n## Getting Started\n- Start with 10-minute sessions\n- No flexibility required\n- Follow online classes\n- Focus on breath over poses\n- Be gentle with yourself', readTime: 7),
      ContentItem(id: 'article_37', type: ContentType.article, category: 'Relationships', categoryColor: const Color(0xFFE91E63), icon: Icons.favorite_border, title: 'Attachment Styles and Your Relationships', excerpt: 'How early bonds shape adult relationship patterns.', content: '# Attachment Styles\n\n## Four Styles\n1. Secure: comfortable with intimacy and independence\n2. Anxious: fears abandonment, seeks reassurance\n3. Avoidant: values independence, fears closeness\n4. Disorganized: mixed signals, fears both closeness and distance\n\n## Identifying Your Style\n- How do you react during conflict?\n- What happens when partner is distant?\n- Do you express needs easily?\n- How do you handle vulnerability?\n\n## Moving to Secure\n- Self-awareness is step one\n- Therapy (especially attachment-focused)\n- Choose secure partners\n- Practice vulnerability gradually\n- Challenge old patterns consciously', readTime: 10),
      ContentItem(id: 'article_38', type: ContentType.article, category: 'Mental Health', categoryColor: const Color(0xFF9C27B0), icon: Icons.psychology, title: 'ADHD in Adults: Beyond the Stereotype', excerpt: 'Understanding adult ADHD and strategies for thriving.', content: '# Adult ADHD\n\n## Symptoms in Adults\n- Difficulty focusing (or hyperfocus)\n- Disorganization and forgetfulness\n- Impulsivity\n- Restlessness\n- Time blindness\n- Emotional dysregulation\n\n## Strengths of ADHD\n- Creativity and innovation\n- High energy and enthusiasm\n- Hyperfocus on interests\n- Risk-taking and entrepreneurship\n- Out-of-the-box thinking\n\n## Management Strategies\n- External structure (calendars, reminders)\n- Body doubling for tasks\n- Break tasks into tiny steps\n- Use timers\n- Exercise regularly\n- Medication when appropriate\n- ADHD coaching', readTime: 10),
      ContentItem(id: 'article_39', type: ContentType.article, category: 'Resilience', categoryColor: const Color(0xFFFF9800), icon: Icons.psychology, title: 'Post-Traumatic Growth: Finding Meaning After Adversity', excerpt: 'How struggle can lead to profound personal transformation.', content: '# Post-Traumatic Growth\n\n## What It Is\nPositive psychological change experienced as a result of struggling with highly challenging life circumstances.\n\n## Five Domains\n1. Greater appreciation for life\n2. Improved relationships\n3. New possibilities recognized\n4. Increased personal strength\n5. Spiritual/existential growth\n\n## Facilitating Growth\n- Allow yourself to grieve\n- Find meaning in the experience\n- Connect with others who understand\n- Write about your experience\n- Seek professional guidance\n- Embrace the changed you\n\nGrowth doesn\'t mean the trauma was good. It means YOU are strong.', readTime: 9),
      ContentItem(id: 'article_40', type: ContentType.article, category: 'Mindfulness', categoryColor: const Color(0xFF4CAF50), icon: Icons.self_improvement, title: 'Body Scan Meditation: Complete Guide', excerpt: 'A powerful technique for releasing tension and building body awareness.', content: '# Body Scan Meditation\n\n## What It Is\nA mindfulness practice of systematically focusing attention on each part of the body.\n\n## Benefits\n- Reduces physical tension\n- Improves body awareness\n- Promotes relaxation\n- Better sleep\n- Reduces chronic pain\n\n## How to Practice\n1. Lie down comfortably\n2. Close eyes, take deep breaths\n3. Focus on toes — notice sensations\n4. Slowly move attention upward\n5. Feet, ankles, calves, knees...\n6. Continue through entire body\n7. Notice without judging\n8. Release tension as you go\n9. End with whole-body awareness\n\nPractice for 15-45 minutes. Daily for best results.', readTime: 7),
      ContentItem(id: 'article_41', type: ContentType.article, category: 'Self-Care', categoryColor: const Color(0xFF00BCD4), icon: Icons.sunny, title: 'Morning Routines for Mental Health', excerpt: 'Design a morning that sets you up for emotional success.', content: '# Morning Routines\n\n## Why Mornings Matter\n- Cortisol naturally peaks in morning\n- First hour shapes the rest of the day\n- Proactive vs reactive start\n\n## Ideal Mental Health Morning\n1. Wake at consistent time\n2. Avoid phone for first 30 min\n3. Sunlight exposure\n4. Hydrate (water before coffee)\n5. Movement (even 10 minutes)\n6. Mindfulness or meditation\n7. Nutritious breakfast\n8. Set 3 intentions for the day\n\n## Customizing\n- Start with 1-2 elements\n- Add gradually over weeks\n- Adjust to your chronotype\n- Weekend version can be lighter\n- Consistency over perfection', readTime: 7),
      ContentItem(id: 'article_42', type: ContentType.article, category: 'Emotional Intelligence', categoryColor: const Color(0xFF673AB7), icon: Icons.record_voice_over, title: 'Assertive Communication: Finding Your Voice', excerpt: 'Express your needs clearly without aggression or passivity.', content: '# Assertive Communication\n\n## Three Styles\n- Passive: your needs don\'t matter\n- Aggressive: only your needs matter\n- Assertive: both needs matter equally\n\n## Assertive Techniques\n- "I" statements: "I feel... when... because..."\n- Broken record: calmly repeat your position\n- Fogging: acknowledge without agreeing\n- Saying no without guilt\n\n## Practice Scenarios\n- Declining extra work\n- Expressing disagreement\n- Asking for what you need\n- Setting boundaries\n- Giving constructive feedback\n\n## Key: You have the RIGHT to express your needs.', readTime: 8),
    ];
  }

  List<ContentItem> _getTips() {
    return [
      ContentItem(id: 'tip_1', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFFFF9800), icon: Icons.lightbulb, title: '5-4-3-2-1 Grounding Technique', excerpt: 'Bring yourself to the present when overwhelmed.', content: '# 5-4-3-2-1 Grounding\n\n- **5** things you can SEE\n- **4** things you can TOUCH\n- **3** things you can HEAR\n- **2** things you can SMELL\n- **1** thing you can TASTE\n\nRedirects focus from anxious thoughts to surroundings.', readTime: 2),
      ContentItem(id: 'tip_2', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF4CAF50), icon: Icons.spa, title: 'Box Breathing for Instant Calm', excerpt: 'Navy SEAL technique to calm nerves in 2 minutes.', content: '# Box Breathing\n\n1. Breathe IN 4s\n2. HOLD 4s\n3. OUT 4s\n4. HOLD 4s\n\nRepeat 4-6 times. Activates parasympathetic system.', readTime: 1),
      ContentItem(id: 'tip_3', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF2196F3), icon: Icons.water_drop, title: 'The 20-20-20 Rule', excerpt: 'Protect eyes during long screen sessions.', content: '# 20-20-20 Rule\n\nEvery 20 minutes, look 20 feet away for 20 seconds. Reduces eye strain and headaches.', readTime: 1),
      ContentItem(id: 'tip_4', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF9C27B0), icon: Icons.favorite, title: 'Gratitude Journaling', excerpt: '3 things daily rewires your brain for happiness.', content: '# Gratitude Journaling\n\n3 things daily:\n- +25% happiness\n- Better sleep\n- Less depression\n- Stronger relationships\n\nJust 2 minutes!', readTime: 1),
      ContentItem(id: 'tip_5', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFFE91E63), icon: Icons.accessibility_new, title: 'Power Posing', excerpt: 'Stand like a superhero for 2 min to boost confidence.', content: '# Power Posing\n\nHands on hips, chest open, 2 minutes.\n\n- Increases confidence\n- Decreases stress\n- Great before interviews', readTime: 1),
      ContentItem(id: 'tip_6', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF00BCD4), icon: Icons.water, title: 'Cold Water Face Splash', excerpt: 'Activate dive reflex to instantly reduce anxiety.', content: '# Cold Water Technique\n\nSplash cold water on face or hold ice.\n\n- Slows heart rate instantly\n- Reduces anxiety in seconds\n- Works during panic attacks', readTime: 1),
      ContentItem(id: 'tip_7', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFFFF9800), icon: Icons.mood, title: 'Laugh for 60 Seconds', excerpt: 'Fake → real laughter floods body with endorphins.', content: '# Laughter Medicine\n\nFake laugh for 60s — it becomes real!\n\n- Releases endorphins\n- Reduces stress hormones\n- Boosts immunity', readTime: 1),
      ContentItem(id: 'tip_8', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF607D8B), icon: Icons.timer, title: 'The 2-Minute Rule', excerpt: 'If it takes <2 min, do it now.', content: '# 2-Minute Rule\n\nIf something takes less than 2 minutes, do it immediately.\n\nReduces mental clutter and procrastination anxiety.', readTime: 1),
      ContentItem(id: 'tip_9', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF4CAF50), icon: Icons.nature, title: '5-Minute Nature Break', excerpt: 'Step outside for 5 min to reset your nervous system.', content: '# Nature Break\n\n5 minutes outdoors:\n- Lowers cortisol\n- Improves mood\n- Boosts creativity\n- Reduces fatigue', readTime: 1),
      ContentItem(id: 'tip_10', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF673AB7), icon: Icons.directions_walk, title: 'Quick Muscle Relaxation', excerpt: 'Tense and release muscles to melt stress.', content: '# Quick PMR\n\n1. Clench fists 5s → release\n2. Shrug shoulders 5s → release\n3. Scrunch face 5s → release\n\nInstant tension relief!', readTime: 2),
      ContentItem(id: 'tip_11', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFFFF5722), icon: Icons.record_voice_over, title: 'Morning Affirmation', excerpt: 'One powerful statement to start your day.', content: '# Morning Affirmation\n\n"I am capable, worthy, and today is full of possibilities."\n\n10 seconds to set a positive tone.', readTime: 1),
      ContentItem(id: 'tip_12', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF2196F3), icon: Icons.local_drink, title: 'Hydration Check', excerpt: 'Dehydration causes fatigue, anxiety, and brain fog.', content: '# Stay Hydrated\n\nEven 1-2% dehydration affects mood.\n\n- Water first thing AM\n- Keep bottle visible\n- 8 glasses daily', readTime: 1),
      ContentItem(id: 'tip_13', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF8BC34A), icon: Icons.self_improvement, title: '1-Minute Body Scan', excerpt: 'Quick check-in to locate hidden tension.', content: '# Quick Body Scan\n\n60 seconds:\n1. Forehead → relax\n2. Jaw → unclench\n3. Shoulders → drop\n4. Hands → open\n5. Deep breath', readTime: 1),
      ContentItem(id: 'tip_14', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFFE91E63), icon: Icons.volunteer_activism, title: 'Random Act of Kindness', excerpt: 'Kindness boosts YOUR happiness more than the receiver.', content: '# Kindness Boost\n\nOne act today: compliment, help, appreciate.\n\nReleases oxytocin — the "love hormone."', readTime: 1),
      ContentItem(id: 'tip_15', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF9C27B0), icon: Icons.nightlight, title: 'Digital Sunset', excerpt: 'No screens 1 hour before bed = dramatically better sleep.', content: '# Digital Sunset\n\n1 hour before bed, no screens.\n\nReplace with: reading, stretching, journaling.', readTime: 1),
      ContentItem(id: 'tip_16', type: ContentType.tip, category: 'Quick Tip', categoryColor: const Color(0xFF00BCD4), icon: Icons.edit_note, title: 'Brain Dump Journal', excerpt: 'Write everything on your mind for 5 min to clear clutter.', content: '# Brain Dump\n\n5-minute timer. Write EVERYTHING — no filter.\n\nReduces anxiety. Clears working memory. Best before bed.', readTime: 1),
    ];
  }
}

// Content Detail Screen — also theme-aware with ZenAuraBackground
class ContentDetailScreen extends StatelessWidget {
  final ContentItem item;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const ContentDetailScreen({
    super.key,
    required this.item,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(item.category, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5)),
            onPressed: onBookmarkToggle,
          ),
        ],
      ),
      body: ZenAuraBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [item.categoryColor, item.categoryColor.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: item.categoryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(item.icon, color: Colors.white, size: 28)),
                    const SizedBox(height: 16),
                    Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
                    const SizedBox(height: 8),
                    Text(item.excerpt, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text('${item.readTime} min read', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 10),
                        Text('by ${item.author}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Content
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Text(
                  item.content,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.85), fontSize: 16, height: 1.8, letterSpacing: 0.2),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

enum ContentType { article, tip }

class ContentItem {
  final String id;
  final ContentType type;
  final String category;
  final Color categoryColor;
  final IconData icon;
  final String title;
  final String excerpt;
  final String content;
  final int readTime;
  final String? imageUrl;
  final String author;
  final String description;

  ContentItem({
    required this.id,
    required this.type,
    required this.category,
    required this.categoryColor,
    required this.icon,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.readTime,
    this.imageUrl,
    this.author = 'Saathi Team',
    String? description,
  }) : description = description ?? excerpt;
}
