import 'dart:developer';

import 'package:flutter/material.dart';

Future<String?> customShowDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (context) {
      String url = '';
      return AlertDialog(
        title: const Text('Insert link for image'),
        content: TextField(
          onChanged: (value) {
            url = value;
            log('la url es: $url');
          },
          decoration: const InputDecoration(hintText: "Enter URL"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, url);
            },
            child: const Text('Insert'),
          ),
        ],
      );
    },
  );
}
