import 'package:flutter/material.dart';
import 'package:pr5/screen.dart';
import 'package:pr5/screen2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

late ThemeModel model;
TextEditingController _controller = TextEditingController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeModel>(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (_, model1, __) {
          model = model1;
          return MaterialApp(
            routes: {
              'screen': (context) => const Screen(),
              'screen2': (context) => const Screen2()
            },
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: model.mode,
            debugShowCheckedModeBanner: false,
            home: const MyHomePage(title: ''),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isPrefNull = true;
  String? text = "";
  bool isDark = false;

  late SharedPreferences shared;

  Future<void> initShared() async {
    shared = await SharedPreferences.getInstance();
    text = shared.getString('text');
    isDark = shared.getBool('isDark') ?? false;

    if (text != null) {
      isPrefNull == false;
      _controller.text = text as String;
    }
    if (isDark) {
      model.toggleMode();
    }
    setState(() {});
  }

  void onChange() {
    text = _controller.text;
    savePref();
  }

  @override
  void initState() {
    _controller.addListener(onChange);
    initShared();
    super.initState();
  }

  void savePref() async {
    setState(() {});
    if (text != null && text != "") {
      isPrefNull = false;
      await shared.setString('text', text!);
      await shared.setBool('isDark', isDark);
    }
  }

  void clearPreferences() async {
    setState(() {});
    isPrefNull = true;
    await shared.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 400,
              alignment: Alignment.center,
              child: TextFormField(
                decoration: const InputDecoration(hintText: "Введите текст"),
                controller: _controller,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (isPrefNull) {
                  Navigator.pushNamed(
                    context,
                    'screen',
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    'screen2',
                    arguments: {'Argument': text},
                  );
                }
              },
              child: const Text('Перейти в окно'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                model.toggleMode();
                isDark = !isDark;
                savePref();
              },
              child: const Text('Сменить тему'),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                clearPreferences();
              },
              child: const Text('Очистить данные из буфера'),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeModel with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
