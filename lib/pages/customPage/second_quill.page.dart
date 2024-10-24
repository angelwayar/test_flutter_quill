import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:test_flutter_quill/entities/post.entity.dart';
import 'package:test_flutter_quill/widgets/custom_toolbar.widget.dart';

import '../../widgets/custom_editor.widget.dart';
import 'view_second_quill.page.dart';

class SecondQuillPage extends StatefulWidget {
  const SecondQuillPage({super.key});

  @override
  State<SecondQuillPage> createState() => _SecondQuillPageState();
}

class _SecondQuillPageState extends State<SecondQuillPage> {
  var deltaJson;
  final editorFocusNode = FocusNode();
  final controller = QuillController.basic();
  final editorScrollController = ScrollController();

  @override
  void initState() {
    controller.addListener(() {
      deltaJson = controller.document.toDelta().toJson();
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    editorFocusNode.dispose();
    editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Quill'),
      ),
      body: Column(
        children: [
          CustomToolbar(
            controller: controller,
            focusNode: editorFocusNode,
          ),
          Builder(
            builder: (context) {
              return Expanded(
                child: CustomEditor(
                  controller: controller,
                  focusNode: editorFocusNode,
                  scrollController: editorScrollController,
                  configurations: const QuillEditorConfigurations(),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              final deltaJsonToStrin = jsonEncode(deltaJson);
              postEntity.localizedContent![0].content = deltaJsonToStrin;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewSecondQuillPage(data: postEntity),
                ),
              );
            },
            child: const Text('Preview'),
          ),
          const SizedBox(height: 125.0),
        ],
      ),
    );
  }
}
