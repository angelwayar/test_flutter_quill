import 'dart:io' as io show Directory, File;
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:test_flutter_quill/embeds/timestamp_embed.dart';
import 'package:flutter_quill_extensions/src/editor/image/widgets/image.dart'
    show getImageProviderByImageSource, imageFileExtensions;
import 'package:path/path.dart' as path;

class EmdedsPage extends StatefulWidget {
  const EmdedsPage({
    super.key,
    required this.deltaJson,
  });

  final dynamic deltaJson;

  @override
  State<EmdedsPage> createState() => _EmdedsPageState();
}

class _EmdedsPageState extends State<EmdedsPage> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    log("${widget.deltaJson}");
    var myDelta = Delta.fromJson(widget.deltaJson);
    _controller = QuillController(
      readOnly: true,
      document: Document.fromDelta(myDelta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: QuillEditor(
                controller: _controller,
                scrollController: ScrollController(),
                focusNode: FocusNode(),
                configurations: QuillEditorConfigurations(
                  // readOnly: true,
                  elementOptions: const QuillEditorElementOptions(
                    codeBlock: QuillEditorCodeBlockElementOptions(
                      enableLineNumbers: true,
                    ),
                    orderedList: QuillEditorOrderedListElementOptions(),
                    unorderedList: QuillEditorUnOrderedListElementOptions(
                      useTextColorForDot: true,
                    ),
                  ),
                  scrollable: true,
                  placeholder: 'Start writing your notes...',
                  padding: const EdgeInsets.all(16),
                  onImagePaste: (imageBytes) async {
                    if (kIsWeb) {
                      return null;
                    }
                    final newFileName =
                        'imageFile-${DateTime.now().toIso8601String()}.png';
                    final newPath = path.join(
                      io.Directory.systemTemp.path,
                      newFileName,
                    );
                    final file = await io.File(
                      newPath,
                    ).writeAsBytes(imageBytes, flush: true);
                    return file.path;
                  },
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorWebBuilders(),
                    TimeStampEmbedBuilderWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
