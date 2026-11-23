import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});
  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  bool loading = true;
  String? error;
  double price = 0;
  double change = 0;
  final List<double> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final d = await Api.instance.tonStats();
    if (!mounted) return;
    if (d == null) {
      setState(() {
        loading = false;
        error = 'Could not reach the network.';
      });
      return;
    }
    final ton = d['the-open-network'] as Map<String, dynamic>?;
    final p = (ton?['usd'] as num?)?.toDouble() ?? 0;
    final c = (ton?['usd_24h_change'] as num?)?.toDouble() ?? 0;
    setState(() {
      price = p;
      change = c;
      if (p > 0) {
        _history.add(p);
        if (_history.length > 20) _history.removeAt(0);
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final up = change >= 0;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [Text('Network'), Geez('ኔትወርክ', size: 9)],
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
          children: [
            const Eyebrow('TON · the-open-network'),
            const SizedBox(height: 6),
            Geez('ቶን ብሎክቼይን', size: 10),
            const SizedBox(height: 18),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (error != null)
              _errorCard()
            else ...[
              _priceCard(up),
              const SizedBox(height: 14),
              if (_history.length > 1) _sparkline(),
              const SizedBox(height: 22),
              const Eyebrow('The ventures'),
              const SizedBox(height: 12),
              _venture('ETN Ecosystem', 'ኢትኤን ኢኮሲስተም', 'Founder',
                  'Decentralised platforms on TON, built from Addis Ababa for Africa.'),
              _venture('ET Apps Community', 'የመተግበሪያ ማህበረሰብ', 'Founder',
                  'The builder community shipping on decentralised rails in Ethiopia.'),
              _venture("Ge'ez E-sport", 'ግዕዝ ኢ-ስፖርት', 'CTO',
                  'Competitive gaming infrastructure — the servers the continent never had.'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Live market data via CoinGecko. Set offline mode in Settings to stop all network calls.',
                        style: TextStyle(
                            fontSize: 11, height: 1.55, color: AppColors.muted.withOpacity( 0.9)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.danger.withOpacity( 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 30, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(color: AppColors.accent.withOpacity( 0.4)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _priceCard(bool up) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent.withOpacity( 0.07), Colors.transparent],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TON',
                    style: kMono.copyWith(fontSize: 10, color: AppColors.text.withOpacity( 0.7))),
                const SizedBox(height: 8),
                Text(
                  '\$${price.toStringAsFixed(price < 1 ? 4 : 2)}',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(up ? Icons.trending_up : Icons.trending_down,
                        size: 15, color: up ? AppColors.good : AppColors.danger),
                    const SizedBox(width: 6),
                    Text(
                      '${up ? '+' : ''}${change.toStringAsFixed(2)}%  24h',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: up ? AppColors.good : AppColors.danger),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceHi,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Text('LIVE', style: kMono.copyWith(fontSize: 8, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _sparkline() {
    final lo = _history.reduce((a, b) => a < b ? a : b);
    final hi = _history.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo) == 0 ? 1.0 : (hi - lo);
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in _history)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 8 + ((v - lo) / span) * 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _venture(String name, String am, String role, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(role.toUpperCase(),
                  style: kMono.copyWith(fontSize: 8, color: AppColors.amber)),
              const Spacer(),
              const Icon(Icons.arrow_outward, size: 13, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 7),
          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Text(am, style: TextStyle(fontSize: 10, color: AppColors.accent.withOpacity( 0.7), height: 1.5)),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(
                  fontSize: 12.5, height: 1.55, color: AppColors.text.withOpacity( 0.62))),
        ],
      ),
    );
  }
}
