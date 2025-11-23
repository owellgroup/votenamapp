import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';
import '../models/vote_category.dart';
import 'candidates_screen.dart';

class VoteCategoriesScreen extends StatefulWidget {
  const VoteCategoriesScreen({super.key});

  @override
  State<VoteCategoriesScreen> createState() => _VoteCategoriesScreenState();
}

class _VoteCategoriesScreenState extends State<VoteCategoriesScreen> {
  List<VoteCategory> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final loadedCategories = await ApiService.getVoteCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Available Votes'),
        backgroundColor: CupertinoColors.white,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: loadCategories,
          child: const Icon(CupertinoIcons.arrow_clockwise),
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(padding * 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: isSmallScreen ? 50 : 60,
                            color: CupertinoColors.systemRed,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          Text(
                            'Error loading categories',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: padding * 2),
                            child: Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 30),
                          CupertinoButton.filled(
                            onPressed: loadCategories,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.bell_slash,
                              size: isSmallScreen ? 50 : 60,
                              color: CupertinoColors.secondaryLabel,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Text(
                              'No voting categories available',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(padding),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryCard(context, category);
                        },
                      ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, VoteCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final iconSize = isSmallScreen ? 40.0 : 50.0;
    final iconInnerSize = isSmallScreen ? 24.0 : 28.0;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final spacing = isSmallScreen ? 12.0 : 16.0;
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleSize = isSmallScreen ? 12.0 : 14.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.all(padding),
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => CandidatesScreen(
                voteCategory: category,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: const Color(0xFF41479B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: const Color(0xFF41479B),
                size: iconInnerSize,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'Tap to view candidates',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.secondaryLabel,
              size: isSmallScreen ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }
}

