import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../data/lama_quotes.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  late int _index;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _index =
        (now.year * 366 + now.month * 31 + now.day) % lamaQuotes.length;
  }

  void _next() {
    setState(() => _index = (_index + 1) % lamaQuotes.length);
  }

  @override
  Widget build(BuildContext context) {
    final quote = lamaQuotes[_index];

    return GestureDetector(
      onTap: _next,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“${quote.text}”',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 18,
                height: 1,
                color: AppColors.goldLight.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                quote.author,
                style: GoogleFonts.raleway(
                  color: AppColors.goldLight.withValues(alpha: 0.65),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
