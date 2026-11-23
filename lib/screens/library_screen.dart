import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/store.dart';
import '../widgets/anim.dart';
import '../widgets/thumb.dart';
import 'detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _cats = ['All', 'AI', 'Web3', 'Build', 'Markets', 'Media'];
  String _cat = 'All';
  String _q = '';
  bool _savedOnly = false;
  List<Map<String, dynamic>> _all = [];
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rows = await Store.instance.episodes(category: _cat, savedOnly: _savedOnly);
    if (!mounted) return;
    setState(() => _all = rows);
  }

  List<Map<String, dynamic>> get _filtered {
    if (_q.trim().isEmpty) return _all;
    final n = _q.toLowerCase();
    return _all.where((e) {
      final t = (e['title'] as String? ?? '').toLowerCase();
      final d = (e['description'] as String? ?? '').toLowerCase();
      final a = (e['titleAm'] as String? ?? '').toLowerCase();
      return t.contains(n) || d.contains(n) || a.contains(n);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Library'),
            Geez('ቤተ መጻሕፍት', size: 9),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _savedOnly ? 'Show all' : 'Show saved only',
            onPressed: () {
              setState(() => _savedOnly = !_savedOnly);
              _load();
            },
            icon: Icon(_savedOnly ? Icons.bookmark : Icons.bookmark_border,
                color: _savedOnly ? AppColors.accent : AppColors.muted),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _q = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search episodes  ·  ፈልግ',
                hintStyle: TextStyle(fontSize: 13.5, color: AppColors.muted.withOpacity( 0.7)),
                prefixIcon: const Icon(Icons.search, size: 19, color: AppColors.muted),
                suffixIcon: _q.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 17, color: AppColors.muted),
                        onPressed: () {
                          _search.clear();
                          setState(() => _q = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.accent.withOpacity( 0.6)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _cats[i];
                final active = c == _cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _cat = c);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: const Cubic(0.16, 1, 0.3, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent.withOpacity( 0.14) : Colors.transparent,
                      border: Border.all(
                          color: active ? AppColors.accent.withOpacity( 0.5) : const Color(0x1AFFFFFF)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(c,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? AppColors.accent : AppColors.muted,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? _empty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => RiseIn(
                      key: ValueKey('${_cat}_${_q}_$i'),
                      delay: (i < 8 ? i * 55 : 0),
                      child: _card(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 42, color: AppColors.muted.withOpacity( 0.5)),
            const SizedBox(height: 14),
            Text(_savedOnly ? 'Nothing saved yet' : 'No episodes match',
                style: const TextStyle(fontSize: 14, color: AppColors.muted)),
            const SizedBox(height: 4),
            Geez(_savedOnly ? 'እስካሁን ምንም አልተቀመጠም' : 'ምንም አልተገኘም', size: 10),
          ],
        ),
      );

  Widget _card(Map<String, dynamic> e) {
    final watched = (e['watched'] as int? ?? 0) == 1;
    final saved = (e['saved'] as int? ?? 0) == 1;
    final sec = e['durationSec'] as int? ?? 0;
    String pub = '';
    try {
      pub = DateFormat('MMM yyyy').format(DateTime.parse(e['published'] as String));
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailScreen(episode: e)),
            );
            _load();
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LayoutBuilder(
                    builder: (ctx, c) => EpisodeThumb(
                      path: e['thumb'] as String?,
                      height: (c.maxWidth * 9 / 16).clamp(90.0, 170.0),
                      width: c.maxWidth,
                      radius: 2,
                      category: e['category'] as String?,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text((e['category'] as String? ?? '').toUpperCase(),
                        style: kMono.copyWith(fontSize: 8.5, color: AppColors.amber)),
                    const SizedBox(width: 8),
                    Text('${sec ~/ 60} min', style: kMono.copyWith(fontSize: 8.5)),
                    if (pub.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text('· $pub', style: kMono.copyWith(fontSize: 8.5)),
                    ],
                    const Spacer(),
                    if (watched)
                      const Icon(Icons.check_circle, size: 14, color: AppColors.good)
                    else if (saved)
                      const Icon(Icons.bookmark, size: 14, color: AppColors.accent),
                  ],
                ),
                const SizedBox(height: 8),
                Text(e['title'] as String? ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3)),
                const SizedBox(height: 4),
                Text(e['titleAm'] as String? ?? '',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.muted.withOpacity( 0.8), height: 1.4)),
                const SizedBox(height: 9),
                Text(
                  e['description'] as String? ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5, height: 1.55, color: AppColors.text.withOpacity( 0.6)),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
