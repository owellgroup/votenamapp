import 'package:flutter/cupertino.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VotenamApp());
}

class VotenamApp extends StatelessWidget {
  const VotenamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Namibia Voting System',
      theme: CupertinoThemeData(
        primaryColor: Color(0xFF2E7D32), // Green instead of blue
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
