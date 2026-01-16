import 'dart:io';
import 'package:flutter/material.dart';
import '../controller/add_product_controller.dart';

class AddProductMediaInfo extends StatelessWidget {
  final AddProductController controller;
  const AddProductMediaInfo({super.key, required this.controller});

  // -------------------- UI HELPERS --------------------

  InputDecoration inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
      ),
    );
  }


  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  // -------------------- IMAGE TILE --------------------

  Widget imageTile(BuildContext context, int index) {
    final img = controller.productImages[index];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(img.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        /// Remove Image
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => controller.removeImage(index),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),

        /// Set Thumbnail
        Positioned(
          bottom: 4,
          left: 4,
          child: InkWell(
            onTap: () => controller.setThumbnail(index),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: controller.thumbnailIndex == index
                  ? Colors.green
                  : Colors.black54,
              child: const Icon(Icons.star, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller, // 🔥 Listens to notifyListeners()
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text('Add Product – Media & Details')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ---------- THUMBNAIL ----------
                label('Thumbnail Image *'),
                GestureDetector(
                  onTap: controller.pickThumbnailImage,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: controller.thumbnailImage == null
                        ? const Center(
                      child: Icon(Icons.image, size: 40),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(controller.thumbnailImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- PRODUCT IMAGES ----------
                label('Product Images *'),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                  onPressed: controller.pickProductImages,
                ),

                const SizedBox(height: 10),

                if (controller.productImages.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.productImages.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) =>
                        imageTile(context, index),
                  ),

                const SizedBox(height: 20),

                // ---------- EXTRA INFO ----------
                label('Product Tags'),
                TextFormField(
                  controller: controller.tagsController,
                  decoration: inputDec('Comma separated tags'),
                ),

                const SizedBox(height: 16),

                label('Weight'),
                TextFormField(
                  controller: controller.weightController,
                  decoration: inputDec('e.g. 500g / 1kg'),
                ),

                const SizedBox(height: 16),

                label('Dimensions'),
                TextFormField(
                  controller: controller.dimensionsController,
                  decoration: inputDec('L × W × H'),
                ),

                const SizedBox(height: 16),

                label('Warranty Information'),
                TextFormField(
                  controller: controller.warrantyController,
                  decoration: inputDec('Warranty details'),
                ),

                const SizedBox(height: 16),

                label('SEO / Admin Notes'),
                TextFormField(
                  controller: controller.seoController,
                  decoration: inputDec('Optional'),
                ),

                const SizedBox(height: 24),

                // ---------- SUBMIT ----------
                FilledButton(
                  onPressed: () {
                    if (controller.thumbnailImage == null ||
                        controller.productImages.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Images required')),
                      );
                      return;
                    }

                    controller.submitProduct();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  child: const Text('Submit Product'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
