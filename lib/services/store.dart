import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence: episodes, saved articles, ask history, settings.
class Store {
  Store._();
  static final Store instance = Store._();

  Database? db;
  SharedPreferences? prefs;
  bool ready = false;

  Future<void> init() async {
    if (ready) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      db = await openDatabase(
        p.join(dir.path, 'jayp.db'),
        version: 1,
        onCreate: (d, v) async {
          await d.execute('CREATE TABLE episodes('
              'id TEXT PRIMARY KEY, title TEXT NOT NULL, titleAm TEXT, '
              'description TEXT, published TEXT, durationSec INTEGER, '
              'category TEXT, url TEXT, watched INTEGER DEFAULT 0, saved INTEGER DEFAULT 0)');
          await d.execute('CREATE TABLE asklog('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, question TEXT, answer TEXT, ts TEXT)');
          await d.execute('CREATE INDEX idx_ep_cat ON episodes(category)');
        },
      );
      prefs = await SharedPreferences.getInstance();
      ready = true;
    } catch (_) {
      ready = false;
    }
  }

  Future<List<Map<String, dynamic>>> episodes({String? category, bool savedOnly = false}) async {
    final d = db;
    if (d == null) return [];
    final where = <String>[];
    final args = <Object?>[];
    if (category != null && category != 'All') {
      where.add('category = ?');
      args.add(category);
    }
    if (savedOnly) where.add('saved = 1');
    return d.query(
      'episodes',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'published DESC',
    );
  }

  /// Seeds the catalogue. Idempotent: inserts any episode whose id is not
  /// already present, so a re-launch after a schema change (or an install
  /// over an older build) backfills the missing rows instead of giving up
  /// because the table is not literally empty.
  Future<int> seedEpisodes(List<Map<String, dynamic>> rows) async {
    final d = db;
    if (d == null) return 0;
    var inserted = 0;
    for (final r in rows) {
      try {
        final existing = await d.query('episodes',
            columns: ['id'], where: 'id = ?', whereArgs: [r['id']]);
        if (existing.isNotEmpty) continue;
        await d.insert('episodes', r, conflictAlgorithm: ConflictAlgorithm.replace);
        inserted++;
      } catch (_) {
        // Never let one bad row poison the whole seed.
      }
    }
    return inserted;
  }

  Future<int> episodeCount() async {
    final d = db;
    if (d == null) return 0;
    return Sqflite.firstIntValue(
            await d.rawQuery('SELECT COUNT(*) FROM episodes')) ??
        0;
  }

  /// Last-resort repair: wipe and re-seed. Used if the table is empty even
  /// after a seed attempt (corrupt DB from an interrupted write).
  Future<int> reseedEpisodes(List<Map<String, dynamic>> rows) async {
    final d = db;
    if (d == null) return 0;
    await d.delete('episodes');
    var n = 0;
    for (final r in rows) {
      try {
        await d.insert('episodes', r, conflictAlgorithm: ConflictAlgorithm.replace);
        n++;
      } catch (_) {}
    }
    return n;
  }

  Future<bool> toggleSaved(String id) async {
    final d = db;
    if (d == null) return false;
    final cur = await d.query('episodes', columns: ['saved'], where: 'id = ?', whereArgs: [id]);
    final was = (cur.isNotEmpty && (cur.first['saved'] as int? ?? 0) == 1);
    await d.update('episodes', {'saved': was ? 0 : 1}, where: 'id = ?', whereArgs: [id]);
    return !was;
  }

  Future<void> markWatched(String id) async {
    final d = db;
    if (d == null) return;
    await d.update('episodes', {'watched': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> stats() async {
    final d = db;
    if (d == null) return {'total': 0, 'watched': 0, 'saved': 0};
    final total = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM episodes')) ?? 0;
    final watched = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM episodes WHERE watched=1')) ?? 0;
    final saved = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM episodes WHERE saved=1')) ?? 0;
    return {'total': total, 'watched': watched, 'saved': saved};
  }

  Future<void> logAsk(String q, String a) async {
    final d = db;
    if (d == null) return;
    await d.insert('asklog', {
      'question': q,
      'answer': a,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> askHistory({int limit = 25}) async {
    final d = db;
    if (d == null) return [];
    return d.query('asklog', orderBy: 'id DESC', limit: limit);
  }

  bool get offlineMode => prefs?.getBool('offlineMode') ?? false;
  Future<void> setOfflineMode(bool v) async {
    await prefs?.setBool('offlineMode', v);
  }

  String? get lastSync => prefs?.getString('lastSync');
  Future<void> setLastSync(DateTime d) async {
    await prefs?.setString('lastSync', d.toIso8601String());
  }
}
