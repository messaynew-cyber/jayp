import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/store.dart';
import 'detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Map<String, int> stats = {'total': 0, 'watched': 0, 'saved': 0};
  List<Map<String, dynamic>> recent = [];
  bool loading = true;
  late AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..forward();
    _boot();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await _seed();
    final s = await Store.instance.stats();
    final list = await Store.instance.episodes();
    if (!mounted) return;
    setState(() {
      stats = s;
      recent = list.take(3).toList();
      loading = false;
    });
  }

  Future<void> _seed() async {
    try {
      final raw = await rootBundle.loadString('assets/data/episodes.json');
      final data = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      await Store.instance.seedEpisodes(data);
    } catch (_) {}
  }

  String _fmtDur(int? sec) {
    if (sec == null) return '—';
    final m = sec ~/ 60;
    return '${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: _boot,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _hero(),
            _statBand(),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Latest'),
                  const SizedBox(height: 6),
                  const Text('Recently added',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2)),
                  const Geez('አዲስ የተጨመሩ', size: 10),
                  const SizedBox(height: 16),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else
                    for (final e in recent) _EpisodeRow(e: e, dur: _fmtDur(e['durationSec'] as int?)),
                  const SizedBox(height: 30),
                  _aboutCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 34),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF141922), AppColors.ground],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent.withOpacity( 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('ጄ',
                      style: TextStyle(color: AppColors.accent, fontSize: 17, height: 1)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('JAYP',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text)),
                    Geez('ጄይፕ', size: 9),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 34),
            const Text(
              'Ethiopian technology,\nin your pocket.',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, height: 1.14, letterSpacing: -0.6),
            ),
            const SizedBox(height: 8),
            const Text('የኢትዮጵያ ቴክኖሎጂ በእጅዎ',
                style: TextStyle(fontSize: 13, color: AppColors.accent, height: 1.4)),
            const SizedBox(height: 18),
            Text(
              'Jason Peters — the channel, the ventures, and the arguments. '
              'Works offline, built for the network you actually have.',
              style: TextStyle(fontSize: 14, height: 1.62, color: AppColors.text.withOpacity( 0.72)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBand() {
    final watched = stats['watched'] ?? 0;
    final total = stats['total'] ?? 0;
    final pct = total == 0 ? 0.0 : watched / total;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity( 0.06),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                Text('${(pct * 100).round()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$watched of $total watched',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Geez('የተመለከቱ', size: 9.5),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip(Icons.bookmark_border, '${stats['saved']}', 'Saved'),
                    const SizedBox(width: 16),
                    _chip(Icons.wifi_off, Store.instance.offlineMode ? 'Off' : 'On', 'Offline'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String value, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(value,
              style: TextStyle(fontSize: 11.5, color: AppColors.text.withOpacity( 0.85))),
          const SizedBox(width: 4),
          Text(label, style: kMono.copyWith(fontSize: 8.5)),
        ],
      );

  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent.withOpacity( 0.06), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Who'),
          const SizedBox(height: 12),
          const Text('Jason Peters',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
          const Geez('ጄሰን ፒተርስ', size: 10),
          const SizedBox(height: 12),
          Text(
            'Founder of ETN Ecosystem and the ET Apps Community. CTO at Ge\'ez E-sport. '
            'Host of ETHIO TECH with JayP — 84,700 subscribers — and the person who '
            'translated the AI conversation into Amharic.',
            style: TextStyle(fontSize: 13.5, height: 1.66, color: AppColors.text.withOpacity( 0.7)),
          ),
        ],
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  final Map<String, dynamic> e;
  final String dur;
  const _EpisodeRow({required this.e, required this.dur});

  @override
  Widget build(BuildContext context) {
    final watched = (e['watched'] as int? ?? 0) == 1;
    final saved = (e['saved'] as int? ?? 0) == 1;
    String pub = '';
    try {
      pub = DateFormat('MMM d, yyyy').format(DateTime.parse(e['published'] as String));
    } catch (_) {}
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailScreen(episode: e)),
          ),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: watched ? AppColors.accent.withOpacity( 0.2) : const Color(0x1AFFFFFF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 46,
                  margin: const EdgeInsets.only(right: 14, top: 2),
                  decoration: BoxDecoration(
                    color: watched ? AppColors.accent : AppColors.muted.withOpacity( 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text((e['category'] as String? ?? '').toUpperCase(),
                              style: kMono.copyWith(fontSize: 8.5, color: AppColors.amber)),
                          const SizedBox(width: 8),
                          Text('· $dur', style: kMono.copyWith(fontSize: 8.5)),
                          if (saved) ...[
                            const Spacer(),
                            const Icon(Icons.bookmark, size: 13, color: AppColors.accent),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(e['title'] as String? ?? '',
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.3)),
                      const SizedBox(height: 3),
                      Text(e['titleAm'] as String? ?? '',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.muted.withOpacity( 0.8),
                              height: 1.4)),
                      if (pub.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(pub, style: kMono.copyWith(fontSize: 8.5)),
                      ],
                    ],
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
