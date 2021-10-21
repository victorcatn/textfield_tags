import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef String? Validator(String tag);

class TextFieldTags extends HookWidget {
  final Set<String> tags;

  final void Function(String tag) onTag;

  final void Function(String tag) onDelete;

  final Object? Function(String text)? validator;

  ///Enter optional String separators to split tags. Default is [","," "]
  final List<String> textSeparators;

  TextFieldTags({
    Key? key,
    this.textSeparators = const [" ", ","],
    required this.tags,
    required this.onTag,
    required this.onDelete,
    this.validator,
  });

  List<Widget> _buildTags() {
    return tags
        .map((e) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: InputChip(
                label: Text(e),
                onDeleted: () => onDelete(e),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final _textEditingController = useTextEditingController();
    return Wrap(
      children: [
        ..._buildTags(),
        IntrinsicWidth(
          child: Container(
            constraints: BoxConstraints(minWidth: 50),
            child: TextField(
              controller: _textEditingController,
              autocorrect: false,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(), filled: false),
              onSubmitted: (value) {
                final val = value.trim().toLowerCase();
                _validateClearAndNotify(val, _textEditingController);
              },
              onChanged: (value) {
                //TODO: consider the case when a text containing separator is pasted into the field, for now its ignored
                //TODO: add autocompleting feature
                if (textSeparators.any((sep) =>
                    value.substring(0, value.length - 1).contains(sep))) return;
                final lastChar = value[value.length - 1];
                if (textSeparators.contains(lastChar)) {
                  final oldval = _textEditingController.value;
                  final oldsel = oldval.selection;
                  _textEditingController.value = oldval.copyWith(
                      text: value.substring(0, value.length - 1),
                      selection:
                          oldsel.copyWith(baseOffset: oldsel.baseOffset - 1));
                  _validateClearAndNotify(
                      _textEditingController.text, _textEditingController);
                }
              },
            ),
          ),
        )
      ],
    );
  }

  void _validateClearAndNotify(
      String val, TextEditingController _textEditingController) {
    if (validator == null || validator!(val) == null) {
      _textEditingController.clear();
      onTag(val);
    }
  }
}
