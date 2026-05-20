import 'package:flutter/material.dart';

Future<String?> showPlayerNameDialog(
  BuildContext context, {
  String initialName = '',
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PlayerNameDialog(initialName: initialName),
  );
}

class _PlayerNameDialog extends StatefulWidget {
  const _PlayerNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<_PlayerNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
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
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        '닉네임 저장',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 10,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: '예: 키오스크고수',
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
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
