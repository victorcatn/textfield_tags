import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:textfield_tags/textfield_tags.dart';

void main() {
  runApp(MyApp());
}

final control = fb.control({"gato", "perro"});

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("test")),
        body: ReactiveTextFieldTags(
            formControl: control,
            validator: (String tag) {
              if (tag.length > 15) return "hey that is too much";

              if (tag.isEmpty) return "enter something";

              final splited = tag.split(":");

              if (splited.length == 1)
                return "agregue : para separar la etiqueta";

              if (splited.length > 2) return "solo se permite un :";

              if (splited[0].isEmpty || splited[1].isEmpty)
                return "agregue texto antes y despues de :";

              return null;
            }),
      ),
    );
  }
}
