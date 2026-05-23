import 'package:fitness/Screens/FoodBarcode/food_data.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FoodBarcode extends StatefulWidget {
  const FoodBarcode({super.key});

  @override
  State<FoodBarcode> createState() => _FoodBarcodeState();
}

class _FoodBarcodeState extends State<FoodBarcode> {
  String? lastBarcode;
  Map<String, dynamic> productDetails = {};

  Widget _buildCorner({required bool top, required bool left}) {
    const double cornerSize = 30;
    const double thickness = 4;

    return SizedBox(
      width: cornerSize,
      height: cornerSize,
      child: CustomPaint(
        painter: CornerPainter(
          top: top,
          left: left,
          color: StandardData.primaryColor,
          thickness: thickness,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> getProduct(String barcode) async {
      final ProductQueryConfiguration config = ProductQueryConfiguration(
        barcode,
        version: ProductQueryVersion.v3,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: [ProductField.ALL],
      );

      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        config,
      );

      if (result.status == ProductResultV3.statusFailure) {
        setState(() {
          productDetails = {};
          productDetails['status'] = 'Product not found!';
        });
      } else {
        setState(() {
          productDetails['status'] = 'Product found!';
          productDetails['name'] = result.product?.productName ?? 'Unknown';
          productDetails['brand'] = result.product?.brands ?? 'Unknown';
          productDetails['category'] = result.product?.categories ?? 'Unknown';
          productDetails['image'] = result.product?.imageFrontUrl ?? 'Unknown';
          productDetails['serving_size'] =
              result.product?.servingSize ?? 'null';
          productDetails['serving_quantity'] =
              result.product?.servingQuantity ?? 'null';
          productDetails['protein'] =
              result.product?.nutriments?.getValue(
                Nutrient.proteins,
                PerSize.oneHundredGrams,
              ) ??
              'null';
          productDetails['carbs'] =
              result.product?.nutriments?.getValue(
                Nutrient.carbohydrates,
                PerSize.oneHundredGrams,
              ) ??
              'null';
          productDetails['fat'] =
              result.product?.nutriments?.getValue(
                Nutrient.fat,
                PerSize.oneHundredGrams,
              ) ??
              'null';
          productDetails['sugar'] =
              result.product?.nutriments?.getValue(
                Nutrient.sugars,
                PerSize.oneHundredGrams,
              ) ??
              'null';
        });
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodData(product: productDetails),
        ),
      ).then((_) {
        setState(() {
          lastBarcode = null;
        });
      });
    }

    final size = MediaQuery.of(context).size;
    final scanWidth = size.width * 0.8;
    final scanHeight = 300.0;
    final double left = (size.width - scanWidth) / 2;
    final double top = (size.height - scanHeight) / 2;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanWidth,
      height: scanHeight,
    );

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            scanWindow: Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: size.width * 0.8,
              height: 300,
            ),
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                if (lastBarcode == barcodes.first.rawValue) {
                  return;
                }
                lastBarcode = barcodes.first.rawValue;
                getProduct(barcodes.first.rawValue!);
              }
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top,
            child: Container(color: Colors.black.withAlpha(200)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: top,
            child: Container(color: Colors.black.withAlpha(200)),
          ),
          Positioned(
            top: top,
            left: 0,
            width: left,
            height: scanHeight,
            child: Container(color: Colors.black.withAlpha(200)),
          ),
          Positioned(
            top: top,
            right: 0,
            width: left,
            height: scanHeight,
            child: Container(color: Colors.black.withAlpha(200)),
          ),
          Positioned(
            top: scanRect.top,
            left: scanRect.left,
            child: _buildCorner(top: true, left: true),
          ),

          Positioned(
            top: scanRect.top,
            right: size.width - scanRect.right,
            child: _buildCorner(top: true, left: false),
          ),

          Positioned(
            bottom: size.height - scanRect.bottom,
            left: scanRect.left,
            child: _buildCorner(top: false, left: true),
          ),

          Positioned(
            bottom: size.height - scanRect.bottom,
            right: size.width - scanRect.right,
            child: _buildCorner(top: false, left: false),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_new),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.flash_off)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    "Scan Food Barcode",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: StandardData.primaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.65,
                ),
                child: Center(
                  child: Text(
                    "Fitness App",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: StandardData.primaryColor,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color color;
  final double thickness;

  CornerPainter({
    required this.top,
    required this.left,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();

    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
