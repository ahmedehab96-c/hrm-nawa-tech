import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/text_direction_helper.dart';
import '../../l10n/app_localizations.dart';
import 'ai_assistant_service.dart';

class AiAssistantPanel extends StatefulWidget {
  const AiAssistantPanel({super.key});

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  var _busy = false;
  var _welcome = false;

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _seedWelcome(AppLocalizations l10n) {
    if (_welcome) return;
    _welcome = true;
    _msgs.add(_Msg(l10n.aiAssistantWelcome, false));
  }

  Future<void> _send() async {
    final q = _text.text.trim();
    if (q.isEmpty || _busy) return;
    _text.clear();
    setState(() {
      _msgs.add(_Msg(q, true));
      _busy = true;
    });
    _end();
    final lang = Localizations.localeOf(context).languageCode;
    final reply = await AiAssistantService.getResponse(q, languageCode: lang);
    if (!mounted) return;
    setState(() {
      _msgs.add(_Msg(reply, false));
      _busy = false;
    });
    _end();
  }

  void _end() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final cs = t.colorScheme;
    _seedWelcome(l10n);

    return Directionality(
      textDirection: textDirectionForContext(context),
      child: Container(
        width: 400,
        height: 560,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Material(
              color: cs.primaryContainer.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.smart_toy, color: cs.primary, size: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.aiPanelTitle,
                        style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _msgs.length + (_busy ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _msgs.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 10),
                          Text(l10n.aiTyping, style: AppTypography.caption),
                        ],
                      ),
                    );
                  }
                  final m = _msgs[i];
                  return _Bubble(text: m.text, user: m.user, cs: cs);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      decoration: InputDecoration(
                        hintText: l10n.aiInputHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _busy ? null : _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  _Msg(this.text, this.user);
  final String text;
  final bool user;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.user, required this.cs});

  final String text;
  final bool user;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: user ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: user ? cs.primaryContainer : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: user ? cs.onPrimaryContainer : cs.onSurface,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
