import 'package:flutter/material.dart';

Future<String?> showPlayerNameDialog(
  BuildContext context, {
  String recentName = '',
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PlayerNameDialog(recentName: recentName),
  );
}

class _PlayerNameDialog extends StatefulWidget {
  const _PlayerNameDialog({required this.recentName});

  final String recentName;

  @override
  State<_PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<_PlayerNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit({bool anonymous = false}) {
    final name = anonymous ? '익명' : _controller.text.trim();
    Navigator.of(context).pop(name.isEmpty ? '익명' : name);
  }

  @override
  Widget build(BuildContext context) {
    final recentName = widget.recentName.trim();
    final hasRecentName = recentName.isNotEmpty;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        '닉네임 저장',
        style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
            controller: _controller,
            autofocus: true,
            maxLength: 10,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: hasRecentName ? '새 닉네임 입력' : '예: 홍길동',
              counterText: '',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (hasRecentName) ...[
            const SizedBox(height: 12),
            const Text(
              '최근 닉네임',
              style: TextStyle(
                color: Color(0xFF60707F),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            ActionChip(
              avatar: const Icon(Icons.history_rounded, size: 18),
              label: Text(recentName),
              labelStyle: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
              ),
              backgroundColor: const Color(0xFFEAF7FF),
              side: const BorderSide(color: Color(0xFFB9E2F4)),
              onPressed: () {
                _controller.text = recentName;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _submit(anonymous: true),
          child: const Text('익명으로 저장'),
        ),
        FilledButton(onPressed: _submit, child: const Text('저장')),
      ],
    );
  }
}
