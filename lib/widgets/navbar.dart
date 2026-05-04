import 'package:flutter/material.dart';
import '../theme.dart';

class PortfolioNavbar extends StatefulWidget implements PreferredSizeWidget {
  final List<String> sections;
  final void Function(String) onTap;

  const PortfolioNavbar({super.key, required this.sections, required this.onTap});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  State<PortfolioNavbar> createState() => _PortfolioNavbarState();
}

class _PortfolioNavbarState extends State<PortfolioNavbar> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: AppColors.bgNav,  // solid color — no compositing cost
            border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Text(
                '<NV />',
                style: AppTheme.mono(color: AppColors.accent, size: 18, weight: FontWeight.w600),
              ),
              if (!isMobile)
                Row(
                  children: [
                    ...widget.sections.asMap().entries.map((e) =>
                      _NavLink(
                        index: e.key + 1,
                        label: e.value,
                        onTap: () => widget.onTap(e.value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _ResumeButton(),
                  ],
                )
              else
                IconButton(
                  icon: Icon(_menuOpen ? Icons.close : Icons.menu, color: AppColors.accent, size: 22),
                  onPressed: () => setState(() => _menuOpen = !_menuOpen),
                ),
            ],
          ),
        ),
        if (isMobile && _menuOpen)
          Container(
            color: AppColors.bgNav,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...widget.sections.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: () { setState(() => _menuOpen = false); widget.onTap(e.value); },
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('0${e.key + 1}.', style: AppTheme.mono(color: AppColors.accent, size: 11)),
                      const SizedBox(height: 2),
                      Text(e.value, style: AppTheme.sans(color: AppColors.textLight, size: 15, weight: FontWeight.w500)),
                    ]),
                  ),
                )),
                const SizedBox(height: 16),
                _ResumeButton(),
              ],
            ),
          ),
      ],
    );
  }
}

class _ResumeButton extends StatefulWidget {
  @override
  State<_ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<_ResumeButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _hover ? AppColors.accentLight : Colors.transparent,
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Resume', style: AppTheme.mono(color: AppColors.accent, size: 12)),
    ),
  );
}

class _NavLink extends StatefulWidget {
  final int index;
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.index, required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: '0${widget.index}. ',
              style: AppTheme.mono(color: AppColors.accent, size: 11),
            ),
            TextSpan(
              text: widget.label,
              style: AppTheme.sans(
                color: _hover ? AppColors.accent : AppColors.textLight,
                size: 13,
                weight: FontWeight.w400,
              ),
            ),
          ]),
        ),
      ),
    ),
  );
}
