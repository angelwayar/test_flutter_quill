import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart' as path;
import 'package:test_flutter_quill/embeds/timestamp_embed.dart';

import '../../entities/post.entity.dart';
import '../../widgets/social_divider.widget.dart';

class ViewSecondQuillPage extends StatefulWidget {
  const ViewSecondQuillPage({
    super.key,
    required this.data,
  });

  final PostEntity data;

  @override
  State<ViewSecondQuillPage> createState() => _ViewSecondQuillPageState();
}

class _ViewSecondQuillPageState extends State<ViewSecondQuillPage> {
  late final QuillController controller;

  @override
  void initState() {
    super.initState();
    final contentInJson = jsonDecode(widget.data.localizedContent![0].content!);
    log('El valor que llega es: $contentInJson');
    log('El tipo del valor que llega es: ${contentInJson.runtimeType}');
    var myDelta = Delta.fromJson(contentInJson);
    log('El tipo del valor que llega es: ${contentInJson.runtimeType}');
    controller = QuillController(
      readOnly: true,
      document: Document.fromDelta(myDelta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF0A0F14),
      appBar: AppBar(
        title: const Text('Second Quill'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 156.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.data.localizedContent![0].title!,
              style: const TextStyle(
                fontSize: 42.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32.0),
            //TODO: Se debe de agregar la imagen para si visualización la primera imagen del array
            const SizedBox(height: 32.0),
            Text(
              widget.data.localizedContent![0].description!,
              style: const TextStyle(
                fontSize: 22.0,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 32.0),
            const SocialDivider(),
            const SizedBox(height: 32.0),
            Expanded(
              child: QuillEditor(
                controller: controller,
                focusNode: FocusNode(),
                scrollController: ScrollController(),
                configurations: QuillEditorConfigurations(
                  customStyles: const DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(color: Colors.white),
                      HorizontalSpacing(0, 0),
                      VerticalSpacing(0, 0),
                      VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
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
                    ).writeAsBytes(
                      imageBytes,
                      flush: true,
                    );

                    return file.path;
                  },
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorWebBuilders(),
                    TimeStampEmbedBuilderWidget(),
                  ],
                ),
              ),
            ),
            const SocialDivider(),
            const SizedBox(height: 32.0),
            //TODO: Se debe de agregar la imagen para si visualización la segunda imagen del array
          ],
        ),
      ),
    );
  }
}
