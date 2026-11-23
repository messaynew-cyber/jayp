import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/store.dart';
import 'library_screen.dart';
import 'ask_screen.dart';
import 'network_screen.dart';
import 'settings_screen.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final GlobalKey<LibraryScreenState> _libraryKey = GlobalKey<LibraryScreenState>();

  static const _tabs = [
    _Tab('Home', 'መነሻ', Icons.home_outlined, Icons.home),
    _Tab('Library', 'ቤተ መጻሕፍት', Icons.library_books_outlined, Icons.library_books),
    _Tab('Ask', 'ጠይቅ', Icons.chat_bubble_outline, Icons.chat_bubble),
    _Tab('Network', 'ኔትወርክ', Icons.public_outlined, Icons.public),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTab(),
      LibraryScreen(key: _libraryKey),
      const AskScreen(),
      const NetworkScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                for (var k = 0; k < _tabs.length; k++)
                  Expanded(
                    child: _NavItem(
                      tab: _tabs[k],
                      active: _i == k,
                      onTap: () {
                        setState(() => _i = k);
                        // IndexedStack keeps children alive, so initState only runs
                        // once. Refresh the Library every time it becomes visible.
                        if (k == 1) {
                          _libraryKey.currentState?.refreshFromSource();
                        }
                      },
                    ),
                  ),
                Expanded(
                  child: _NavItem(
                    tab: const _Tab('Settings', 'ቅንብር', Icons.tune_outlined, Icons.tune),
                    active: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final String am;
  final IconData icon;
  final IconData iconActive;
  const _Tab(this.label, this.am, this.icon, this.iconActive);
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.tab, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.muted;
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.accent.withOpacity( 0.08),
      highlightColor: Colors.transparent,
      child: Semantics(
        label: tab.label,
        selected: active,
        button: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? tab.iconActive : tab.icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 9.5,
                letterSpacing: 0.4,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            Text(
              tab.am,
              style: TextStyle(
                fontSize: 8,
                color: AppColors.muted.withOpacity( 0.5),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
