import 'package:flutter/material.dart';
import 'package:segmented_button/segmented_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.blue.withOpacity(.3),
              child: SegmentedButton<String>(
                tabs: const ["Team", "Work", "Play", "Family"],
                onTap: (p0) {},
                childBuilder: (tab, index, selected) {
                  return Text(
                    tab,
                    style: TextStyle(
                      color: selected ? Colors.orange : Colors.black,
                      fontSize: 20,
                    ),
                  );
                },
                initialTabIndex: 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
