import 'dart:developer';
import 'dart:io' as io show Directory, File;

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:desktop_drop/desktop_drop.dart' show DropTarget;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// ignore: implementation_imports
import 'package:flutter_quill_extensions/src/editor/image/widgets/image.dart'
    show getImageProviderByImageSource, imageFileExtensions;
import 'package:path/path.dart' as path;
import 'package:test_flutter_quill/embeds/timestamp_embed.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ImageProviderBuilder = ImageProvider Function(
  BuildContext context,
  String imageSource,
);

class CustomImageEmbedBuilder implements EmbedBuilder {
  CustomImageEmbedBuilder({
    this.imageProviderBuilder,
    this.onImageTap,
  });

  final ImageProviderBuilder? imageProviderBuilder;
  final void Function(String imageUrl)? onImageTap;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, QuillController controller, Embed node,
      bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data as String;
    final attributes = node.style.attributes;
    final link = attributes['link']?.value as String?;

    // Construir el widget de imagen con soporte para caché
    Widget imageWidget;
    if (isHttpBasedUrl(imageUrl)) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        errorWidget: (context, url, error) => Text(
          'Error while loading image: ${error.toString()}',
        ),
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: CircularProgressIndicator(value: progress.progress),
        ),
      );
    } else {
      final provider = imageProviderBuilder?.call(context, imageUrl) ??
          getImageProviderByImageSource(
            imageUrl,
            imageProviderBuilder: null,
            context: context,
            assetsPrefix:
                QuillSharedExtensionsConfigurations.get(context: context)
                    .assetsPrefix,
          );

      imageWidget = Image(image: provider);
    }

    log('Link es: $link');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: link != null
            ? () async {
                try {
                  final uri = Uri.parse(link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                } catch (e) {
                  debugPrint('Error launching URL: $e');
                }
              }
            : () => onImageTap?.call(imageUrl),
        child: imageWidget,
      ),
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    // TODO: implement buildWidgetSpan
    throw UnimplementedError();
  }

  @override
  // TODO: implement expanded
  bool get expanded => throw UnimplementedError();

  @override
  String toPlainText(Embed node) {
    // TODO: implement toPlainText
    throw UnimplementedError();
  }
}

class MyQuillEditor extends StatelessWidget {
  const MyQuillEditor({
    required this.controller,
    required this.configurations,
    required this.scrollController,
    required this.focusNode,
    super.key,
  });

  final QuillController controller;
  final QuillEditorConfigurations configurations;
  final ScrollController scrollController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    return QuillEditor(
      scrollController: scrollController,
      focusNode: focusNode,
      controller: controller,
      configurations: configurations.copyWith(
        elementOptions: const QuillEditorElementOptions(
          codeBlock: QuillEditorCodeBlockElementOptions(
            enableLineNumbers: true,
          ),
          orderedList: QuillEditorOrderedListElementOptions(),
          unorderedList: QuillEditorUnOrderedListElementOptions(
            useTextColorForDot: true,
          ),
        ),
        customStyles: DefaultStyles(
          h1: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            HorizontalSpacing.zero,
            const VerticalSpacing(16, 0),
            VerticalSpacing.zero,
            null,
          ),
          sizeSmall: defaultTextStyle.style.copyWith(fontSize: 9),
        ),
        scrollable: true,
        placeholder: 'Start writing your notes...',
        padding: const EdgeInsets.all(16),
        onImagePaste: (imageBytes) async {
          if (kIsWeb) {
            return null;
          }
          // We will save it to system temporary files
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
        onGifPaste: (gifBytes) async {
          if (kIsWeb) {
            return null;
          }
          // We will save it to system temporary files
          final newFileName = 'gifFile-${DateTime.now().toIso8601String()}.gif';
          final newPath = path.join(
            io.Directory.systemTemp.path,
            newFileName,
          );
          final file = await io.File(
            newPath,
          ).writeAsBytes(gifBytes, flush: true);
          return file.path;
        },
        embedBuilders: [
          ...FlutterQuillEmbeds.editorWebBuilders(),
          CustomImageEmbedBuilder(
            imageProviderBuilder: (context, imageUrl) {
              log('imageProviderBuilder');

              //TODO: Aquí se puede integrar alguna lógica para poder guardar la imagen en el S3
              if (isAndroidApp || isIosApp || kIsWeb) {
                if (isHttpBasedUrl(imageUrl)) {
                  return CachedNetworkImageProvider(imageUrl);
                }
              }
              return getImageProviderByImageSource(
                imageUrl,
                imageProviderBuilder: null,
                context: context,
                assetsPrefix: QuillSharedExtensionsConfigurations.get(
                  context: context,
                ).assetsPrefix,
              );
            },
            onImageTap: (imageUrl) {
              // Manejo opcional del tap cuando no hay enlace
              log('Image tapped: $imageUrl');
            },
          ),
          TimeStampEmbedBuilderWidget(),
        ],
        builder: (context, rawEditor) {
          // The `desktop_drop` plugin doesn't support iOS platform for now
          if (isIosApp) {
            return rawEditor;
          }

          return DropTarget(
            onDragDone: (details) {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final file = details.files.first;
              final isSupported = imageFileExtensions.any(file.name.endsWith);

              if (!isSupported) {
                // scaffoldMessenger.showText(
                //   'Only images are supported right now: ${file.mimeType}, ${file.name}, ${file.path}, $imageFileExtensions',
                // );
                return;
              }

              context.requireQuillController.insertImageBlock(
                imageSource: file.path,
              );
              // scaffoldMessenger.showText('Image is inserted.');
            },
            child: rawEditor,
          );
        },
      ),
    );
  }
}
