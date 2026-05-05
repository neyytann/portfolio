import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/shared.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RevealNotifier extends ChangeNotifier {
  static final instance = RevealNotifier();
  void notify() => notifyListeners();
}

const _maxW = 960.0;

EdgeInsets _pad(BuildContext ctx) {
  final w = MediaQuery.of(ctx).size.width;
  return EdgeInsets.symmetric(
    horizontal: w < 600 ? 24 : (w < 900 ? 48 : 80),
    vertical: 100,
  );
}

Widget _constrained(Widget child) => Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: _maxW), child: child),
    );

// ── Scroll reveal ─────────────────────────────────────────────────────────────

class _ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _ScrollReveal({required this.child, this.delay = Duration.zero});

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _check();
      RevealNotifier.instance.addListener(_check);
    });
  }

  void _check() {
    if (!mounted) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final vh = MediaQuery.of(context).size.height;
    final inView = pos.dy < vh * 0.93 && pos.dy > -box.size.height;

    if (inView && !_ctrl.isAnimating && _ctrl.status != AnimationStatus.completed) {
      Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
    } else if (pos.dy >= vh * 0.93) {
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    RevealNotifier.instance.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: KeyedSubtree(key: _key, child: widget.child),
      ),
    ),
  );
}

// ── About ─────────────────────────────────────────────────────────────────────

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding: _pad(context),
      child: _constrained(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScrollReveal(child: const SectionLabel('01. About Me')),
          const SizedBox(height: 40),
          _ScrollReveal(
            delay: const Duration(milliseconds: 100),
            child: isMobile ? _mobileLayout() : _desktopLayout(),
          ),
        ],
      )),
    );
  }

  Widget _bio() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...[
        "Hello! I'm Nathaniel, a software developer based in the Philippines who enjoys building things that live on the internet.",
        "I work on a wide range of projects — from mobile apps to backend APIs — with a focus on writing clean, scalable code that solves real problems.",
        "When I'm not coding, I'm usually exploring new technologies, contributing to open source, or leveling up my system design skills.",
      ].asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          e.value,
          style: AppTheme.sans(color: AppColors.textMuted, size: 15, height: 1.75),
        ),
      )),
      const SizedBox(height: 16),
      Text("Technologies I've been working with recently:",
          style: AppTheme.sans(color: AppColors.text, size: 14, height: 1.6)),
      const SizedBox(height: 16),
      Wrap(
        spacing: 0,
        runSpacing: 0,
        children: [
          'Flutter', 'Dart', 'Go', 'C++', 'Java', 'PostgreSQL'
        ].map((t) => SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Text('▹ ', style: AppTheme.mono(color: AppColors.accent, size: 13)),
              Text(t, style: AppTheme.mono(color: AppColors.textMuted, size: 12)),
            ]),
          ),
        )).toList(),
      ),
    ],
  );

  Widget _avatar() => Container(
    width: 260,
    height: 260,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 2),
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.15),
          blurRadius: 32,
          spreadRadius: 2,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        'lib/assets/images/nathan.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppColors.bgCard),
      ),
    ),
  );

  Widget _desktopLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 3, child: _bio()),
      const SizedBox(width: 60),
      _avatar(),
    ],
  );

  Widget _mobileLayout() => Column(
    children: [
      _bio(),
      const SizedBox(height: 40),
      _avatar(),
    ],
  );
}

// ── Skills ────────────────────────────────────────────────────────────────────

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: _pad(context),
      child: _constrained(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScrollReveal(child: const SectionLabel('02. Skills')),
          const SizedBox(height: 12),
          _ScrollReveal(
            delay: const Duration(milliseconds: 60),
            child: Text(
              'Technologies & Tools',
              style: AppTheme.sans(color: AppColors.textMuted, size: 14, height: 1.6),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: isMobile ? 12 : 20,
            runSpacing: isMobile ? 12 : 20,
            children: skillGroups.asMap().entries.map((e) =>
              _ScrollReveal(
                delay: Duration(milliseconds: 80 + e.key * 70),
                child: _SkillCard(group: e.value),
              ),
            ).toList(),
          ),
        ],
      )),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillGroup group;
  const _SkillCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = w < 600 ? (w - 48).toDouble() : 220.0;
    return SizedBox(
      width: cardW,
      child: CardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('▹ ', style: AppTheme.mono(color: AppColors.accent, size: 14)),
              Text(group.category,
                  style: AppTheme.mono(color: AppColors.accent, size: 12, weight: FontWeight.w600)),
            ]),
            const SizedBox(height: 16),
            ...group.skills.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 4, height: 4,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(s, style: AppTheme.sans(size: 13, color: AppColors.textMuted)),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Projects ──────────────────────────────────────────────────────────────────

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _pad(context),
      child: _constrained(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScrollReveal(child: const SectionLabel('03. Projects')),
          const SizedBox(height: 8),
          _ScrollReveal(
            delay: const Duration(milliseconds: 60),
            child: Text(
              "Some Things I've Built",
              style: AppTheme.display(size: 28, color: AppColors.textMuted, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 48),
          ...projects.asMap().entries.map((e) =>
            _ScrollReveal(
              delay: Duration(milliseconds: 100 + e.key * 100),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _ProjectCard(project: e.value, index: e.key),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  const _ProjectCard({required this.project, required this.index});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _showImage = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return CardBox(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview — show/hide toggle
          if (widget.project.image.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _showImage = !_showImage),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _showImage ? (isMobile ? 180.0 : 240.0) : 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: _showImage
                        ? Image.asset(
                            widget.project.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.bgCard,
                              child: Center(
                                child: Text('No preview available',
                                    style: AppTheme.mono(
                                        color: AppColors.textMuted, size: 12)),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.folder_outlined, color: AppColors.accent, size: 36),
                    Row(children: [
                      // Preview toggle button
                      if (widget.project.image.isNotEmpty)
                        _ActionButton(
                          icon: _showImage ? Icons.visibility_off : Icons.visibility,
                          tooltip: _showImage ? 'Hide preview' : 'Show preview',
                          onTap: () => setState(() => _showImage = !_showImage),
                        ),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.project.name,
                  style: AppTheme.display(
                      size: 18, color: AppColors.textLight, weight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.project.description,
                  style: AppTheme.sans(size: 14, color: AppColors.textMuted, height: 1.7),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: widget.project.stack.map((t) => TagChip(t)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.tooltip, required this.onTap});
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          child: Icon(
            widget.icon,
            color: _hover ? AppColors.accent : AppColors.textMuted,
            size: 20,
          ),
        ),
      ),
    ),
  );
}

class _IconLink extends StatefulWidget {
  final IconData icon;
  final String url;
  const _IconLink({required this.icon, required this.url});
  @override
  State<_IconLink> createState() => _IconLinkState();
}

class _IconLinkState extends State<_IconLink> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        child: Icon(widget.icon,
          color: _hover ? AppColors.accent : AppColors.textMuted,
          size: 20,
        ),
      ),
    ),
  );
}

// ── Experience ────────────────────────────────────────────────────────────────

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding: _pad(context),
      child: _constrained(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScrollReveal(child: const SectionLabel('04. Experience')),
          const SizedBox(height: 40),
          _ScrollReveal(
            delay: const Duration(milliseconds: 100),
            child: isMobile ? _MobileExperience() : _DesktopExperience(),
          ),
        ],
      )),
    );
  }
}

class _DesktopExperience extends StatefulWidget {
  @override
  State<_DesktopExperience> createState() => _DesktopExperienceState();
}

class _DesktopExperienceState extends State<_DesktopExperience> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final exp = experiences[_selected];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: experiences.asMap().entries.map((e) =>
            _Tab(
              label: e.value.company,
              selected: e.key == _selected,
              onTap: () => setState(() => _selected = e.key),
            ),
          ).toList(),
        ),
        Container(width: 2, color: AppColors.border, margin: const EdgeInsets.only(left: 0, right: 32)),
        Expanded(child: _ExpContent(exp: exp)),
      ],
    );
  }
}

class _MobileExperience extends StatefulWidget {
  @override
  State<_MobileExperience> createState() => _MobileExperienceState();
}

class _MobileExperienceState extends State<_MobileExperience> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: experiences.asMap().entries.map((e) =>
              _TabH(
                label: e.value.company,
                selected: e.key == _selected,
                onTap: () => setState(() => _selected = e.key),
              ),
            ).toList(),
          ),
        ),
        Container(height: 2, color: AppColors.border),
        const SizedBox(height: 24),
        _ExpContent(exp: experiences[_selected]),
      ],
    );
  }
}

class _ExpContent extends StatelessWidget {
  final Experience exp;
  const _ExpContent({required this.exp});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(children: [
          TextSpan(text: exp.role, style: AppTheme.display(size: 18, color: AppColors.textLight, weight: FontWeight.w600)),
          TextSpan(text: ' @ ', style: AppTheme.sans(size: 18, color: AppColors.textMuted)),
          TextSpan(text: exp.company, style: AppTheme.display(size: 18, color: AppColors.accent, weight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(height: 6),
      Text(exp.period, style: AppTheme.mono(color: AppColors.textMuted, size: 12)),
      const SizedBox(height: 20),
      ...exp.description.split('. ').where((s) => s.trim().isNotEmpty).map((sentence) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 12),
                child: Text('▹', style: AppTheme.mono(color: AppColors.accent, size: 13)),
              ),
              Expanded(
                child: Text(
                  sentence.trim().endsWith('.') ? sentence.trim() : '${sentence.trim()}.',
                  style: AppTheme.sans(size: 14, color: AppColors.textMuted, height: 1.7),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 10, runSpacing: 8,
          children: exp.stack.map((t) => TagChip(t)).toList()),
    ],
  );
}

class _Tab extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});
  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: (widget.selected || _hover) ? AppColors.accentLight : Colors.transparent,
          border: Border(left: BorderSide(
            color: widget.selected ? AppColors.accent : Colors.transparent,
            width: 2,
          )),
        ),
        child: Text(
          widget.label,
          style: AppTheme.mono(
            color: widget.selected ? AppColors.accent : (_hover ? AppColors.accent : AppColors.textMuted),
            size: 12,
          ),
        ),
      ),
    ),
  );
}

class _TabH extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabH({required this.label, required this.selected, required this.onTap});
  @override
  State<_TabH> createState() => _TabHState();
}

class _TabHState extends State<_TabH> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: widget.selected ? AppColors.accent : Colors.transparent,
            width: 2,
          )),
        ),
        child: Text(
          widget.label,
          style: AppTheme.mono(
            color: widget.selected ? AppColors.accent : (_hover ? AppColors.accent : AppColors.textMuted),
            size: 12,
          ),
        ),
      ),
    ),
  );
}

// ── Contact ───────────────────────────────────────────────────────────────────

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});
  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _status = 'idle';

  Future<void> _submit() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) return;

    setState(() => _status = 'sending');

    const serviceId  = 'service_yrp7yq4';
    const templateId = 'template_q25o8nr';
    const publicKey  = 'H2oPZZbHym3Hf1OtZ';

    try {
      final res = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id':  serviceId,
          'template_id': templateId,
          'user_id':     publicKey,
          'template_params': {
            'from_name':  name,
            'from_email': email,
            'message':    message,
            'to_email':   'nathanielvelasco0915@gmail.com',
          },
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          _status = 'success';
          _nameCtrl.clear(); _emailCtrl.clear(); _messageCtrl.clear();
        });
      } else {
        setState(() => _status = 'error');
      }
    } catch (_) {
      setState(() => _status = 'error');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: _pad(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ScrollReveal(
                child: Text("05. What's Next?",
                    style: AppTheme.mono(color: AppColors.accent, size: 13)),
              ),
              const SizedBox(height: 20),
              _ScrollReveal(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  "Get In Touch",
                  style: AppTheme.display(size: w < 600 ? 36 : 52, color: AppColors.textLight, weight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              _ScrollReveal(
                delay: const Duration(milliseconds: 140),
                child: Text(
                  "I'm currently open to new opportunities. Whether you have a project in mind, a question, or just want to say hi — I'll try my best to get back to you!",
                  style: AppTheme.sans(size: 15, color: AppColors.textMuted, height: 1.7),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              _ScrollReveal(
                delay: const Duration(milliseconds: 180),
                child: CardBox(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('Name', _nameCtrl),
                      _field('Email', _emailCtrl),
                      _field('Message', _messageCtrl, maxLines: 5),
                      const SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: _status == 'sending' ? null : _submit,
                          child: _SendButton(status: _status),
                        ),
                      ),
                      if (_status == 'success') ...[
                        const SizedBox(height: 16),
                        Center(child: Text("Message sent — I'll be in touch soon!",
                            style: AppTheme.mono(color: AppColors.accent, size: 12))),
                      ],
                      if (_status == 'error') ...[
                        const SizedBox(height: 16),
                        Center(child: Text("Something went wrong. Please try again.",
                            style: AppTheme.mono(color: Colors.redAccent, size: 12))),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              _ScrollReveal(
                delay: const Duration(milliseconds: 220),
                child: Column(children: [
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 28),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('<NV />', style: AppTheme.mono(color: AppColors.accent, size: 14, weight: FontWeight.w600)),
                    Text('Designed & Built by Nathaniel Velasco',
                        style: AppTheme.mono(color: AppColors.textMuted, size: 10)),
                  ]),
                  const SizedBox(height: 8),
                  Text('${DateTime.now().year}',
                      style: AppTheme.mono(color: AppColors.border, size: 10)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTheme.mono(color: AppColors.accent, size: 11)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: AppTheme.sans(size: 14, color: AppColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.bg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
        ),
      ),
      const SizedBox(height: 18),
    ],
  );
}

class _SendButton extends StatefulWidget {
  final String status;
  const _SendButton({required this.status});
  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      decoration: BoxDecoration(
        color: _hover ? AppColors.accentLight : Colors.transparent,
        border: Border.all(color: widget.status == 'sending' ? AppColors.border : AppColors.accent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.status == 'sending' ? 'Sending…' : 'Get in Touch',
        style: AppTheme.mono(
          color: widget.status == 'sending' ? AppColors.textMuted : AppColors.accent,
          size: 13,
          weight: FontWeight.w500,
        ),
      ),
    ),
  );
}