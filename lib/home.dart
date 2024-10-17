import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:test_flutter_quill/embds.dart';

import 'widgets/my_quill_editor.widget.dart';
import 'widgets/my_quill_toolbar.widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var deltaJson;
  final _controller = QuillController.basic();
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      deltaJson = _controller.document.toDelta().toJson();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  QuillSharedConfigurations get _sharedConfigurations {
    return const QuillSharedConfigurations(
      extraConfigurations: {
        QuillSharedExtensionsConfigurations.key:
            QuillSharedExtensionsConfigurations(
          assetsPrefix: 'assets', // Defaults to assets
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyQuillToolbar(
              controller: _controller,
              focusNode: _editorFocusNode,
            ),
            Builder(
              builder: (context) {
                return Expanded(
                  child: MyQuillEditor(
                    controller: _controller,
                    configurations: QuillEditorConfigurations(
                      characterShortcutEvents: standardCharactersShortcutEvents,
                      spaceShortcutEvents: standardSpaceShorcutEvents,
                      searchConfigurations: const QuillSearchConfigurations(
                        searchEmbedMode: SearchEmbedMode.plainText,
                      ),
                      sharedConfigurations: _sharedConfigurations,
                    ),
                    scrollController: _editorScrollController,
                    focusNode: _editorFocusNode,
                  ),
                );
              },
            ),
            const SizedBox(height: 150.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmdedsPage(deltaJson: deltaJson),
                    ));
              },
              child: const Text("Next page"),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}
