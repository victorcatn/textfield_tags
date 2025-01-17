import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/scheduler.dart';

typedef String? Validator(String tag);

class TextFieldTags extends HookWidget {
  final Set<String> tags;

  final void Function(String tag) onTag;

  final void Function(String tag) onDelete;

  final Object? Function(String text)? validator;

  ///Enter optional String separators to split tags. Default is [","," "]
  final List<String> textSeparators;

  final AutocompleteOptionsBuilder<String> optionsBuilder;

  TextFieldTags({
    Key? key,
    this.textSeparators = const [" ", ","],
    required this.tags,
    required this.onTag,
    required this.onDelete,
    required this.optionsBuilder,
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
    final _focusNode = useFocusNode();
    final _key = useMemoized(() => GlobalKey());
    return Wrap(
      children: [
        ..._buildTags(),
        IntrinsicWidth(
          child: Container(
              constraints: BoxConstraints(minWidth: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    focusNode: _focusNode,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: false,
                    ),
                    onSubmitted: (value) {
                      final val = value.trim().toLowerCase();
                      _validateClearAndNotify(_textEditingController);
                      RawAutocomplete.onFieldSubmitted(_key);
                    },
                    onChanged: (value) {
                      //TODO: consider the case when a text containing separator is pasted into the field, for now its ignored
                      //TODO: add autocompleting feature
                      if (value.length == 0) return;
                      if (textSeparators.any((sep) =>
                          value.substring(0, value.length - 1).contains(sep)))
                        return;
                      final lastChar = value[value.length - 1];
                      if (textSeparators.contains(lastChar)) {
                        _deleteLastChar(_textEditingController);
                        if (!value.contains(":")) {
                          _appendText(":", _textEditingController);
                        }
                        _validateClearAndNotify(_textEditingController);
                      }
                    },
                  ),
                  RawAutocomplete<String>(
                    key: _key,
                    focusNode: _focusNode,
                    textEditingController: _textEditingController,
                    optionsBuilder: optionsBuilder,
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options) {
                      return _AutocompleteOptions<String>(
                        displayStringForOption:
                            RawAutocomplete.defaultStringForOption,
                        onSelected: onSelected,
                        options: options,
                        maxOptionsHeight: 200.0,
                      );
                    },
                    onSelected: (_) =>
                        _validateClearAndNotify(_textEditingController),
                  ),
                ],
              ) /*TextField(
              controller: _textEditingController,
              autocorrect: false,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(), filled: false),
              onSubmitted: (value) {
                final val = value.trim().toLowerCase();
                _validateClearAndNotify(_textEditingController);
              },
              onChanged: (value) {
                //TODO: consider the case when a text containing separator is pasted into the field, for now its ignored
                //TODO: add autocompleting feature
                if (value.length == 0) return;
                if (textSeparators.any((sep) =>
                    value.substring(0, value.length - 1).contains(sep))) return;
                final lastChar = value[value.length - 1];
                if (textSeparators.contains(lastChar)) {
                  _deleteLastChar(_textEditingController);
                  if (!value.contains(":")) {
                    _appendText(":", _textEditingController);
                  }
                  _validateClearAndNotify(_textEditingController);
                }
              },
            ),*/
              ),
        )
      ],
    );
  }

  void _appendText(String text, TextEditingController _textEditingController) {
    final oldval = _textEditingController.value;
    _textEditingController.value = oldval.copyWith(
      text: oldval.text + ":",
      selection: oldval.selection.copyWith(
          baseOffset: oldval.selection.baseOffset + 1,
          extentOffset: oldval.selection.extentOffset + 1),
    );
  }

  void _deleteLastChar(TextEditingController _textEditingController) {
    final oldval = _textEditingController.value;
    _textEditingController.value = oldval.copyWith(
      text: oldval.text.substring(0, oldval.text.length - 1),
      selection: oldval.selection.copyWith(
          baseOffset: oldval.selection.baseOffset - 1,
          extentOffset: oldval.selection.extentOffset - 1),
    );
  }

  void _validateClearAndNotify(TextEditingController _textEditingController) {
    final val = _textEditingController.value.text.trim().toLowerCase();
    if (validator == null || validator!(val) == null) {
      _textEditingController.clear();
      onTag(val);
    }
  }
}

class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
  }) : super(key: key);

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxOptionsHeight),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(builder: (BuildContext context) {
                  final bool highlight =
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance!
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(displayStringForOption(option)),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
