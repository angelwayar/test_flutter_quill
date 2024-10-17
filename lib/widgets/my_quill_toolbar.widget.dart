import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;

import '../cubits/settings/settings_cubit.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

// import '../settings/cubit/settings_cubit.dart';
// import 'embeds/timestamp_embed.dart';

// Primero, creamos un custom embed para manejar imágenes con enlaces
class LinkedImageEmbed extends CustomBlockEmbed {
  const LinkedImageEmbed(this.value) : super('linked-image', value);

  final String value;

  static LinkedImageEmbed fromDocument(Document document) =>
      LinkedImageEmbed(jsonEncode(document.toDelta().toJson()));

  String get imageUrl => (json.decode(value) as Map)['image'] as String;
  String? get link => (json.decode(value) as Map)['link'] as String?;
}

// Custom Embed Builder para renderizar las imágenes con enlaces
// class LinkedImageEmbedBuilder extends EmbedBuilder {
//   LinkedImageEmbedBuilder({required this.onImageTap});

//   final Function(String? url)? onImageTap;

//   @override
//   String get key => 'linked-image';

//   @override
//   Widget build(
//     BuildContext context,
//     QuillController controller,
//     Embed node,
//     bool readOnly,
//     bool inline,
//     TextStyle textStyle,
//   ) {
//     final imageData = json.decode(node.value.data) as Map;
//     final imageUrl = imageData['image'] as String;
//     final link = imageData['link'] as String?;

//     return MouseRegion(
//       cursor:
//           link != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
//       child: GestureDetector(
//         onTap: link != null ? () => onImageTap?.call(link) : null,
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.contain,
//         ),
//       ),
//     );
//   }
// }

class MyQuillToolbar extends StatelessWidget {
  const MyQuillToolbar({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final QuillController controller;
  final FocusNode focusNode;

  Future<void> onImageInsertWithCropping(
    String image,
    QuillController controller,
    BuildContext context,
  ) async {
    log('onImageInsertWithCropping');
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image,
        uiSettings: [
          WebUiSettings(context: context),
        ],
      );

      final newImage = croppedFile?.path;
      if (newImage == null) {
        return;
      }
      
      //TODO: Llamar al endpoint para guardar la imagen S3


      final url = await showDialog<String>(
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
                  Navigator.pop(context, url);
                },
                child: const Text('Insert'),
              ),
            ],
          );
        },
      );

      String newPath = newImage.replaceFirst("blob:", "");
      // Codificar la imagen y el enlace en un solo string JSON
      final imageData = jsonEncode({
        'path': newPath,
        'link': url,
      });

      // Insertar la imagen con el enlace usando una sola clave
      final delta = Delta()
        ..insert('\n')
        ..insert({'image': imageData}) // Usar 'image' como única clave
        ..insert('\n');

      controller.compose(
        delta,
        TextSelection.collapsed(offset: delta.length),
        ChangeSource.local,
      );
    } catch (error) {
      log('Error inserting image: $error');
      throw Exception('Error al insertar la imagen');
    }
  }

  Future<void> onImageInsert(String image, QuillController controller) async {
    log('onImageInsert');
    if (kIsWeb || isHttpBasedUrl(image)) {
      controller.insertImageBlock(imageSource: image);
      return;
    }
    final newSavedImage = await saveImage(io.File(image));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  /// For mobile platforms it will copies the picked file from temporary cache
  /// to applications directory
  ///
  /// for desktop platforms, it will do the same but from user files this time
  Future<String> saveImage(io.File file) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileExt = path.extension(file.path);
    final newFileName = '${DateTime.now().toIso8601String()}$fileExt';
    final newPath = path.join(
      appDocDir.path,
      newFileName,
    );
    final copiedFile = await file.copy(newPath);
    return copiedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return QuillToolbar.simple(
      controller: controller,

      /// configurations parameter:
      ///   Optional: if not provided will use the configuration set when the controller was instantiated.
      ///   Override: Provide parameter here to override the default configuration - useful if configuration will change.
      configurations: QuillSimpleToolbarConfigurations(
        showAlignmentButtons: true,
        multiRowsDisplay: true,
        fontFamilyValues: {
          'Amatic': GoogleFonts.amaticSc().fontFamily!,
          'Annie': GoogleFonts.annieUseYourTelescope().fontFamily!,
          'Formal': GoogleFonts.petitFormalScript().fontFamily!,
          'Roboto': GoogleFonts.roboto().fontFamily!
        },
        fontSizesValues: const {
          '14': '14.0',
          '16': '16.0',
          '18': '18.0',
          '20': '20.0',
          '22': '22.0',
          '24': '24.0',
          '26': '26.0',
          '28': '28.0',
          '30': '30.0',
          '35': '35.0',
          '40': '40.0'
        },
        searchButtonType: SearchButtonType.modern,
        customButtons: [
          QuillToolbarCustomButtonOptions(
            icon: const Icon(Icons.add_alarm_rounded),
            onPressed: () {
              controller.document
                  .insert(controller.selection.extentOffset, '\n');
              controller.updateSelection(
                TextSelection.collapsed(
                  offset: controller.selection.extentOffset + 1,
                ),
                ChangeSource.local,
              );

              // controller.document.insert(
              //   controller.selection.extentOffset,
              //   TimeStampEmbed(
              //     DateTime.now().toString(),
              //   ),
              // );

              controller.updateSelection(
                TextSelection.collapsed(
                  offset: controller.selection.extentOffset + 1,
                ),
                ChangeSource.local,
              );

              controller.document
                  .insert(controller.selection.extentOffset, ' ');
              controller.updateSelection(
                TextSelection.collapsed(
                  offset: controller.selection.extentOffset + 1,
                ),
                ChangeSource.local,
              );

              controller.document
                  .insert(controller.selection.extentOffset, '\n');
              controller.updateSelection(
                TextSelection.collapsed(
                  offset: controller.selection.extentOffset + 1,
                ),
                ChangeSource.local,
              );
            },
          ),
          QuillToolbarCustomButtonOptions(
            icon: const Icon(Icons.dashboard_customize),
            onPressed: () {
              // context.read<SettingsCubit>().updateSettings(
              //     state.copyWith(useCustomQuillToolbar: true));
            },
          ),
        ],
        embedButtons: FlutterQuillEmbeds.toolbarButtons(
          imageButtonOptions: QuillToolbarImageButtonOptions(
            imageButtonConfigurations: QuillToolbarImageConfigurations(
              onImageInsertCallback: isAndroidApp || isIosApp || kIsWeb
                  ? (image, controller) =>
                      onImageInsertWithCropping(image, controller, context)
                  : onImageInsert,
            ),
          ),
        ),
      ),
    );
  }
}
