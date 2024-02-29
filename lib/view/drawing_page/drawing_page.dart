import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sketch_app/models/models.dart';
import 'package:sketch_app/utils/app_colors.dart';
import 'package:sketch_app/view/drawing_canvas/widgets/widgets.dart';
import '../drawing_canvas/drawing_canvas.dart';


class DrawingPage extends HookWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(5);
    final eraserSize = useState<double>(15);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: AppColors.white,
              width: double.maxFinite,
              height: double.maxFinite,
              child: DrawingCanvas(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                sideBarController: animationController,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
              ),
            ),
            Positioned(
              top: kToolbarHeight + 10,
              // left: -5,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animationController),
                child: CanvasSideBar(
                  drawingMode: drawingMode,
                  selectedColor: selectedColor,
                  strokeSize: strokeSize,
                  eraserSize: eraserSize,
                  currentSketch: currentSketch,
                  allSketches: allSketches,
                  // canvasGlobalKey: canvasGlobalKey,
                  filled: filled,
                  polygonSides: polygonSides,
                ),
              ),
            ),
            CustomAppBar(
              animationController: animationController,
              drawingMode: drawingMode,
              currentSketch: currentSketch,
              allSketches: allSketches,
              canvasGlobalKey: canvasGlobalKey,
            ),
          ],
        ),
      ),
    );
  }
}