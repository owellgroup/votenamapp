import 'package:flutter/cupertino.dart';
import '../widgets/votenam_logo.dart';
import 'vote_categories_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final logoSize = isSmallScreen ? 200.0 : 250.0;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final spacing = isSmallScreen ? 20.0 : 30.0;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                VotenamLogo(
                  width: logoSize,
                  height: logoSize,
                ),
                SizedBox(height: spacing),
                
                // Vote Now Button
                _buildActionButton(
                  context: context,
                  title: 'Vote Now',
                  icon: CupertinoIcons.check_mark_circled_solid,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const VoteCategoriesScreen(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Results Button
                _buildActionButton(
                  context: context,
                  title: 'Results',
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const ResultsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;
    final verticalPadding = isSmallScreen ? 12.0 : 14.0;
    const color = Color(0xFF41479B);
    
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: CupertinoColors.white,
              size: iconSize,
            ),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

