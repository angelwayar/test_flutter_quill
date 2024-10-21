import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:test_flutter_quill/widgets/my_quill_editor.widget.dart';

class CustomEditor extends StatelessWidget {
  const CustomEditor({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.configurations,
    required this.scrollController,
  });

  final FocusNode focusNode;
  final QuillController controller;
  final ScrollController scrollController;
  final QuillEditorConfigurations configurations;

  ImageProvider getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('blob:')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('data:')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      // Si es una ruta relativa, convertir a URL completa
      return NetworkImage('http://localhost:33671/$imageUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      focusNode: focusNode,
      controller: controller,
      configurations: configurations.copyWith(
        embedBuilders: [
          ...FlutterQuillEmbeds.editorWebBuilders(),
          CustomImageEmbedBuilder(
            imageProviderBuilder: (context, imageUrl) {
              try {
                return getImageProvider(imageUrl);
              } catch (e) {
                log('Error loading image: $e');
                // Retornar una imagen de placeholder o manejar el error
                return const AssetImage('assets/placeholder.png');
              }
            },
          ),
          //TODO: Esto puede servir para imagenes de internet
          // CustomImageEmbedBuilder(
          //   imageProviderBuilder: (context, imageUrl) {
          //     return getImageProviderByImageSource(
          //       imageUrl,
          //       context: context,
          //       imageProviderBuilder: null,
          //       assetsPrefix: QuillSharedExtensionsConfigurations.get(
          //         context: context,
          //       ).assetsPrefix,
          //     );
          //   },
          // ),
        ],
      ),
      scrollController: scrollController,
    );
  }
}
