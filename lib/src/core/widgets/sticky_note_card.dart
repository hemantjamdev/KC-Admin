import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aesthetic Post-It Sticky Note Widget for Stitching Notes & Special Instructions.
/// Styled with pastel yellow paper gradient, subtle tape accent, and warm charcoal typography.
class StickyNoteCard extends StatelessWidget {
  const StickyNoteCard({
    super.key,
    required this.note,
    this.title = 'Stitching Note',
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 16),
  });

  final String note;
  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (note.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Sticky Note Body Container
          Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFFDE7), // Soft pastel yellow
                  Color(0xFFFFF59D), // Warm post-it yellow
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16), // Paper curl corner
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(3, 5),
                ),
                BoxShadow(
                  color: const Color(0xFFD4E157).withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(-1, -1),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFBC02D).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.sticky_note_2_rounded,
                      size: 16,
                      color: Color(0xFF5D4037),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),

          // Translucent Tape Accent at top center
          Positioned(
            top: -8,
            child: Transform.rotate(
              angle: -0.04,
              child: Container(
                width: 64,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.yellow.shade700.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
