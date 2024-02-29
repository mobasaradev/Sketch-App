import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sketch_app/view/drawing_canvas/widgets/widgets.dart';
import 'package:universal_html/html.dart' as html;

import '../../../controller/undo_redo.dart';
import '../../../models/models.dart';

class CustomAppBar extends HookWidget {
  const CustomAppBar({
    super.key,
    required this.currentSketch,
    required this.allSketches,
    required this.drawingMode,
    required this.animationController,
    required this.canvasGlobalKey,
  });
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    final undoRedoStack = useState(
      UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              icon: const Icon(Icons.menu),
            ),
            const Text(
              'Sketch App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: allSketches.value.isNotEmpty
                      ? () => undoRedoStack.value.undo()
                      : null,
                  icon: const Icon(Icons.undo),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: undoRedoStack.value.canRedo,
                  builder: (_, canRedo, __) {
                    return IconButton(
                      onPressed:
                          canRedo ? () => undoRedoStack.value.redo() : null,
                      icon: const Icon(Icons.redo),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => undoRedoStack.value.clear(),
                  child: const Icon(Icons.cleaning_services),
                ),
                const SizedBox(width: 7),
                IconBox(
                  iconData: FontAwesomeIcons.eraser,
                  selected: drawingMode.value == DrawingMode.eraser,
                  onTap: () => drawingMode.value = DrawingMode.eraser,
                  tooltip: 'Eraser',
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(
                        double.infinity,
                        120,
                        0,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 140,
                                child: TextButton(
                                  child: const Text('Export as PNG'),
                                  onPressed: () async {
                                    Uint8List? pngBytes = await getBytes();
                                    if (pngBytes != null) {
                                      saveFile(pngBytes, 'png');
                                    }
                                  },
                                ),
                              ),
                              const Divider(),
                              SizedBox(
                                width: 140,
                                child: TextButton(
                                  child: const Text('Export as JPEG'),
                                  onPressed: () async {
                                    Uint8List? pngBytes = await getBytes();
                                    if (pngBytes != null) {
                                      saveFile(pngBytes, 'jpeg');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void saveFile(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      html.AnchorElement()
        ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
        ..download =
            'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
        ..style.display = 'none'
        ..click();
    } else {
      await FileSaver.instance.saveFile(
        name: 'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension',
        bytes: bytes,
        ext: extension,
        mimeType: extension == 'png' ? MimeType.png : MimeType.jpeg,
      );
    }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(decodeImageFromList(bytes));
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(
          decodeImageFromList(bytes),
        );
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  Future<Uint8List?> getBytes() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}
