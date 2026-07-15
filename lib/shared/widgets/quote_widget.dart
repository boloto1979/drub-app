import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';

class QuoteWidget extends ConsumerWidget {
  const QuoteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);

    return Text(
      s.dharmaQuote,
      style: GoogleFonts.cormorantGaramond(
        color: Colors.white.withValues(alpha: 0.82),
        fontSize: 15,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
        height: 1.75,
      ),
    );
  }
}
