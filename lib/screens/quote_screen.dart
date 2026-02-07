import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/api_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with SingleTickerProviderStateMixin {
  String quote = "Loading wisdom...";
  String author = "";
  bool _isLoading = false;
  bool _showAuthor = false;
  bool _showCopiedMessage = false;
  bool _showFavoritedMessage = false;
  bool _showSharedMessage = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  // Store favorite quotes
  final List<Map<String, String>> _favoriteQuotes = [];
  final List<String> _favoriteIds = [];

  // Enhanced color palette with more vibrant gradients
  final List<List<Color>> _gradientSets = [
    // Vibrant teal to purple
    [const Color(0xFF00D2FF), const Color(0xFF3A7BD5), const Color(0xFF9D50BB)],
    // Deep ocean blues
    [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
    // Purple to pink
    [const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)],
    // Turquoise gradient
    [const Color(0xFF11998E), const Color(0xFF38EF7D), const Color(0xFF64FFDA)],
    // Royal blue to purple
    [const Color(0xFF141E30), const Color(0xFF243B55), const Color(0xFF8A2BE2)],
  ];

  // Vibrant accent colors
  final Color _vibrantTurquoise = const Color(0xFF00F5FF);
  final Color _electricPurple = const Color(0xFFB721FF);
  final Color _neonPink = const Color(0xFFFD1D1D);
  final Color _sunYellow = const Color(0xFFFFD700);

  List<Color> _currentGradient = [];
  int _currentGradientIndex = 0;
  String _currentQuoteId = '';

  @override
  void initState() {
    super.initState();

    // Initialize with vibrant gradient
    _currentGradient = _gradientSets[0];

    // Setup animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -0.003,
      end: 0.003,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fetch first quote
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getQuote();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Generate unique ID for quote
  String _generateQuoteId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  // Function to fetch quote from API
  Future<void> getQuote() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _showAuthor = false;
      _showCopiedMessage = false;
      _showFavoritedMessage = false;
      _showSharedMessage = false;
    });

    // Change to next vibrant gradient
    _currentGradientIndex = (_currentGradientIndex + 1) % _gradientSets.length;
    _currentGradient = _gradientSets[_currentGradientIndex];

    // Reset animation
    _controller.reset();

    try {
      final data = await ApiService.fetchRandomQuote();
      _currentQuoteId = _generateQuoteId();

      // Start animations
      _controller.forward();

      // Delay author reveal
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showAuthor = true;
          });
        }
      });

      setState(() {
        quote = data['content'] ?? "No quote available";
        author = data['author']?.split(',')[0] ?? "Unknown";
        _isLoading = false;
      });
    } catch (e) {
      _currentQuoteId = _generateQuoteId();
      setState(() {
        quote = "Even the wisest fall silent sometimes. Try again.";
        author = "Unknown";
        _isLoading = false;
        _showAuthor = true;
      });
      _controller.forward();
    }
  }

  // Share quote
  Future<void> _shareQuote() async {
    Clipboard.setData(ClipboardData(text: '"$quote"\n- $author'));

    setState(() {
      _showSharedMessage = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSharedMessage = false;
        });
      }
    });
  }

  // Copy quote to clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: '"$quote"\n- $author'));
    setState(() {
      _showCopiedMessage = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCopiedMessage = false;
        });
      }
    });
  }

  // Add/Remove from favorites
  void _toggleFavorite() {
    if (_currentQuoteId.isEmpty) return;

    if (_favoriteIds.contains(_currentQuoteId)) {
      // Remove from favorites
      _favoriteQuotes.removeWhere((q) => q['id'] == _currentQuoteId);
      _favoriteIds.remove(_currentQuoteId);
      setState(() {
        _showFavoritedMessage = false;
      });
    } else {
      // Add to favorites
      _favoriteQuotes.add({
        'id': _currentQuoteId,
        'quote': quote,
        'author': author,
        'date': DateTime.now().toIso8601String(),
      });
      _favoriteIds.add(_currentQuoteId);
      setState(() {
        _showFavoritedMessage = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showFavoritedMessage = false;
          });
        }
      });
    }
  }

  // Navigate to favorites screen
  void _showFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteQuotes: _favoriteQuotes,
          onRemoveFavorite: (id) {
            setState(() {
              _favoriteQuotes.removeWhere((q) => q['id'] == id);
              _favoriteIds.remove(id);
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuoteMark({bool left = true}) {
    return Transform.rotate(
      angle: left ? 0 : pi,
      child: Text(
        '❝',
        style: TextStyle(
          fontSize: 60,
          color: Colors.white.withOpacity(0.2),
          shadows: [
            Shadow(
              color: _vibrantTurquoise.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
    bool isActive = false,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [color, color.withOpacity(0.7)]
                  : [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? color : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? color.withOpacity(0.4)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isActive ? Colors.white : color, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.white : color.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Tooltip(message: tooltip, child: Container()),
      ],
    );
  }

  Widget _buildFeedbackMessage(String message, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorited = _favoriteIds.contains(_currentQuoteId);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _currentGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Menu button
                        _buildActionButton(
                          icon: Icons.menu,
                          label: '${_favoriteQuotes.length}',
                          tooltip: "View Favorites",
                          onTap: _showFavorites,
                          color: _electricPurple,
                          isActive: _favoriteQuotes.isNotEmpty,
                        ),

                        // Title
                        Column(
                          children: [
                            Text(
                              'QUOTE GENERATOR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: _vibrantTurquoise.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daily Dose of Wisdom',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),

                        // Settings button
                        _buildActionButton(
                          icon: Icons.bookmark,
                          label: 'Saved',
                          tooltip: "Favorites",
                          onTap: _showFavorites,
                          color: _sunYellow,
                          isActive: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Column(
                          children: [
                            // Quote Card
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: RotationTransition(
                                  turns: _rotationAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 40,
                                          offset: const Offset(0, 15),
                                        ),
                                        BoxShadow(
                                          color: _vibrantTurquoise.withOpacity(
                                            0.1,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Decorative quote marks
                                        Positioned(
                                          top: -20,
                                          left: -10,
                                          child: _buildQuoteMark(left: true),
                                        ),
                                        Positioned(
                                          bottom: -20,
                                          right: -10,
                                          child: _buildQuoteMark(left: false),
                                        ),

                                        Column(
                                          children: [
                                            // Quote Text
                                            Text(
                                              quote,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                height: 1.6,
                                                letterSpacing: 0.5,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),

                                            const SizedBox(height: 40),

                                            // Author
                                            if (author.isNotEmpty)
                                              AnimatedOpacity(
                                                opacity: _showAuthor
                                                    ? 1.0
                                                    : 0.0,
                                                duration: const Duration(
                                                  milliseconds: 800,
                                                ),
                                                curve: Curves.easeOut,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 16,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.15),
                                                        Colors.white
                                                            .withOpacity(0.05),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                    border: Border.all(
                                                      color: _vibrantTurquoise
                                                          .withOpacity(0.4),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        color: _vibrantTurquoise
                                                            .withOpacity(0.9),
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        author,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              _vibrantTurquoise
                                                                  .withOpacity(
                                                                    0.9,
                                                                  ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // NEW QUOTE BUTTON (MOVED ABOVE)
                            if (_isLoading)
                              Container(
                                width: 220,
                                height: 65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  border: Border.all(
                                    color: _vibrantTurquoise.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation(
                                        _vibrantTurquoise,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: getQuote,
                                child: Container(
                                  width: 220,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _vibrantTurquoise.withOpacity(0.8),
                                        _electricPurple.withOpacity(0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(35),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _vibrantTurquoise.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.autorenew,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        'NEW QUOTE',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 40),

                            // ACTION BUTTONS ROW (MOVED BELOW)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'QUOTE ACTIONS',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // Share Button
                                      _buildActionButton(
                                        icon: Icons.share,
                                        label: 'SHARE',
                                        tooltip: "Copy to share",
                                        onTap: _shareQuote,
                                        color: _vibrantTurquoise,
                                        isActive: false,
                                      ),

                                      // Copy Button
                                      _buildActionButton(
                                        icon: Icons.copy,
                                        label: 'COPY',
                                        tooltip: "Copy to clipboard",
                                        onTap: _copyToClipboard,
                                        color: _sunYellow,
                                        isActive: false,
                                      ),

                                      // Favorite Button
                                      _buildActionButton(
                                        icon: isFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        label: isFavorited ? 'SAVED' : 'SAVE',
                                        tooltip: isFavorited
                                            ? "Remove from favorites"
                                            : "Add to favorites",
                                        onTap: _toggleFavorite,
                                        color: _neonPink,
                                        isActive: isFavorited,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Feedback Messages
              if (_showCopiedMessage)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildFeedbackMessage(
                      "✓ Copied to clipboard!",
                      _sunYellow,
                    ),
                  ),
                ),

              if (_showFavoritedMessage)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildFeedbackMessage(
                      "✓ Added to favorites!",
                      _neonPink,
                    ),
                  ),
                ),

              if (_showSharedMessage)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildFeedbackMessage(
                      "✓ Ready to share!",
                      _vibrantTurquoise,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Favorites Screen (Keep as before)
class FavoritesScreen extends StatefulWidget {
  final List<Map<String, String>> favoriteQuotes;
  final Function(String) onRemoveFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteQuotes,
    required this.onRemoveFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Color _vibrantTurquoise = const Color(0xFF00F5FF);
  final Color _electricPurple = const Color(0xFFB721FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF1A1A2E),
              const Color(0xFF243B55),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: _vibrantTurquoise),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'My Favorite Quotes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _vibrantTurquoise,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.favoriteQuotes.length} saved',
                      style: TextStyle(
                        color: _vibrantTurquoise.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: widget.favoriteQuotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 70,
                              color: _vibrantTurquoise.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 20,
                                color: _vibrantTurquoise.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap the heart icon to save quotes',
                              style: TextStyle(
                                color: _vibrantTurquoise.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: widget.favoriteQuotes.length,
                        itemBuilder: (context, index) {
                          final quote = widget.favoriteQuotes[index];
                          return _buildFavoriteQuoteCard(quote, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteQuoteCard(Map<String, String> quote, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_vibrantTurquoise, _electricPurple],
                  ),
                  borderRadius: BorderRadius.circular(17.5),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  widget.onRemoveFavorite(quote['id']!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Removed from favorites'),
                      backgroundColor: _electricPurple,
                    ),
                  );
                },
                icon: Icon(Icons.favorite, color: _electricPurple, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '"${quote['quote']!}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(
                Icons.person,
                color: _vibrantTurquoise.withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                quote['author']!,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: _vibrantTurquoise.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              if (quote['date'] != null)
                Text(
                  _formatDate(quote['date']!),
                  style: TextStyle(
                    fontSize: 13,
                    color: _vibrantTurquoise.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
