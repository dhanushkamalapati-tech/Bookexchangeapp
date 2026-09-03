import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BookExchangeApp());
}

class BookExchangeApp extends StatelessWidget {
  const BookExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Exchange App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E5D50),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _rememberMe = false;
  String? _formMessage;

  static const _rememberMeKey = 'remember_me';

  @override
  void initState() {
    super.initState();
    _loadRememberedPreference();
  }

  Future<void> _loadRememberedPreference() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _rememberMe = preferences.getBool(_rememberMeKey) ?? false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openHome() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _formMessage = null);
      return;
    }
    _saveRememberedPreference();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _saveRememberedPreference() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberMeKey, _rememberMe);
  }

  void _continueAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _formMessage = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _showPasswordReset() async {
    final controller = TextEditingController(text: _emailController.text);
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Send reset link'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || email == null || email.isEmpty) return;
    setState(() => _formMessage = 'Reset instructions sent to $email.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF234B42),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6D6A7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Color(0xFF234B42),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Leaf & Lore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 46),
              const Text(
                'A good book\nfinds its person.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  height: 1.02,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Trade the stories that shaped you\nand discover what comes next.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 16,
                  height: 1.35,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRegistering ? 'Join the exchange' : 'Welcome back',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _isRegistering
                          ? 'Create a profile for your reading circle.'
                          : 'Sign in to your reading circle.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontFamily: 'sans-serif',
                      ),
                    ),
                    const SizedBox(height: 22),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_isRegistering) ...[
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Your name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: _isRegistering
                                  ? 'Create a password'
                                  : 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.length < 6
                                ? 'Use at least 6 characters'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if (!_isRegistering)
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? false),
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _showPasswordReset,
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                    if (_formMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _formMessage!,
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _openHome,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          _isRegistering
                              ? 'Create my account'
                              : 'Enter the exchange',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _continueAsGuest,
                        child: const Text('Continue as guest'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _isRegistering ? 'Already a member? ' : 'New here? ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        fontFamily: 'sans-serif',
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isRegistering ? 'Sign in' : 'Create an account',
                      ),
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
}

class BookInfo {
  const BookInfo({
    required this.title,
    required this.author,
    required this.category,
    required this.summary,
    required this.color,
    required this.distance,
  });

  final String title;
  final String author;
  final String category;
  final String summary;
  final Color color;
  final String distance;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedCategory = 'For you';
  String _profileName = 'Alex Reader';
  String _location = 'Your neighborhood';
  String _searchQuery = '';
  bool _exchangeNotifications = true;
  bool _messageNotifications = true;
  final Set<String> _savedTitles = {
    'The Seven Husbands of Evelyn Hugo',
    'Tomorrow, and Tomorrow, and Tomorrow',
    'Educated',
  };

  static const _books = [
    BookInfo(
      title: 'Tomorrow, and Tomorrow, and Tomorrow',
      author: 'Gabrielle Zevin',
      category: 'Fiction',
      summary:
          'A moving story about friendship, creativity, and the games we play.',
      color: Color(0xFFD98964),
      distance: '0.8 mi away',
    ),
    BookInfo(
      title: 'Pachinko',
      author: 'Min Jin Lee',
      category: 'Fiction',
      summary: 'An epic family story shaped by love, identity, and resilience.',
      color: Color(0xFF6D8FB0),
      distance: '1.2 mi away',
    ),
    BookInfo(
      title: 'The Seven Husbands of Evelyn Hugo',
      author: 'Taylor Jenkins Reid',
      category: 'Romance',
      summary:
          'A legendary actress finally tells the truth behind her extraordinary life.',
      color: Color(0xFFB18A9D),
      distance: '1.7 mi away',
    ),
    BookInfo(
      title: 'Educated',
      author: 'Tara Westover',
      category: 'Non-fiction',
      summary:
          'A powerful memoir about learning to see the world for yourself.',
      color: Color(0xFF7A9B82),
      distance: '2.1 mi away',
    ),
    BookInfo(
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      category: 'Mystery',
      summary:
          'A celebrated painter stops speaking after a shocking act of violence.',
      color: Color(0xFF7C849B),
      distance: '0.5 mi away',
    ),
    BookInfo(
      title: 'The Thursday Murder Club',
      author: 'Richard Osman',
      category: 'Mystery',
      summary:
          'Four friends investigate a case that lands much closer than expected.',
      color: Color(0xFFC29A68),
      distance: '2.4 mi away',
    ),
    BookInfo(
      title: 'The Night Circus',
      author: 'Erin Morgenstern',
      category: 'For you',
      summary:
          'A mysterious circus arrives at night, full of impossible wonders.',
      color: Color(0xFF344E5C),
      distance: '1.1 mi away',
    ),
    BookInfo(
      title: 'A Man Called Ove',
      author: 'Fredrik Backman',
      category: 'For you',
      summary:
          'A warm, funny reminder that unexpected friendships can change everything.',
      color: Color(0xFFB97865),
      distance: '1.9 mi away',
    ),
    BookInfo(
      title: 'Beach Read',
      author: 'Emily Henry',
      category: 'Romance',
      summary:
          'Two writers discover that a creative rivalry can become something more.',
      color: Color(0xFFE0A177),
      distance: '2.8 mi away',
    ),
    BookInfo(
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Non-fiction',
      summary:
          'A practical guide to building better habits through small changes.',
      color: Color(0xFF7996A8),
      distance: '3.0 mi away',
    ),
    BookInfo(
      title: 'The House in the Cerulean Sea',
      author: 'TJ Klune',
      category: 'For you',
      summary:
          'A gentle fantasy about finding home in the most unexpected place.',
      color: Color(0xFF6C9A91),
      distance: '1.5 mi away',
    ),
    BookInfo(
      title: 'The Maid',
      author: 'Nita Prose',
      category: 'Mystery',
      summary:
          'An observant hotel maid finds herself at the center of a mystery.',
      color: Color(0xFFA58D78),
      distance: '2.6 mi away',
    ),
  ];

  List<BookInfo> get _visibleBooks {
    final query = _searchQuery.toLowerCase();
    return _books.where((book) {
      final categoryMatches =
          _selectedCategory == 'For you' || book.category == _selectedCategory;
      final searchMatches =
          query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      return categoryMatches && searchMatches;
    }).toList();
  }

  void _showBookDetails(String title, String author) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(
          '$author\n\nAvailable for exchange near you. Add it to your saved shelf or start an exchange request.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _savedTitles.add(title.replaceAll('\n', ' ')));
              Navigator.pop(dialogContext);
              _showMessage('$title saved to your shelf.');
            },
            child: const Text('Save book'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showFilters() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Filter your shelf'),
        children: ['For you', 'Fiction', 'Mystery', 'Romance', 'Non-fiction']
            .map(
              (category) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, category),
                child: Row(
                  children: [
                    Icon(
                      category == _selectedCategory
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: const Color(0xFF2E5D50),
                    ),
                    const SizedBox(width: 10),
                    Text(category),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) setState(() => _selectedCategory = selected);
  }

  Future<void> _editProfile() async {
    final controller = TextEditingController(text: _profileName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty) setState(() => _profileName = name);
  }

  Future<void> _editLocation() async {
    final controller = TextEditingController(text: _location);
    final location = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exchange location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Meetup area'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (location != null && location.isNotEmpty) {
      setState(() => _location = location);
    }
  }

  Future<void> _editNotifications() async {
    var exchange = _exchangeNotifications;
    var messages = _messageNotifications;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Exchange updates'),
                value: exchange,
                onChanged: (value) => setDialogState(() => exchange = value),
              ),
              SwitchListTile(
                title: const Text('Messages'),
                value: messages,
                onChanged: (value) => setDialogState(() => messages = value),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                setState(() {
                  _exchangeNotifications = exchange;
                  _messageNotifications = messages;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildCurrentView()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Exchanges',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 1:
        return _buildExchangesView();
      case 2:
        return _buildSavedView();
      case 3:
        return _buildProfileView();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildHomeView() => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildHeader()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildSearch()),
      ),
      if (_searchQuery.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
          sliver: SliverToBoxAdapter(child: _buildSearchResult()),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildSectionTitle()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 14, 0, 0),
        sliver: SliverToBoxAdapter(child: _buildCategories()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildMoodInsight()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildFeaturedBanner()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildShelfStatus()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildStats()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
        sliver: SliverToBoxAdapter(child: _buildCommunityPulse()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 110),
        sliver: SliverToBoxAdapter(child: _buildRecentSection()),
      ),
    ],
  );

  Widget _buildPageHeader(String title, String subtitle, IconData icon) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: const Color(0xFFD9E8DF),
              child: Icon(icon, color: const Color(0xFF2E5D50)),
            ),
          ],
        ),
      );

  Widget _buildExchangesView() => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: _buildPageHeader(
          'My exchanges',
          'Keep every handoff in one place.',
          Icons.swap_horiz,
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 120),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildExchangeCard(
              'The Midnight Library',
              'Pickup with Maya',
              'Ready for pickup',
              const Color(0xFFE5EFE8),
              Icons.schedule,
            ),
            const SizedBox(height: 14),
            _buildExchangeCard(
              'Pachinko',
              'Waiting for a reading buddy',
              'Request sent',
              const Color(0xFFE8EEF4),
              Icons.hourglass_top,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => _selectedIndex = 0),
              icon: const Icon(Icons.add),
              label: const Text('Find another book'),
            ),
          ]),
        ),
      ),
    ],
  );

  Widget _buildExchangeCard(
    String title,
    String detail,
    String status,
    Color color,
    IconData icon,
  ) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Container(
          height: 62,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2E5D50),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.menu_book,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(icon, size: 15, color: const Color(0xFF2E5D50)),
                  const SizedBox(width: 5),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSavedView() => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: _buildPageHeader(
          'Saved shelf',
          'Books waiting for the right moment.',
          Icons.bookmark,
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            if (_savedTitles.contains('The Seven Husbands of Evelyn Hugo'))
              SavedBookRow(
                title: 'The Seven Husbands of Evelyn Hugo',
                author: 'Taylor Jenkins Reid',
                color: const Color(0xFFB18A9D),
                onRemove: () => setState(
                  () =>
                      _savedTitles.remove('The Seven Husbands of Evelyn Hugo'),
                ),
              ),
            const SizedBox(height: 12),
            if (_savedTitles.contains('Tomorrow, and Tomorrow, and Tomorrow'))
              SavedBookRow(
                title: 'Tomorrow, and Tomorrow, and Tomorrow',
                author: 'Gabrielle Zevin',
                color: const Color(0xFFD98964),
                onRemove: () => setState(
                  () => _savedTitles.remove(
                    'Tomorrow, and Tomorrow, and Tomorrow',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (_savedTitles.contains('Educated'))
              SavedBookRow(
                title: 'Educated',
                author: 'Tara Westover',
                color: const Color(0xFF7A9B82),
                onRemove: () => setState(() => _savedTitles.remove('Educated')),
              ),
          ]),
        ),
      ),
    ],
  );

  Widget _buildProfileView() => ListView(
    padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
    children: [
      _buildPageHeader(
        'Your profile',
        'Make your reading circle yours.',
        Icons.person,
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFE8),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 31,
              backgroundColor: Color(0xFFD9E8DF),
              child: Icon(Icons.person, size: 35, color: Color(0xFF2E5D50)),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileName,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '12 books in your story',
                  style: TextStyle(fontSize: 13, fontFamily: 'sans-serif'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _buildProfileAction(
        Icons.edit_outlined,
        'Edit profile',
        'Update your reading details.',
        _editProfile,
      ),
      _buildProfileAction(
        Icons.location_on_outlined,
        'Exchange location',
        _location,
        _editLocation,
      ),
      _buildProfileAction(
        Icons.notifications_none,
        'Notifications',
        'Choose what you want to hear about.',
        _editNotifications,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Sign out'),
      ),
    ],
  );

  Widget _buildProfileAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 5),
    leading: CircleAvatar(
      backgroundColor: const Color(0xFFE8EEE9),
      child: Icon(icon, color: const Color(0xFF2E5D50)),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontFamily: 'sans-serif', fontSize: 12),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );

  Widget _buildHeader() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Alex',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: 'sans-serif',
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Find your next\nfavorite read.',
              style: TextStyle(
                fontSize: 30,
                height: 1.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFFD9E8DF),
        child: IconButton(
          tooltip: 'Open profile',
          onPressed: () => setState(() => _selectedIndex = 3),
          icon: Icon(Icons.person, color: Colors.teal.shade800, size: 28),
        ),
      ),
    ],
  );

  Widget _buildSearch() => TextField(
    onSubmitted: (query) {
      setState(() => _searchQuery = query.trim());
    },
    decoration: InputDecoration(
      hintText: 'Search books, authors, or ISBN',
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 14,
        fontFamily: 'sans-serif',
      ),
      prefixIcon: const Icon(Icons.search, color: Color(0xFF2E5D50)),
      suffixIcon: IconButton(
        tooltip: 'Filter books',
        onPressed: _showFilters,
        icon: const Icon(Icons.tune, size: 20),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildSearchResult() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE5EFE8),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.search, color: Color(0xFF2E5D50)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Showing books matching “$_searchQuery”',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
        ),
        IconButton(
          tooltip: 'Clear search',
          onPressed: () => setState(() => _searchQuery = ''),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );

  Widget _buildSectionTitle() => const Text(
    'Browse by mood',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );

  Widget _buildMoodInsight() {
    final details = {
      'For you': (
        'A little bit of everything',
        '12 fresh picks matched to your reading rhythm.',
        Icons.auto_awesome,
      ),
      'Fiction': (
        'Lose yourself in a story',
        'Stories with big worlds and even bigger feelings.',
        Icons.auto_stories,
      ),
      'Mystery': (
        'Follow the clues',
        'Page-turners from quiet suspense to wild twists.',
        Icons.search,
      ),
      'Romance': (
        'Stay for the feeling',
        'Tender stories with characters worth rooting for.',
        Icons.favorite_border,
      ),
      'Non-fiction': (
        'Read something real',
        'Ideas, lives, and lessons to take with you.',
        Icons.lightbulb_outline,
      ),
    }[_selectedCategory]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBDD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3D9BF)),
      ),
      child: Row(
        children: [
          Icon(details.$3, color: const Color(0xFF846C3D), size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details.$2,
                  style: TextStyle(
                    color: Colors.brown.shade600,
                    fontSize: 12,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      'For you',
      'Fiction',
      'Mystery',
      'Romance',
      'Non-fiction',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF52605A),
                fontFamily: 'sans-serif',
                fontWeight: FontWeight.w600,
              ),
              selectedColor: const Color(0xFF2E5D50),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedBanner() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFE5EFE8),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEEKLY PICK',
                style: TextStyle(
                  color: Colors.teal.shade800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'The Midnight\nLibrary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'A little magic for your TBR.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 15),
              FilledButton.tonal(
                onPressed: () {
                  setState(() => _savedTitles.add('The Midnight Library'));
                  _showBookDetails('The Midnight Library', 'Matt Haig');
                },
                child: const Text('Explore pick'),
              ),
            ],
          ),
        ),
        Container(
          height: 155,
          width: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF244B43),
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3322443B),
                blurRadius: 12,
                offset: Offset(4, 6),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nightlight_round, color: Color(0xFFE9D9A8), size: 31),
              SizedBox(height: 12),
              Text(
                'THE\nMIDNIGHT\nLIBRARY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'MATT HAIG',
                style: TextStyle(
                  color: Color(0xFFE9D9A8),
                  fontSize: 7,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildShelfStatus() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      color: const Color(0xFF2E5D50),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE9D9A8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.swap_horiz, color: Color(0xFF234B42)),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your exchange shelf',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '3 books ready to find a new reader',
                style: TextStyle(
                  color: Color(0xFFD6E5DC),
                  fontSize: 12,
                  fontFamily: 'sans-serif',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Open exchange shelf',
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 17,
          ),
        ),
      ],
    ),
  );

  Widget _buildRecentSection() {
    final books = _visibleBooks;
    final title = _searchQuery.isNotEmpty
        ? 'Search results'
        : _selectedCategory == 'For you'
        ? 'New near you'
        : '$_selectedCategory reads';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${books.length} books',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _searchQuery.isNotEmpty
              ? 'Curated from your search'
              : 'Ready to find a new reader nearby',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontFamily: 'sans-serif',
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 250,
          child: books.isEmpty
              ? Center(
                  child: Text(
                    'No books match this search yet.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(
                      title: book.title,
                      author: book.author,
                      color: book.color,
                      distance: book.distance,
                      onTap: () => _showBookDetails(book.title, book.author),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStats() => Row(
    children: const [
      Expanded(
        child: StatTile(
          value: '12',
          label: 'Books read',
          icon: Icons.menu_book_outlined,
          color: Color(0xFFD98964),
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: StatTile(
          value: '04',
          label: 'Exchanges',
          icon: Icons.swap_horizontal_circle_outlined,
          color: Color(0xFF6D8FB0),
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: StatTile(
          value: '08',
          label: 'Saved',
          icon: Icons.bookmark_border,
          color: Color(0xFFB18A9D),
        ),
      ),
    ],
  );

  Widget _buildCommunityPulse() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE6E4DC)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Around the corner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.near_me_outlined, color: Colors.teal.shade700, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFD9E8DF),
              child: Icon(Icons.person, color: Colors.teal.shade800),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Maya ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: 'just listed '),
                    TextSpan(
                      text: 'Educated',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' for exchange.'),
                  ],
                ),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.25,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
            const Text(
              '2m',
              style: TextStyle(
                color: Color(0xFF7B817C),
                fontSize: 12,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class BookCard extends StatelessWidget {
  const BookCard({
    required this.title,
    required this.author,
    required this.color,
    required this.distance,
    required this.onTap,
    super.key,
  });

  final String title;
  final String author;
  final Color color;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 168,
            width: 118,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title.replaceAll('\n', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            author,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            distance,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: 11,
              fontFamily: 'sans-serif',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class SavedBookRow extends StatelessWidget {
  const SavedBookRow({
    required this.title,
    required this.author,
    required this.color,
    required this.onRemove,
    super.key,
  });

  final String title;
  final String author;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE6E4DC)),
    ),
    child: Row(
      children: [
        Container(
          height: 72,
          width: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.menu_book, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                author,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontFamily: 'sans-serif',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Remove from saved shelf',
          onPressed: onRemove,
          icon: const Icon(Icons.bookmark, color: Color(0xFF2E5D50)),
        ),
      ],
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    super.key,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 14, 8, 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 9),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontFamily: 'sans-serif',
          ),
        ),
      ],
    ),
  );
}
