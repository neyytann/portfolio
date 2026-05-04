import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onViewProjects;
  final VoidCallback onContact;
  const HeroSection({super.key, required this.onViewProjects, required this.onContact});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  bool _showCard = false;
  bool _floatCard = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    )..forward();

    // Card appears after hero text is done — deferred, not simultaneous
      Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) setState(() => _showCard = true);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _floatCard = true);
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 900;
    final isMobile = w < 600;

    return RepaintBoundary(
      child: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        padding: EdgeInsets.fromLTRB(
          isMobile ? 24 : 80,
          isMobile ? 100 : 140,
          isMobile ? 24 : 80,
          60,
        ),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: _HeroText(fadeCtrl: _fadeCtrl, onViewProjects: widget.onViewProjects, onContact: widget.onContact, isMobile: isMobile)),
                  const SizedBox(width: 60),
                  Expanded(
                    flex: 4,
                    child: _showCard
                        ? RepaintBoundary(child: _FloatCard(animate: _floatCard))
                        : const SizedBox.shrink(),
                  ),
                ],
              )
            : _HeroText(fadeCtrl: _fadeCtrl, onViewProjects: widget.onViewProjects, onContact: widget.onContact, isMobile: isMobile),
      ),
    );
  }
}

// ── Hero text ─────────────────────────────────────────────────────────────────

class _HeroText extends StatelessWidget {
  final AnimationController fadeCtrl;
  final VoidCallback onViewProjects;
  final VoidCallback onContact;
  final bool isMobile;

  const _HeroText({
    required this.fadeCtrl,
    required this.onViewProjects,
    required this.onContact,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TypewriterText(
          text: "Hi, my name is",
          style: AppTheme.mono(color: AppColors.accent, size: 14),
          delay: Duration.zero,
        ),
        const SizedBox(height: 20),
        _WordReveal(
          text: 'Nathaniel Velasco.',
          style: AppTheme.display(
            size: isMobile ? 42 : 68,
            color: AppColors.textLight,
            weight: FontWeight.w700,
            height: 1.05,
          ),
          delay: const Duration(milliseconds: 600),
        ),
        const SizedBox(height: 10),
        _WordReveal(
          text: 'Building robust backend systems.',
          style: AppTheme.display(
            size: isMobile ? 28 : 50,
            color: AppColors.textMuted,
            weight: FontWeight.w700,
            height: 1.1,
          ),
          delay: const Duration(milliseconds: 1100),
        ),
        const SizedBox(height: 28),
        _FadeSlideIn(
          delay: const Duration(milliseconds: 1600),
          child: Text(
            "I'm a backend developer specializing in building reliable, scalable, "
            "and efficient server-side systems. I focus on designing APIs, managing "
            "databases, and implementing the core logic that powers seamless digital experiences.",
            style: AppTheme.sans(
              size: isMobile ? 15 : 16,
              color: AppColors.textMuted,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _FadeSlideIn(
          delay: const Duration(milliseconds: 1900),
          child: Wrap(spacing: 16, runSpacing: 12, children: [
            _CTAButton(label: "Check out my work!", onTap: onViewProjects, filled: true),
            _CTAButton(label: "Get In Touch", onTap: onContact, filled: false),
          ]),
        ),
        const SizedBox(height: 40),
        _FadeSlideIn(
          delay: const Duration(milliseconds: 2100),
          child: _SocialRow(),
        ),
      ],
    );
  }
}

// ── Typewriter ────────────────────────────────────────────────────────────────

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  const _TypewriterText({required this.text, required this.style, required this.delay});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, _type);
  }

  void _type() async {
    for (int i = 1; i <= widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 55));
      if (!mounted) return;
      setState(() => _count = i);
    }
  }

  @override
  Widget build(BuildContext context) => Text(
    widget.text.substring(0, _count),
    style: widget.style,
  );
}

// ── Word reveal ───────────────────────────────────────────────────────────────

class _WordReveal extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  const _WordReveal({required this.text, required this.style, required this.delay});

  @override
  State<_WordReveal> createState() => _WordRevealState();
}

class _WordRevealState extends State<_WordReveal> with TickerProviderStateMixin {
  final List<AnimationController> _ctrls = [];
  final List<Animation<double>> _opacities = [];
  final List<Animation<Offset>> _slides = [];
  late List<String> _words;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    for (int i = 0; i < _words.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _opacities.add(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
      _slides.add(
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)),
      );
      _ctrls.add(ctrl);
    }
    _animate();
  }

  void _animate() async {
    await Future.delayed(widget.delay);
    for (int i = 0; i < _ctrls.length; i++) {
      if (!mounted) return;
      _ctrls[i].forward();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(_words.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FadeTransition(
            opacity: _opacities[i],
            child: SlideTransition(
              position: _slides[i],
              child: Text(_words[i], style: widget.style),
            ),
          ),
        );
      }),
    );
  }
}

// ── Fade slide in block ───────────────────────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeSlideIn({required this.child, required this.delay});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ── Float card — only mounted after hero fades in ─────────────────────────────

class _FloatCard extends StatefulWidget {
  final bool animate;
  const _FloatCard({required this.animate});

  @override
  State<_FloatCard> createState() => _FloatCardState();
}

// Replace _FloatCardState with this:
class _FloatCardState extends State<_FloatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_FloatCard old) {
    super.didUpdateWidget(old);
    if (widget.animate && !old.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: const _CodeCard(),
    );
  }
}

// ── Code card — const, no state ───────────────────────────────────────────────

class _CodeCard extends StatelessWidget {
  const _CodeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.06),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              _dot(const Color(0xFFFF5F57)),
              const SizedBox(width: 6),
              _dot(const Color(0xFFFFBD2E)),
              const SizedBox(width: 6),
              _dot(const Color(0xFF28C840)),
              const SizedBox(width: 16),
              Text('nathaniel.dart', style: AppTheme.mono(color: AppColors.textMuted, size: 11)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line([_s('// about me', AppColors.textMuted.withOpacity(0.5))]),
                const SizedBox(height: 8),
                _line([_s('const ', const Color(0xFF569CD6)), _s('dev ', AppColors.text), _s('= {', AppColors.textMuted)]),
                const SizedBox(height: 5),
                _line([_s('  name: ', const Color(0xFF9CDCFE)), _s("'Nathaniel Velasco'", const Color(0xFFCE9178)), _s(',', AppColors.textMuted)]),
                const SizedBox(height: 4),
                _line([_s('  role: ', const Color(0xFF9CDCFE)), _s("'Backend Dev'", const Color(0xFFCE9178)), _s(',', AppColors.textMuted)]),
                const SizedBox(height: 4),
                _line([_s('  location: ', const Color(0xFF9CDCFE)), _s("'Philippines'", const Color(0xFFCE9178)), _s(',', AppColors.textMuted)]),
                const SizedBox(height: 5),
                _line([_s('  stack: ', const Color(0xFF9CDCFE)), _s('[', AppColors.textMuted)]),
                ...['Flutter', 'Go', 'Java', 'PostgreSQL'].map((s) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: _line([_s('    ', AppColors.text), _s("'$s'", const Color(0xFFCE9178)), _s(',', AppColors.textMuted)]),
                  ),
                ),
                _line([_s('  ],', AppColors.textMuted)]),
                const SizedBox(height: 5),
                _line([_s('  available: ', const Color(0xFF9CDCFE)), _s('true', const Color(0xFF569CD6)), _s(',', AppColors.textMuted)]),
                const SizedBox(height: 5),
                _line([_s('};', AppColors.textMuted)]),
                const SizedBox(height: 14),
                Row(children: [
                  Text('▶ ', style: AppTheme.mono(color: AppColors.accent, size: 12)),
                  Text('node nathaniel.dart', style: AppTheme.mono(color: AppColors.textMuted, size: 11)),
                  const SizedBox(width: 4),
                  const _BlinkingCursor(),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 12, height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _line(List<TextSpan> spans) => RichText(text: TextSpan(children: spans));

  TextSpan _s(String text, Color color) =>
      TextSpan(text: text, style: AppTheme.mono(color: color, size: 12));
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 530))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _ctrl,
    child: Container(width: 7, height: 13, color: AppColors.accent),
  );
}

// ── Social row ────────────────────────────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _SocialLink(label: 'GitHub', url: 'https://github.com/neyytann'),
      const SizedBox(width: 20),
      _SocialLink(label: 'LinkedIn', url: 'https://linkedin.com/in/yourname'),
      const SizedBox(width: 20),
      _SocialLink(label: 'Twitter', url: 'https://twitter.com/yourhandle'),
      const SizedBox(width: 20),
      Container(width: 80, height: 1, color: AppColors.border),
    ]);
  }
}

class _SocialLink extends StatefulWidget {
  final String label;
  final String url;
  const _SocialLink({required this.label, required this.url});
  @override
  State<_SocialLink> createState() => _SocialLinkState();
}

class _SocialLinkState extends State<_SocialLink> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: () async {
        final uri = Uri.parse(widget.url);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        child: Text(widget.label,
            style: AppTheme.mono(color: _hover ? AppColors.accent : AppColors.textMuted, size: 12)),
      ),
    ),
  );
}

// ── CTA Button ────────────────────────────────────────────────────────────────

class _CTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _CTAButton({required this.label, required this.onTap, required this.filled});
  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: widget.filled
              ? (_hover ? AppColors.accent.withOpacity(0.85) : AppColors.accent)
              : (_hover ? AppColors.accentLight : Colors.transparent),
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.label,
          style: AppTheme.mono(
            color: widget.filled ? AppColors.bg : AppColors.accent,
            size: 13,
            weight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}