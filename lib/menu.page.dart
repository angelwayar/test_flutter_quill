import 'package:flutter/material.dart';

import 'pages/customPage/second_quill.page.dart';
import 'pages/firts_quill.page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FirstQuillPage(),
                ),
              );
            },
            child: const Text('Primer Editor Con Quill'),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SecondQuillPage(),
                ),
              );
            },
            child: const Text('Segundo Editor Con Quill'),
          ),
        ],
      ),
    );
  }
}
