import 'package:flutter/material.dart';
import 'package:select_any/select_any.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
        floatingActionButton: NavigationButton(),
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  const NavigationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SelectAnyModule(SelectModel('Example', 'id', [
                      Line('a'),
                      Line(
                        'b',
                        enclosure: 'My value is: ???',
                      ),
                      Line('c', enableSorting: false),
                      Line('d', tableTooltip: 'My Custom Tooltip'),
                      Line('e', name: 'My Custom Name')
                    ], FontDataAny((data) async {
                      return List<Map<String, dynamic>>.generate(
                          100,
                          (index) => <String, dynamic>{
                                'id': index,
                                'a': 'A $index',
                                'b': 'B $index',
                                'c': 'C $index',
                                'd': 'D $index',
                                'e': 'E $index'
                              });
                    }), TypeSelect.SIMPLE,
                        theme: const SelectModelTheme(
                            tableTheme: SelectModelThemeTable(
                                headerColor: Colors.blue))))));
      },
      child: const Icon(Icons.navigation),
    );
  }
}
