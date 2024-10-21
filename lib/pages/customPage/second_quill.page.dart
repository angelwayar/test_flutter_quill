import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:test_flutter_quill/widgets/custom_toolbar.widget.dart';

import '../../widgets/custom_editor.widget.dart';

class SecondQuillPage extends StatefulWidget {
  const SecondQuillPage({super.key});

  @override
  State<SecondQuillPage> createState() => _SecondQuillPageState();
}

class _SecondQuillPageState extends State<SecondQuillPage> {
  final editorFocusNode = FocusNode();
  final controller = QuillController.basic();
  final editorScrollController = ScrollController();

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
          CustomToolbar(controller: controller, focusNode: editorFocusNode),
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
        ],
      ),
    );
  }
}
