import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tringo_vendor/Core/Utility/app_textstyles.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isTorchOn = false;

  final _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _handled = false;
  final ImagePicker _picker = ImagePicker();

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(value);
  }

  Future<void> _pickImageAndAnalyze() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final result = await _controller.analyzeImage(image.path);

      if (result == null || result.barcodes.isEmpty) {
        _showError("Unable to recognise a valid code from uploaded image.");
        return;
      }

      final barcode = result.barcodes.first;
      final value = barcode.rawValue;

      if (value == null || value.isEmpty) {
        _showError("Unable to recognise a valid code from uploaded image.");
        return;
      }

      Navigator.of(context).pop(value);
    } catch (e) {
      _showError("Unable to process this image.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Colored-corner scan frame
          Center(
            child: Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: CustomPaint(painter: _FramePainter()),
            ),
          ),

          // Upload from gallery button
          Align(
            alignment: Alignment(0, 0.6),
            child: ElevatedButton.icon(
              onPressed: _pickImageAndAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: Icon(Icons.image, color: Colors.white70),
              label: Text(
                "Upload from gallery",
                style: AppTextStyles.mulish(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: _isTorchOn ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.flash_on,
                        color: _isTorchOn ? Colors.black : Colors.white,
                      ),
                      onPressed: () async {
                        await _controller.toggleTorch();
                        setState(() {
                          _isTorchOn = !_isTorchOn; // manually flip torch state
                        });
                      },
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.qr_code_2, color: Colors.white),
                    onPressed: _pickImageAndAnalyze,
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Bottom Info Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Scan any QR code to pay",
                    style: AppTextStyles.mulish(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Google Pay • PhonePe • PayTM • UPI",
                    style: AppTextStyles.mulish(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Corner painter (already fixed for double types)
class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40.0;

    final corners = [
      [Colors.red, const Offset(0, 0)],
      [Colors.orange, Offset(size.width, 0)],
      [Colors.blue, Offset(0, size.height)],
      [Colors.green, Offset(size.width, size.height)],
    ];

    for (var i = 0; i < corners.length; i++) {
      paint.color = corners[i][0] as Color;
      final offset = corners[i][1] as Offset;

      final bool isRight = offset.dx > 0;
      final bool isBottom = offset.dy > 0;

      final double x = isRight ? size.width : 0.0;
      final double y = isBottom ? size.height : 0.0;
      final double horizontalStartX = isRight
          ? x - cornerLength
          : x + cornerLength;
      final double verticalStartY = isBottom
          ? y - cornerLength
          : y + cornerLength;

      canvas.drawLine(Offset(horizontalStartX, y), Offset(x, y), paint);
      canvas.drawLine(Offset(x, verticalStartY), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
