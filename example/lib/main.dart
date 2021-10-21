import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

void main() {
  runApp(MyApp());
}

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> m = {"cool", "college"};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Flutter textfield tags',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: TextFieldTags(
          tags: m,
          textSeparators: [" ", ".", ","],
          onDelete: (tag) {
            setState(() {
              m.remove(tag);
            });
          },
          onTag: (tag) {
            setState(() {
              m.add(tag);
            });
          },
          validator: (String tag) {
            if (tag.length > 15) return "hey that is too much";

            if (tag.isEmpty) return "enter something";

            final splited = tag.split(":");

            if (splited.length == 1)
              return "agregue : para separar la etiqueta";
            
            if (splited.length > 2) return "solo se permite un :";

            if (splited[0].isEmpty || splited[1].isEmpty) return "agregue texto antes y despues de :";

            return null;
          },
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

//Tags eg: university, college, music, math, calculus, computerscience, economics, flutter
