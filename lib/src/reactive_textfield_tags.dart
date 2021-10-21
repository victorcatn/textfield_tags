import 'package:reactive_forms/reactive_forms.dart';
import 'package:textfield_tags/textfield_tags.dart';

class ReactiveTextFieldTags
    extends ReactiveFormField<Set<String>, Set<String>> {
  ReactiveTextFieldTags({
    required FormControl<Set<String>> formControl,
    Object? Function(String)? validator,
  }) : super(
          formControl: formControl,
          builder: (field) {
            return TextFieldTags(
              tags: field.value!,
              onTag: (tag) => field.didChange(Set.from(field.value!..add(tag))),
              onDelete: (tag) =>
                  field.didChange(Set.from(field.value!..remove(tag))),
              validator: validator,
            );
          },
        );
}
