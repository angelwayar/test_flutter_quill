import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:test_flutter_quill/constants/font_family.constant.dart';
import 'package:test_flutter_quill/constants/font_sizes.constant.dart';

class CustomToolbar extends StatelessWidget {
  const CustomToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final FocusNode focusNode;
  final QuillController controller;

  Future<String?> processImage(String imagePath) async {
    try {
      // Si la imagen ya es una URL válida, retornarla
      if (imagePath.startsWith('http') || imagePath.startsWith('blob:')) {
        return imagePath;
      }

      // Si es un archivo local, convertirlo a blob URL
      final file = html.File([await readFileBytes(imagePath)], 'image.jpg');
      final blobUrl = html.Url.createObjectUrlFromBlob(file);
      return blobUrl;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  Future<List<int>> readFileBytes(String filePath) async {
    // Implementar la lectura del archivo según tu necesidad
    throw UnimplementedError('Implement file reading');
  }

  Future<void> onImageInsertWithCropping(
    image,
    QuillController controller,
    BuildContext context,
  ) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      uiSettings: [
        WebUiSettings(context: context),
      ],
    );
    if (croppedFile?.path == null) return;

    // Procesar la imagen cropped
    final processedImageUrl = await processImage(croppedFile!.path);
    if (processedImageUrl == null) return;

    //TODO: Se debe de insertar al url
    // final url = await customShowDialog(context);

    // Insertar la imagen en el editor
    final index = controller.selection.baseOffset;
    controller.replaceText(
      index,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 1),
    );

    controller.replaceText(
      index + 1,
      0,
      BlockEmbed.image(processedImageUrl),
      TextSelection.collapsed(offset: index + 2),
    );

    controller.replaceText(
      index + 2,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QuillToolbar.simple(
      controller: controller,
      configurations: QuillSimpleToolbarConfigurations(
        fontFamilyValues: fontFamilyValues,
        fontSizesValues: fontSizesValues,
        embedButtons: FlutterQuillEmbeds.toolbarButtons(
          imageButtonOptions: QuillToolbarImageButtonOptions(
            imageButtonConfigurations: QuillToolbarImageConfigurations(
              onImageInsertCallback: (image, controller) =>
                  onImageInsertWithCropping(
                image,
                controller,
                context,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
