import 'package:flutter/material.dart';
import '../theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(text.split('.')[0] + '.', style: AppTheme.mono(color: AppColors.accent, size: 13)),
      const SizedBox(width: 10),
      Text(text.contains('.') ? text.split('.').sublist(1).join('.').trim() : '',
          style: AppTheme.display(size: 22, color: AppColors.textLight, weight: FontWeight.w600)),
      const SizedBox(width: 24),
      Expanded(child: Container(height: 1, color: AppColors.border)),
    ],
  );
}

class SectionHeading extends StatelessWidget {
  final String plain;
  final String accent;
  const SectionHeading({super.key, required this.plain, required this.accent});

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width < 600 ? 28.0 : 36.0;
    return RichText(
      text: TextSpan(
        style: AppTheme.display(size: fontSize, weight: FontWeight.w700, height: 1.1),
        children: [
          TextSpan(text: plain, style: TextStyle(color: AppColors.textLight)),
          TextSpan(text: accent, style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String label;
  const TagChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label,
            style: AppTheme.mono(color: AppColors.accent, size: 11, weight: FontWeight.w500)),
      );
}

class CardBox extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  const CardBox({super.key, required this.child, this.padding});

  @override
  State<CardBox> createState() => _CardBoxState();
}

class _CardBoxState extends State<CardBox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(
          color: _hover ? AppColors.accent.withOpacity(0.4) : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: _hover ? [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 1,
          )
        ] : [],
      ),
        child: widget.child,
    ),
  );
}

class Divider2 extends StatelessWidget {
  const Divider2({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
