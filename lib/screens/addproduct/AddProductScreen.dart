
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/extensions/context_extension.dart';
import 'package:molafzo_vendor/screens/addproduct/model.dart';
import 'package:provider/provider.dart';
import '../../providers/translate_provider.dart';
import 'StoreListScreen.dart';
import 'CategorySelectScreen.dart';
import 'VariantManagerScreen.dart';
import 'contreller.dart';

// AddProductBasicInfonew.dart
class AddProductBasicInfonew extends StatefulWidget {
  final bool editMode;
  final int? productId;
  final AddProductControllernew? controller;
  final int? originalProductIdForCopy; // Add this for copy operations

  const AddProductBasicInfonew({
    Key? key,
    this.editMode = false,
    this.productId,
    this.controller,
    this.originalProductIdForCopy,
  }) : super(key: key);

  @override
  State<AddProductBasicInfonew> createState() => _AddProductBasicInfonewState();
}

class _AddProductBasicInfonewState extends State<AddProductBasicInfonew> {
  late final AddProductControllernew controller;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      // If in edit mode with controller, we need to make sure categories are loaded
      if (widget.editMode && widget.productId != null) {
        // Categories should already be loaded by the controller
        // But we need to ensure the UI updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.notifyListeners();
        });
      }
    } else {
      controller = AddProductControllernew();
      if (widget.editMode && widget.productId != null) {
        controller.loadProductForEdit(widget.productId!);
      } else {
        controller.fetchStores();
        controller.fetchCategories();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AddProductControllernew>(
        builder: (context, c, _) {
          debugPrint('Building UI - isEditMode: ${widget.editMode}, isLoading: ${c.isLoading}, productImages: ${c.productImages.length}');

          if (widget.editMode && c.isLoading) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  widget.editMode ? context.tr('txt_edit_product') : context.tr('txt_add_product'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              body:  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(context.tr('txt_loading_product_data')),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                widget.editMode ? context.tr('txt_edit_product') : context.tr('txt_add_product'),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: c.isSubmitting
                        ? null
                        : () => _submitProduct(context, c),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(70, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: c.isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(widget.editMode ? context.tr('txt_update') : context.tr('txt_submit')),
                  ),
                ),
              ],
            ),            body: Form(
              key: c.formKeyBasic,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImagesSection(c),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(c),
                    const SizedBox(height: 16),
                    _buildStoreSelectionCard(c),
                    const SizedBox(height: 16),
                    _buildCategorySelectionCard(c),
                    const SizedBox(height: 16),
                    _buildPriceSection(c),
                    const SizedBox(height: 16),
                    _buildVariantsSection(c),
                    if (c.combinations.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildCombinationsList(c),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImagesSection(AddProductControllernew c) {
    final bool isNearLimit = c.productImages.length >= AddProductControllernew.MAX_IMAGES - 2;
    final bool isAtLimit = c.productImages.length >= AddProductControllernew.MAX_IMAGES;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                context.tr('txt_product_imagess'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isNearLimit
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${c.productImages.length}/${AddProductControllernew.MAX_IMAGES}',
                  style: TextStyle(
                    color: isNearLimit ? Colors.orange : Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  context.tr('txt_max_each'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Warning message when near limit
          if (isNearLimit && !isAtLimit)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${context.tr('txt_only')} ${AddProductControllernew.MAX_IMAGES - c.productImages.length} ${context.tr('txt_slot')}${(AddProductControllernew.MAX_IMAGES - c.productImages.length) > 1 ? 's' : ''} ${context.tr('txt_remaining')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          if (c.productImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: c.productImages.length + (c.productImages.length < AddProductControllernew.MAX_IMAGES ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == c.productImages.length) {
                  return _buildAddImageButton(c, key: ValueKey('add_button'));
                }
                return _buildImageTileWithDragAndDrop(c, index);
              },
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _buildAddImageButton(c, isLarge: true),
            ),

          const SizedBox(height: 8),
          Text(
            '• ${context.tr('txt_maximum')} ${AddProductControllernew.MAX_IMAGES} ${context.tr('txt_images')}\n'
                '• ${context.tr('txt_each_images_less')} ${AddProductControllernew.MAX_IMAGE_SIZE_MB}MB\n'
                '• ${context.tr('txt_first_image')}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

// Separate method for image tile with drag and drop
  Widget _buildImageTileWithDragAndDrop(AddProductControllernew c, int index) {
    return Draggable<int>(
      data: index,
      feedback: _buildDraggingFeedback(c, index),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildImageTile(c, index),
      ),
      onDragEnd: (details) {
        // Drag ended without dropping on target
      },
      child: DragTarget<int>(
        onAccept: (oldIndex) {
          setState(() {
            if (oldIndex != index) {
              final item = c.productImages.removeAt(oldIndex);
              c.productImages.insert(index, item);

              // Update thumbnail index if needed
              final currentThumbnailIndex = c.thumbnailIndex;
              if (currentThumbnailIndex != null) {
                if (currentThumbnailIndex == oldIndex) {
                  c.thumbnailIndex = index;
                } else if (currentThumbnailIndex > oldIndex && currentThumbnailIndex <= index) {
                  c.thumbnailIndex = currentThumbnailIndex - 1;
                } else if (currentThumbnailIndex < oldIndex && currentThumbnailIndex >= index) {
                  c.thumbnailIndex = currentThumbnailIndex + 1;
                }
              }

              // Update combinations images references
              _updateCombinationImagesReferences(c);
            }
          });
        },
        onWillAccept: (oldIndex) => oldIndex != index,
        builder: (context, candidateData, rejectedData) {
          return _buildImageTile(c, index);
        },
      ),
    );
  }

// Updated add button with tooltip
  Widget _buildAddImageButton(AddProductControllernew c, {bool isLarge = false, Key? key}) {
    final bool isMaxReached = c.productImages.length >= AddProductControllernew.MAX_IMAGES;

    return Tooltip(
      message: isMaxReached
          ? '${context.tr('txt_maximum')} ${AddProductControllernew.MAX_IMAGES} ${context.tr('txt_images_reached')}'
          : '${context.tr('txt_add_images')} (max ${AddProductControllernew.MAX_IMAGE_SIZE_MB}MB ${context.tr('txt_each')})',
      child: GestureDetector(
        key: key,
        onTap: isMaxReached ? null : () => _showImageSourceDialog(c),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(
              color: isMaxReached ? Colors.grey.shade400 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(6),
            color: isMaxReached ? Colors.grey.shade100 : Colors.grey.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isMaxReached ? Icons.block : Icons.add_photo_alternate,
                size: isLarge ? 24 : 18,
                color: isMaxReached ? Colors.grey.shade500 : Colors.black54,
              ),
              if (isLarge) ...[
                const SizedBox(height: 4),
                Text(
                  isMaxReached ? context.tr('txt_max_reached') : context.tr('add_images'),
                  style: TextStyle(
                    color: isMaxReached ? Colors.grey.shade500 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDraggingFeedback(AddProductControllernew c, int index) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(c.productImages[index].path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

// Add this method to get image size display
  Future<String> _getImageSizeDisplay(AddProductControllernew c, int index) async {
    final file = File(c.productImages[index].path);
    final size = await file.length();
    final sizeMB = size / (1024 * 1024);
    return '${sizeMB.toStringAsFixed(1)}MB';
  }

// Update _buildImageTile to show size
  Widget _buildImageTile(AddProductControllernew c, int index) {
    final isThumbnail = c.thumbnailIndex == index;

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, c, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isThumbnail ? Colors.black : Colors.grey.shade200,
            width: isThumbnail ? 2 : 1,

          ),

        ),
        child: Stack(

          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(c.productImages[index].path),
                fit: BoxFit.cover,
              ),
            ),
            if (isThumbnail)
              const Positioned(
                top: 2,
                left: 2,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),

            // Image size indicator
            FutureBuilder<int>(
              future: File(c.productImages[index].path).length(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sizeMB = snapshot.data! / (1024 * 1024);
                  return Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${sizeMB.toStringAsFixed(1)}MB',
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Delete button
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showDeleteImageConfirmation(c, index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),

            // Thumbnail button
            Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  c.setThumbnail(index);
                  // _showSuccessToast('Thumbnail updated');
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isThumbnail ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 0.5),
                  ),
                  child: Icon(
                    Icons.star_border,
                    color: isThumbnail ? Colors.white : Colors.black,
                    size: 14,
                  ),
                ),
              ),
            ),

            // Fullscreen view indicator
            Positioned(
              top: 2,
              right: 30,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),

            // Drag handle indicator
            Positioned(
              bottom: 2,
              left: 30,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(
                  Icons.drag_handle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteImageConfirmation(AddProductControllernew c, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('txt_remove_images'), style: TextStyle(fontSize: 16)),
          content: Text(context.tr('txt_are_you_sure_remove'), style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text(context.tr('txt_cancel'), style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                c.removeImage(index);
                Navigator.pop(context);
                setState(() {});
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(context.tr('txt_remove')),
            ),
          ],
        );
      },
    );
  }

// Helper method to update image references in combinations
  void _updateCombinationImagesReferences(AddProductControllernew c) {
    for (var combo in c.combinations) {
      final updatedImages = <dynamic>[];
      for (var image in combo.images) {
        // Find the updated image reference
        final updatedImage = c.productImages.firstWhere(
              (img) => img.path == image.path,
          orElse: () => image,
        );
        updatedImages.add(updatedImage);
      }
      combo.images.clear();
      // Convert to appropriate type - assuming combo.images expects List<XFile>
      // If combo.images expects a specific type, you may need to cast
      for (var image in updatedImages) {
        combo.images.add(image);
      }
      c.updateCombination(c.combinations.indexOf(combo), combo);
    }
  }

//   Widget _buildReorderableImageTile(AddProductControllernew c, int index, {required Key key}) {
//     return Container(
//       key: key,
//       child: LongPressDraggable<int>(
//         data: index,
//         feedback: Material(
//           color: Colors.transparent,
//           child: Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.file(
//                 File(c.productImages[index].path),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//         childWhenDragging: Opacity(
//           opacity: 0.4,
//           child: _buildImageTile(c, index),
//         ),
//         dragAnchorStrategy: childDragAnchorStrategy,
//         child: _buildImageTile(c, index),
//       ),
//     );
//   }
//
//   Widget _buildImageTile(AddProductControllernew c, int index) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Image.file(
//             File(c.productImages[index].path),
//             fit: BoxFit.cover,
//           ),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4),
//             border: Border.all(
//               color: c.thumbnailIndex == index ? Colors.black : Colors.transparent,
//               width: 2,
//             ),
//           ),
//         ),
//         if (c.thumbnailIndex == index)
//           const Positioned(
//             top: 2,
//             left: 2,
//             child: CircleAvatar(
//               radius: 8,
//               backgroundColor: Colors.black,
//               child: Icon(Icons.star, color: Colors.white, size: 8),
//             ),
//           ),
//         Positioned(
//           top: 2,
//           right: 2,
//           child: GestureDetector(
//             onTap: () => _showDeleteImageConfirmation(c, index),
//             child: Container(
//               padding: const EdgeInsets.all(2),
//               decoration: const BoxDecoration(
//                 color: Colors.black,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.close, color: Colors.white, size: 8),
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 2,
//           right: 2,
//           child: GestureDetector(
//             onTap: () => c.setThumbnail(index),
//             child: Container(
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: c.thumbnailIndex == index ? Colors.black : Colors.white,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.black, width: 0.5),
//               ),
//               child: Icon(
//                 Icons.star_border,
//                 color: c.thumbnailIndex == index ? Colors.white : Colors.black,
//                 size: 8,
//               ),
//             ),
//           ),
//         ),
//         // Drag handle indicator
//         Positioned(
//           bottom: 2,
//           left: 2,
//           child: Container(
//             padding: const EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.6),
//               borderRadius: BorderRadius.circular(3),
//             ),
//             child: const Icon(
//               Icons.drag_handle,
//               color: Colors.white,
//               size: 10,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showDeleteImageConfirmation(AddProductControllernew c, int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Remove Image', style: TextStyle(fontSize: 16)),
//           content: const Text('Are you sure you want to remove this image?', style: TextStyle(fontSize: 14)),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel', style: TextStyle(color: Colors.black)),
//             ),
//             TextButton(
//               onPressed: () {
//                 c.removeImage(index);
//                 Navigator.pop(context);
//                 setState(() {});
//               },
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               child: const Text('Remove'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
// // Helper method to update image references in combinations
//   void _updateCombinationImagesReferences(AddProductControllernew c) {
//     for (var combo in c.combinations) {
//       final updatedImages = <ProductImage>[];
//       for (var image in combo.images) {
//         // Find the updated image reference
//         final updatedImage = c.productImages.firstWhere(
//               (img) => img.path == image.path,
//           orElse: () => image,
//         );
//         updatedImages.add(updatedImage);
//       }
//       combo.images.clear();
//       combo.images.addAll(updatedImages);
//       c.updateCombination(c.combinations.indexOf(combo), combo);
//     }
//   }
  // Widget _buildAddImageButton(AddProductControllernew c, {bool isLarge = false, Key? key}) {
  //   return GestureDetector(
  //     key: key,
  //     onTap: () => _showImageSourceDialog(c),
  //     child: Container(
  //       width: MediaQuery.of(context).size.width,
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.grey.shade300),
  //         borderRadius: BorderRadius.circular(6),
  //         color: Colors.grey.shade50,
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.add_photo_alternate,
  //               size: isLarge ? 24 : 18, color: Colors.black54),
  //           if (isLarge) ...[
  //             const SizedBox(height: 4),
  //             Text(
  //               'Add Images',
  //               style: TextStyle(color: Colors.black54, fontSize: 11),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildImageTile(AddProductControllernew c, int index) {
  //   return Stack(
  //     fit: StackFit.expand,
  //     children: [
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(4),
  //         child: Image.file(
  //           File(c.productImages[index].path),
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //       Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(4),
  //           border: Border.all(
  //             color: c.thumbnailIndex == index ? Colors.black : Colors.transparent,
  //             width: 2,
  //           ),
  //         ),
  //       ),
  //       if (c.thumbnailIndex == index)
  //         const Positioned(
  //           top: 2,
  //           left: 2,
  //           child: CircleAvatar(
  //             radius: 8,
  //             backgroundColor: Colors.black,
  //             child: Icon(Icons.star, color: Colors.white, size: 8),
  //           ),
  //         ),
  //       Positioned(
  //         top: 2,
  //         right: 2,
  //         child: GestureDetector(
  //           onTap: () => c.removeImage(index),
  //           child: Container(
  //             padding: const EdgeInsets.all(2),
  //             decoration: const BoxDecoration(
  //               color: Colors.black,
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(Icons.close, color: Colors.white, size: 8),
  //           ),
  //         ),
  //       ),
  //       Positioned(
  //         bottom: 2,
  //         right: 2,
  //         child: GestureDetector(
  //           onTap: () => c.setThumbnail(index),
  //           child: Container(
  //             padding: const EdgeInsets.all(2),
  //             decoration: BoxDecoration(
  //               color: c.thumbnailIndex == index ? Colors.black : Colors.white,
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.black, width: 0.5),
  //             ),
  //             child: Icon(
  //               Icons.star_border,
  //               color: c.thumbnailIndex == index ? Colors.white : Colors.black,
  //               size: 8,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBasicInfoSection(AddProductControllernew c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                context.tr('txt_product_info'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.titleController,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              labelText: context.tr('txt_product_title'),
              labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              hintText: context.tr('txt_product_desc'),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (v) => v!.isEmpty ? context.tr('txt_title_required') : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.shortDescController,
            maxLines: 2,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              labelText: context.tr('txt_short_desc'),
              labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              hintText: context.tr('txt_brief_desc'),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.longDescController,
            maxLines: 3,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              labelText: context.tr('txt_long_desc'),
              labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              hintText: context.tr('txt_detailed_desc'),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (v) => v!.isEmpty ? context.tr('txt_desc_required') : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSelectionCard(AddProductControllernew c) {
    // Check if we're in edit mode (editMode is true) or copy mode (originalProductIdForCopy != null)
    final bool isEditable = !widget.editMode && widget.originalProductIdForCopy == null;

    return InkWell(
      onTap: isEditable
          ? () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddProductStoreScreen(controller: c),
          ),
        );
        if (result == true) setState(() {});
      }
          : null, // Disable tap in edit or copy mode
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: !isEditable ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: c.selectedStore != null ? Colors.black : Colors.grey.shade300,
            width: c.selectedStore != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.store, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('txt_store'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.selectedStore?.name ?? context.tr('txt_select_store'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: c.selectedStore != null ? FontWeight.w600 : FontWeight.normal,
                      color: c.selectedStore != null ? Colors.black : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              c.selectedStore != null ? Icons.check_circle : Icons.arrow_forward_ios,
              color: c.selectedStore != null ? Colors.black : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCategorySelectionCard(AddProductControllernew c) {
    String selectedCategoryText = context.tr('txt_select_category');
    if (c.selectedChildCategory != null) {
      selectedCategoryText =
      '${c.selectedCategory?.name} → ${c.selectedSubCategory?.name} → ${c.selectedChildCategory?.name}';
    } else if (c.selectedSubCategory != null) {
      selectedCategoryText =
      '${c.selectedCategory?.name} → ${c.selectedSubCategory?.name}';
    } else if (c.selectedCategory != null) {
      selectedCategoryText = c.selectedCategory!.name;
    }

    // Check if we're in edit mode (editMode is true) or copy mode (originalProductIdForCopy != null)
    final bool isEditable = !widget.editMode && widget.originalProductIdForCopy == null;

    return InkWell(
      onTap: isEditable
          ? () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddProductCategoryScreen(controller: c),
          ),
        );
        if (result == true) setState(() {});
      }
          : null, // Disable tap in edit or copy mode
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: !isEditable ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: c.selectedCategory != null ? Colors.black : Colors.grey.shade300,
            width: c.selectedCategory != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.category, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('txt_category'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedCategoryText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: c.selectedCategory != null ? FontWeight.w600 : FontWeight.normal,
                      color: c.selectedCategory != null ? Colors.black : Colors.grey.shade500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              c.selectedCategory != null ? Icons.check_circle : Icons.arrow_forward_ios,
              color: c.selectedCategory != null ? Colors.black : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPriceSection(AddProductControllernew c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.price_change, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                context.tr('txt_default_pricing'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: c.defaultPriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: context.tr('txt_price'),
                    prefixText: 'c. ',
                    labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: c.defaultComparePriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: context.tr('txt_discounted_price'),
                    prefixText: 'c. ',
                    labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: c.defaultDiscountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: '${context.tr('txt_discount')} %',
                    suffixText: '%',
                    labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: c.defaultStockController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: context.tr('txt_stock'),
                    labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsSection(AddProductControllernew c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.style, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                context.tr('txt_product_variants'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (c.selectedChildCategory != null)
                InkWell(
                  onTap: () async {
                    await c.fetchAttributes(c.selectedChildCategory!.id);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VariantManagerScreen(controller: c),
                      ),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.black, size: 14),
                        SizedBox(width: 4),
                        Text(context.tr('txt_manage'), style: TextStyle(color: Colors.black, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (c.selectedVariants.any((v) => v.values.isNotEmpty))
            _buildSelectedVariantsSummary(c),
          if (c.selectedChildCategory == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('txt_select_category_first'),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedVariantsSummary(AddProductControllernew c) {
    final selectedVariants = c.selectedVariants
        .where((v) => v.values.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.tr('txt_selected_variants')} (${selectedVariants.length})',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...selectedVariants.map((v) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            v.attributeName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          if (v.isCustomAttribute) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                context.tr('txt_custom'),
                                style: TextStyle(fontSize: 8, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        v.values.join(' • '),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black54, size: 16),
                  onPressed: () {
                    c.removeVariant(v.attributeName);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCombinationsList(AddProductControllernew c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                '${context.tr('txt_variant_combinations')} (${c.combinations.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.combinations.length,
            itemBuilder: (context, index) {
              return _buildCombinationCard(c, index);
            },
          ),
        ],
      ),
    );
  }

  // Add this method to show full-screen image viewer
// Add this method to show full-screen image viewer
  void _showFullScreenImage(BuildContext context, AddProductControllernew c, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0.9),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int currentIndex = initialIndex;

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    // Image PageView for swiping
                    PageView.builder(
                      itemCount: c.productImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      controller: PageController(initialPage: initialIndex),
                      itemBuilder: (context, index) {
                        return Center(
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.file(
                              File(c.productImages[index].path),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),

                    // Close button
                    Positioned(
                      top: 40,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Image counter
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Text(
                            //   '${currentIndex + 1} / ${c.productImages.length}',
                            //   style: const TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            Row(
                              children: [
                                // Delete button in full screen
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showDeleteImageConfirmation(c, currentIndex);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Thumbnail button
                                GestureDetector(
                                  onTap: () {
                                    c.setThumbnail(currentIndex);
                                    Navigator.pop(context);
                                    // _showSuccessToast('Thumbnail updated');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      c.thumbnailIndex == currentIndex
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.yellow,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Previous button
                    if (currentIndex > 0)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (currentIndex > 0) {
                                setState(() {
                                  currentIndex--;
                                });
                                // Navigate to previous image
                                Navigator.pop(context);
                                _showFullScreenImage(context, c, currentIndex);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Next button
                    if (currentIndex < c.productImages.length - 1)
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (currentIndex < c.productImages.length - 1) {
                                setState(() {
                                  currentIndex++;
                                });
                                // Navigate to next image
                                Navigator.pop(context);
                                _showFullScreenImage(context, c, currentIndex);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildCombinationCard(AddProductControllernew c, int index) {
    final combo = c.combinations[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        title: Text(
          combo.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          '${context.tr('txt_price_')}: ${combo.price.toStringAsFixed(2)} c. | ${context.tr('txt_stock_')}: ${combo.stock} | ${context.tr('txt_images_')}: ${combo.images.length}/${c.productImages.length} ${context.tr('txt_selected')}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick select/deselect all button
            if (combo.images.length == c.productImages.length)
              IconButton(
                icon: const Icon(Icons.check_box, color: Colors.green, size: 18),
                onPressed: () {
                  setState(() {
                    combo.images.clear();
                    c.updateCombination(index, combo);
                  });
                },
                tooltip: context.tr('txt_deselect_all'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else if (combo.images.isEmpty)
              IconButton(
                icon: const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 18),
                onPressed: () {
                  setState(() {
                    combo.images.addAll(c.productImages);
                    c.updateCombination(index, combo);
                  });
                },
                tooltip: context.tr('txt_select_all'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              IconButton(
                icon: const Icon(Icons.indeterminate_check_box, color: Colors.orange, size: 18),
                onPressed: () {
                  _showImageSelectionDialog(context, c, index);
                },
                tooltip: context.tr('txt_customize_selection'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black54, size: 16),
              onPressed: () {
                _showDeleteConfirmation(context, c, index);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Price and Stock Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: combo.price.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: context.tr('txt_price_'),
                          prefixText: 'c. ',
                          labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          combo.price = double.tryParse(value) ?? 0.0;
                          c.updateCombination(index, combo);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: combo.comparePrice.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: context.tr('txt_discounted_price'),
                          prefixText: 'c. ',
                          labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          combo.comparePrice = double.tryParse(value) ?? 0.0;
                          c.updateCombination(index, combo);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Discount and Stock Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: combo.discount.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: '${context.tr('txt_discount')} %',
                          suffixText: '%',
                          labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          combo.discount = double.tryParse(value) ?? 0.0;
                          c.updateCombination(index, combo);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: combo.stock.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: context.tr('txt_stock_'),
                          labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          combo.stock = int.tryParse(value) ?? 0;
                          c.updateCombination(index, combo);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // SKU Field
                TextFormField(
                  initialValue: combo.sku,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: context.tr('txt_sku_optional'),
                    labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    combo.sku = value;
                    c.updateCombination(index, combo);
                  },
                ),
                const SizedBox(height: 12),

                // Image selection section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      context.tr('txt_select_images_from_combo'),
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          '${combo.images.length}/${c.productImages.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: combo.images.length == c.productImages.length
                                ? Colors.green
                                : combo.images.isEmpty
                                ? Colors.grey
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (combo.images.length < c.productImages.length)
                          IconButton(
                            icon: const Icon(Icons.select_all, color: Colors.black54, size: 16),
                            onPressed: () {
                              setState(() {
                                combo.images.addAll(c.productImages);
                                c.updateCombination(index, combo);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: context.tr('txt_select_all'),
                          ),
                        if (combo.images.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.deselect, color: Colors.black54, size: 16),
                            onPressed: () {
                              setState(() {
                                combo.images.clear();
                                c.updateCombination(index, combo);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: context.tr('txt_clear_all'),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Image grid with full-screen preview on tap
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: c.productImages.length,
                  itemBuilder: (context, imgIndex) {
                    final image = c.productImages[imgIndex];
                    final isSelected = combo.images.contains(image);

                    return GestureDetector(
                      onLongPress: () {
                        // Long press to preview in full screen
                        _showFullScreenImage(context, c, imgIndex);
                      },
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            combo.images.remove(image);
                          } else {
                            combo.images.add(image);
                          }
                          c.updateCombination(index, combo);
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                                height: 60,
                                width: 60,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 2,
                              right: 2,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.black,
                                child: Icon(Icons.check, color: Colors.white, size: 10),
                              ),
                            ),
                          if (c.thumbnailIndex == imgIndex)
                            const Positioned(
                              top: 2,
                              left: 2,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.star, color: Colors.white, size: 6),
                              ),
                            ),
                          // Image size indicator
                          FutureBuilder<int>(
                            future: File(image.path).length(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final sizeMB = snapshot.data! / (1024 * 1024);
                                return Positioned(
                                  bottom: 2,
                                  left: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      '${sizeMB.toStringAsFixed(1)}MB',
                                      style: const TextStyle(color: Colors.white, fontSize: 8),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          // Full-screen indicator
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Help text for image selection
                Text(
                  context.tr('tap_to_deselect'),
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  void _showDeleteConfirmation(BuildContext context, AddProductControllernew c, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('txt_delete_combo'), style: TextStyle(fontSize: 16)),
          content: Text(context.tr('txt_are_you_sure'), style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('txt_cancel'), style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                c.removeCombination(index);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: Text(context.tr('txt_delete')),
            ),
          ],
        );
      },
    );
  }

  void _showImageSelectionDialog(BuildContext context, AddProductControllernew c, int comboIndex) {
    final combo = c.combinations[comboIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr('txt_select_images'), style: TextStyle(fontSize: 16)),
                  Text(
                    '${combo.images.length}/${c.productImages.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: combo.images.length == c.productImages.length
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Quick actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              combo.images.addAll(c.productImages);
                              c.updateCombination(comboIndex, combo);
                            });
                          },
                          child: Text(context.tr('txt_select_all'), style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              combo.images.clear();
                              c.updateCombination(comboIndex, combo);
                            });
                          },
                          child: Text(context.tr('txt_clear_all'), style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: c.productImages.length,
                        itemBuilder: (ctx, imgIndex) {
                          final image = c.productImages[imgIndex];
                          final isSelected = combo.images.contains(image);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  combo.images.remove(image);
                                } else {
                                  combo.images.add(image);
                                }
                                c.updateCombination(comboIndex, combo);
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(image.path),
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black,
                                      child: Icon(Icons.check, color: Colors.white, size: 14),
                                    ),
                                  ),
                                if (c.thumbnailIndex == imgIndex)
                                  const Positioned(
                                    top: 4,
                                    left: 4,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.orange,
                                      child: Icon(Icons.star, color: Colors.white, size: 8),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('txt_done'), style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageSourceDialog(AddProductControllernew c) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.black),
              title: Text(context.tr('gallery'), style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                c.pickProductImages();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.black),
              title: Text(context.tr('camera'), style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                c.pickCameraImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _submitProduct(BuildContext context, AddProductControllernew c) async {
  //   if (c.productImages.isEmpty) {
  //     _showSnackBar('Please add at least one product image');
  //     return;
  //   }
  //   if (c.titleController.text.isEmpty) {
  //     _showSnackBar('Please enter product title');
  //     return;
  //   }
  //   if (c.selectedStore == null) {
  //     _showSnackBar('Please select a store');
  //     return;
  //   }
  //   if (c.selectedChildCategory == null) {
  //     _showSnackBar('Please select a complete category');
  //     return;
  //   }
  //   if (c.defaultPriceController.text.isEmpty) {
  //     _showSnackBar('Please enter price');
  //     return;
  //   }
  //   if (c.defaultStockController.text.isEmpty) {
  //     _showSnackBar('Please enter stock');
  //     return;
  //   }
  //
  //   final result = await c.submitProduct(context);
  //   if (!context.mounted) return;
  //
  //   if (result.success) {
  //     _showSnackBar(result.message, isError: false);
  //     // TODO: Navigate after actual API call
  //     // Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  //   } else {
  //     _showSnackBar(result.message, isError: true);
  //   }
  // }
  // Future<void> _submitProduct(BuildContext context, AddProductControllernew c) async {
  //   // Check if already submitting
  //   if (c.isSubmitting) {
  //     return;
  //   }
  //
  //   if (c.productImages.isEmpty) {
  //     _showSnackBar('Please add at least one product image');
  //     return;
  //   }
  //   if (c.titleController.text.isEmpty) {
  //     _showSnackBar('Please enter product title');
  //     return;
  //   }
  //   if (c.selectedStore == null) {
  //     _showSnackBar('Please select a store');
  //     return;
  //   }
  //   if (c.selectedChildCategory == null) {
  //     _showSnackBar('Please select a complete category');
  //     return;
  //   }
  //   if (c.defaultPriceController.text.isEmpty) {
  //     _showSnackBar('Please enter price');
  //     return;
  //   }
  //   if (c.defaultStockController.text.isEmpty) {
  //     _showSnackBar('Please enter stock');
  //     return;
  //   }
  //
  //   // Show loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Center(
  //       child: Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               CircularProgressIndicator(),
  //               const SizedBox(height: 16),
  //               Text(widget.editMode ? 'Updating product...' : 'Adding product...'),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   final result = widget.editMode
  //       ? await c.updateProduct(context)
  //       : await c.submitProduct(context);
  //
  //   // Close loading dialog
  //   if (context.mounted) {
  //     Navigator.pop(context);
  //   }
  //
  //   if (!context.mounted) return;
  //
  //   if (result.success) {
  //     // Success message is already shown in submitProduct
  //     // The navigation will happen automatically
  //   } else {
  //     // Error message is already shown in submitProduct
  //   }
  // }


  Future<void> _submitProduct(BuildContext context, AddProductControllernew c) async {
    final t = context.watch<TranslateProvider>().t;

    // Check if already submitting
    if (c.isSubmitting) {
      return;
    }

    if (c.productImages.isEmpty) {
      _showSnackBar(t('please_add_at_least_1'));
      return;
    }
    if (c.titleController.text.isEmpty) {
      _showSnackBar(t('enter_prod_title'));
      return;
    }
    if (c.selectedStore == null) {
      _showSnackBar(t('select_store'));
      return;
    }
    if (c.selectedChildCategory == null) {
      _showSnackBar(t('select_category'));
      return;
    }
    if (c.defaultPriceController.text.isEmpty) {
      _showSnackBar(t('enter_price'));
      return;
    }
    if (c.defaultStockController.text.isEmpty) {
      _showSnackBar(t('enter_stock'));
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(widget.originalProductIdForCopy != null
                    ? t('copying_prod')
                    : (widget.editMode ? t('updating_prod') : t('adding_prod'))),
              ],
            ),
          ),
        ),
      ),
    );

    ApiResult result;

    // Check if this is a copy operation (has originalProductIdForCopy)
    if (widget.originalProductIdForCopy != null) {
      // This is a copy operation with the original product ID
      result = await c.copyProduct(context, widget.originalProductIdForCopy!);
    } else if (widget.editMode) {
      // This is an update/edit operation
      result = await c.updateProduct(context);
    } else {
      // This is a new product creation
      result = await c.submitProduct(context);
    }

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    if (!context.mounted) return;

    if (result.success) {
      // Success message is already shown in the respective methods
      // The navigation will happen automatically
    } else {
      // Error message is already shown
    }
  }


  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        backgroundColor: isError ? Colors.red.shade900 : Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}