import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/navbar.dart';
import 'sections/hero_section.dart';
import 'sections/sections.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nathaniel Velasco - Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const PortfolioHome(),
      );
}

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  final _scrollCtrl = ScrollController();

  final _sectionKeys = {
    'About':      GlobalKey(),
    'Skills':     GlobalKey(),
    'Projects':   GlobalKey(),
    'Experience': GlobalKey(),
    'Contact':    GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() => RevealNotifier.instance.notify());
  }

  void _scrollTo(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext == null) return;
    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    );
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: RepaintBoundary(
          child: PortfolioNavbar(
            sections: _sectionKeys.keys.toList(),
            onTap: _scrollTo,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                HeroSection(
                  onViewProjects: () => _scrollTo('Projects'),
                  onContact: () => _scrollTo('Contact'),
                ),
                KeyedSubtree(key: _sectionKeys['About'],      child: const AboutSection()),
                KeyedSubtree(key: _sectionKeys['Skills'],     child: const SkillsSection()),
                KeyedSubtree(key: _sectionKeys['Projects'],   child: const ProjectsSection()),
                KeyedSubtree(key: _sectionKeys['Experience'], child: const ExperienceSection()),
                KeyedSubtree(key: _sectionKeys['Contact'],    child: const ContactSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideIcon extends StatefulWidget {
  final String label;
  final String url;
  const _SideIcon({required this.label, required this.url});
  @override
  State<_SideIcon> createState() => _SideIconState();
}

class _SideIconState extends State<_SideIcon> {
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
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
        child: Text(widget.label,
          style: AppTheme.mono(
            color: _hover ? AppColors.accent : AppColors.textMuted,
            size: 11, weight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}