import 'package:flutter/cupertino.dart';

class VotenamLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const VotenamLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logovotenam.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}

