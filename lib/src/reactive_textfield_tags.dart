import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:textfield_tags/textfield_tags.dart';

class ReactiveTextFieldTags
    extends ReactiveFormField<Set<String>, Set<String>> {
  ReactiveTextFieldTags({
    InputDecoration decoration = const InputDecoration(),
    required FormControl<Set<String>> formControl,
    Object? Function(String)? validator,
  }) : super(
          formControl: formControl,
          builder: (field) {
            //TODO: add a way to show errors
            return InputDecorator(
              decoration: decoration.copyWith(
                  errorText: field.errorText,
                  filled: false,
                  enabled: field.control.enabled,
                  labelText: decoration.labelText,
                  contentPadding: const EdgeInsets.all(8.0)),
              child: TextFieldTags(
                tags: field.value!,
                onTag: (tag) =>
                    field.didChange(Set.from(field.value!..add(tag))),
                onDelete: (tag) =>
                    field.didChange(Set.from(field.value!..remove(tag))),
                validator: validator,
              ),
            );
          },
        );
}
