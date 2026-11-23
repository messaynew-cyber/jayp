import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../services/store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool offline = false;
  Map<String, int> stats = {'total': 0, 'watched': 0, 'saved': 0};

  @override
  void initState() {
    super.initState();
    offline = Store.instance.offlineMode;
    _load();
  }

  Future<void> _load() async {
    final s = await Store.instance.stats();
    if (mounted) setState(() => stats = s);
  }

  Future<void> _open(String url) async {
    final u = Uri.parse(url);
    if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [Text('Settings'), Geez('ቅንብር', size: 9)],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          const Eyebrow('Data'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: SwitchListTile(
              value: offline,
              onChanged: (v) async {
                await Store.instance.setOfflineMode(v);
                setState(() => offline = v);
              },
              activeColor: AppColors.accent,
              title: const Text('Offline mode', style: TextStyle(fontSize: 14.5)),
              subtitle: Text(
                'Block all network calls. The library stays fully usable.',
                style: TextStyle(fontSize: 11.5, color: AppColors.muted.withOpacity( 0.9)),
              ),
              secondary: const Icon(Icons.wifi_off, size: 19),
            ),
          ),
          const SizedBox(height: 22),
          const Eyebrow('Your activity'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Row(
              children: [
                _stat('${stats['total']}', 'Episodes'),
                _divider(),
                _stat('${stats['watched']}', 'Watched'),
                _divider(),
                _stat('${stats['saved']}', 'Saved'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Eyebrow('Links'),
          const SizedBox(height: 12),
          _link('ETHIO TECH with JayP', 'YouTube channel', 'https://www.youtube.com/@ethiotechj'),
          _link('Jason Peters', 'LinkedIn', 'https://et.linkedin.com/in/jasonpeters-et'),
          _link('Cyber Ethiopia', 'Writing & AI guides', 'https://cyber.ethio-tech.com'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x1AFFFFFF)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.muted),
                    const SizedBox(width: 9),
                    Text('JAYP', style: kMono.copyWith(fontSize: 9, color: AppColors.text)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Version 1.0.0 · ጄይፕ',
                    style: TextStyle(fontSize: 11.5, color: AppColors.muted.withOpacity( 0.9))),
                const SizedBox(height: 6),
                Text(
                  'Built for Jason Peters. Episode metadata is bundled for offline use; '
                  'video streams from YouTube.',
                  style: TextStyle(
                      fontSize: 11, height: 1.6, color: AppColors.muted.withOpacity( 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Column(
          children: [
            Text(v, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l.toUpperCase(), style: kMono.copyWith(fontSize: 8.5)),
          ],
        ),
      );

  Widget _divider() => Container(width: 1, height: 30, color: const Color(0x14FFFFFF));

  Widget _link(String title, String sub, String url) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => _open(url),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(sub,
                            style: TextStyle(
                                fontSize: 11.5, color: AppColors.muted.withOpacity( 0.9))),
                      ],
                    ),
                  ),
                  const Icon(Icons.north_east, size: 15, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      );
}
