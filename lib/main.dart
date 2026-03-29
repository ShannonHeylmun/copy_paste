import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MyHomePage(title: 'Flutter Demo Home Page'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final logger = Logger("MainLogger");
  String? copiedData;
  int _counter = 0;

  void _reset() {
    logger.info("ResetToZero");
    setState(() {
      _counter = 0;
    });
  }

  void _incrementCounter() {
    logger.info("Increment");
    setState(() {
      _counter++;
    });
  }

  void _copyCounter() async {
    logger.info("Attempt to Copy");
    try {
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        logger.info("...after a short delay...");
        return Clipboard.setData(
          ClipboardData(text: _counter.toString()),
        ).then((value) => logger.info("copied!"));
      });
    } on ClipboardException catch (e) {
      logger.shout(e.message);
    } catch (e) {
      logger.shout(e.toString());
    }
  }

  void showClipboard() async {
    ClipboardData? data;
    try {
      data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null) {
        logger.info("got clipboard data: ${data.text}");
      }
    } catch (e) {
      logger.shout(e.toString());
    }
    setState(() {
      copiedData = data?.text.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_counter.toString()),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
        body: Center(
          child: InkWell(
            onTap: () => showClipboard(),
            customBorder: CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Text(copiedData ?? "Paste Here"),
            ),
          ),
        ),
        persistentFooterButtons: [
          Row(
            children: [
              CustomCard(onTap: _reset, text: "Zero"),
              CustomCard(onTap: _incrementCounter, text: "Tap to add 1"),
              CustomCard(onTap: _copyCounter, text: "Tap to copy"),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomCard extends Expanded {
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onSecondaryTap;
  final String text;
  CustomCard({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    required this.text,
  }) : super(
         child: Card(
           clipBehavior: Clip.hardEdge,
           child: InkWell(
             onTap: onTap,
             onLongPress: onLongPress,
             onSecondaryTap: onSecondaryTap,

             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Center(child: Text(text, textAlign: TextAlign.center)),
             ),
           ),
         ),
       );
}
