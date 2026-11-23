import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/store.dart';
import '../widgets/thumb.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> episode;
  const DetailScreen({super.key, required this.episode});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool saved;
  late bool watched;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    saved = (widget.episode['saved'] as int? ?? 0) == 1;
    watched = (widget.episode['watched'] as int? ?? 0) == 1;
  }

  Future<void> _toggleSave() async {
    setState(() => busy = true);
    final now = await Store.instance.toggleSaved(widget.episode['id'] as String);
    if (!mounted) return;
    setState(() {
      saved = now;
      busy = false;
    });
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(now ? 'Saved for offline' : 'Removed from saved'),
      duration: const Duration(milliseconds: 1400),
    ));
  }

  Future<void> _open() async {
    final url = widget.episode['url'] as String? ?? 'https://www.youtube.com/@ethiotechj';
    await Store.instance.markWatched(widget.episode['id'] as String);
    if (mounted) setState(() => watched = true);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  Future<void> _share() async {
    final t = widget.episode['title'] as String? ?? '';
    final u = widget.episode['url'] as String? ?? '';
    await Share.share('$t\n$u', subject: t);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.episode;
    final sec = e['durationSec'] as int? ?? 0;
    String pub = '';
    try {
      pub = DateFormat('MMMM d, yyyy').format(DateTime.parse(e['published'] as String));
    } catch (_) {}
    final m = sec ~/ 60;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: busy ? null : _toggleSave,
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                color: saved ? AppColors.accent : AppColors.text),
            tooltip: saved ? 'Remove from saved' : 'Save offline',
          ),
          IconButton(onPressed: _share, icon: const Icon(Icons.share_outlined), tooltip: 'Share'),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: LayoutBuilder(
              builder: (ctx, c) => EpisodeThumb(
                path: e['thumb'] as String?,
                width: c.maxWidth,
                height: (c.maxWidth * 9 / 16).clamp(140.0, 240.0),
                radius: 4,
                category: e['category'] as String?,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              Text((e['category'] as String? ?? '').toUpperCase(),
                  style: kMono.copyWith(color: AppColors.amber, fontSize: 9)),
              const SizedBox(width: 10),
              Text('${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m',
                  style: kMono.copyWith(fontSize: 9)),
              if (pub.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text('· $pub', style: kMono.copyWith(fontSize: 9)),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text(e['title'] as String? ?? '',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, height: 1.22, letterSpacing: -0.4)),
          const SizedBox(height: 8),
          Text(e['titleAm'] as String? ?? '',
              style: const TextStyle(fontSize: 14, color: AppColors.accent, height: 1.45)),
          const SizedBox(height: 24),
          if (watched)
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.good.withOpacity( 0.08),
                border: Border.all(color: AppColors.good.withOpacity( 0.3)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 14, color: AppColors.good),
                  const SizedBox(width: 8),
                  Text('Watched  ·  ተመልክቷል',
                      style: TextStyle(fontSize: 11.5, color: AppColors.good.withOpacity( 0.95))),
                ],
              ),
            ),
          const Divider(),
          const SizedBox(height: 20),
          const Eyebrow('About this episode'),
          const SizedBox(height: 12),
          Text(
            e['description'] as String? ?? '',
            style: TextStyle(fontSize: 14.5, height: 1.75, color: AppColors.text.withOpacity( 0.82)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _open,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.ground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(watched ? 'Watch again' : 'Watch on YouTube',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _toggleSave,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: BorderSide(color: AppColors.accent.withOpacity( 0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              ),
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 18),
              label: Text(saved ? 'Saved offline' : 'Save offline', style: const TextStyle(fontSize: 13.5)),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 15, color: AppColors.muted),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Video plays on YouTube — this app keeps the index, your progress and your notes fully offline.',
                    style: TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.muted.withOpacity( 0.9)),
                  ),
                ),
              ],
            ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
