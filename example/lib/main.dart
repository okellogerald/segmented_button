import 'package:flutter/material.dart';
import 'package:segmented_button/material_segmented_button.dart';
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
        fontFamily: "Circular",
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialSegmentedButton<String>(
                tabs: const ["Team", "Work", "Play", "Family"],
                onTap: (p0) {},
                childBuilder: (tab, index, selected) {
                  return Text(
                    tab,
                    style: TextStyle(
                      color: selected ? Colors.orange : Colors.black,
                      fontSize: 16,
                    ),
                  );
                },
                initialTabIndex: 0,
                expandedToFillWidth: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
