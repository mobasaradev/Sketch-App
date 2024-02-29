import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import '../../../models/models.dart';
import 'widgets.dart';

class CanvasSideBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;

  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.filled,
    required this.polygonSides,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    return Container(
      width: 120,
      height: MediaQuery.of(context).size.height < 680 ? 450 : 610,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          controller: scrollController,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Shapes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              runSpacing: 5,
              children: [
                IconBox(
                  iconData: FontAwesomeIcons.pencil,
                  selected: drawingMode.value == DrawingMode.pencil,
                  onTap: () => drawingMode.value = DrawingMode.pencil,
                  tooltip: 'Pencil',
                ),
                IconBox(
                  selected: drawingMode.value == DrawingMode.line,
                  onTap: () => drawingMode.value = DrawingMode.line,
                  tooltip: 'Line',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 2,
                        color: drawingMode.value == DrawingMode.line
                            ? Colors.grey[900]
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
                IconBox(
                  iconData: Icons.hexagon_outlined,
                  selected: drawingMode.value == DrawingMode.polygon,
                  onTap: () => drawingMode.value = DrawingMode.polygon,
                  tooltip: 'Polygon',
                ),
                IconBox(
                  iconData: FontAwesomeIcons.square,
                  selected: drawingMode.value == DrawingMode.square,
                  onTap: () => drawingMode.value = DrawingMode.square,
                  tooltip: 'Square',
                ),
                IconBox(
                  iconData: FontAwesomeIcons.circle,
                  selected: drawingMode.value == DrawingMode.circle,
                  onTap: () => drawingMode.value = DrawingMode.circle,
                  tooltip: 'Circle',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Fill Shape: ',
              style: TextStyle(fontSize: 12),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Checkbox(
                value: filled.value,
                onChanged: (val) {
                  filled.value = val ?? false;
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: drawingMode.value == DrawingMode.polygon
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Polygon Sides: ',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          width: 120,
                          child: Slider(
                            value: polygonSides.value.toDouble(),
                            min: 3,
                            max: 8,
                            onChanged: (val) {
                              polygonSides.value = val.toInt();
                            },
                            label: '${polygonSides.value}',
                            divisions: 5,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Colors',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ColorPalette(
              selectedColor: selectedColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Size',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stroke Size: ',
                  style: TextStyle(fontSize: 12),
                ),
                Slider(
                  value: strokeSize.value,
                  min: 0,
                  max: 30,
                  onChanged: (val) {
                    strokeSize.value = val;
                  },
                ),
              ],
            ),
           
            const Divider(),
            Center(
              child: GestureDetector(
                onTap: () => _launchUrl('https://github.com/mobasaradev'),
                child: const Text(
                  'Created by Mobasaradev',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      html.window.open(
        url,
        url,
      );
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    }
  }
}
