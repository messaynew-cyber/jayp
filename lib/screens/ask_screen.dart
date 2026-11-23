import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/api.dart';
import '../services/store.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});
  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Turn> _turns = [];
  bool _busy = false;

  static const _suggestions = [
    'What is a blockchain, in plain language?',
    'How do I start learning AI in 2025?',
    'Why does TON matter for African builders?',
    'What can ChatGPT not do?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final q = (preset ?? _input.text).trim();
    if (q.isEmpty || _busy) return;
    setState(() {
      _turns.add(_Turn(q, null, true));
      _busy = true;
    });
    _input.clear();
    _jump();

    final answer = await Api.instance.ask(q);
    await Store.instance.logAsk(q, answer);
    if (!mounted) return;
    setState(() {
      _turns.last = _Turn(q, answer, false);
      _busy = false;
    });
    _jump();
  }

  void _jump() {
    Future.delayed(const Duration(milliseconds: 90), () {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240), curve: const Cubic(0.16, 1, 0.3, 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [Text('Ask JayP'), Geez('ጠይቅ', size: 9)],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _turns.isEmpty
                ? _intro()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _turns.length,
                    itemBuilder: (_, i) => _bubble(_turns[i]),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: !_busy,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      maxLines: null,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask anything  ·  ማንኛውንም ጠይቅ',
                        hintStyle: TextStyle(
                            fontSize: 13.5, color: AppColors.muted.withOpacity( 0.7)),
                        filled: true,
                        fillColor: AppColors.ground,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: FilledButton(
                      onPressed: _busy ? null : () => _send(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.ground,
                        disabledBackgroundColor: AppColors.surfaceHi,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.muted))
                          : const Icon(Icons.arrow_upward_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _intro() => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const SizedBox(height: 8),
          const Eyebrow('Ask'),
          const SizedBox(height: 12),
          const Text('Straight answers on\ntechnology and Africa.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3)),
          const Geez('በቴክኖሎጂ እና በአፍሪካ ላይ ቀጥተኛ መልስ', size: 10),
          const SizedBox(height: 26),
          for (final s in _suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _send(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(s,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  color: AppColors.text.withOpacity( 0.88))),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.north_east, size: 14, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );

  Widget _bubble(_Turn t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 8, left: 38),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity( 0.12),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(2),
            ),
            border: Border.all(color: AppColors.accent.withOpacity( 0.22)),
          ),
          child: Text(t.q, style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(right: 26, bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(10),
              ),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: t.answer == null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 1.8, color: AppColors.accent)),
                      const SizedBox(width: 10),
                      Text('Thinking…', style: TextStyle(fontSize: 13, color: AppColors.muted.withOpacity( 0.9))),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.answer!,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.72,
                              color: AppColors.text.withOpacity( 0.88))),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: t.answer!));
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Copied'),
                                duration: Duration(milliseconds: 1200)),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded,
                                size: 13, color: AppColors.muted.withOpacity( 0.8)),
                            const SizedBox(width: 6),
                            Text('Copy', style: kMono.copyWith(fontSize: 9)),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _Turn {
  final String q;
  String? answer;
  bool pending;
  _Turn(this.q, this.answer, this.pending);
}
