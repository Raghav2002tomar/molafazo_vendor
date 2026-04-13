import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:molafzo_vendor/screens/stores/screens/social_links_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../../../services/api_service.dart';
import '../../addproduct/model.dart' hide StoreModel;
import '../../profile/screens/store_list_screen.dart';
import '../controller/add_store_controller.dart';
import '../../../screens/citys/CitySearchScreen.dart';
import 'DeliveryPolicyWidget.dart';
import 'PolicySelectionWidget.dart';
import 'StorePreviewScreen.dart';

class AddStoreScreen extends StatefulWidget {
  final StoreModel? storeData; // Pass full store data for editing
  const AddStoreScreen({super.key, this.storeData});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  // Variables
  String? _selectedCity;

  // Image dimension tracking
  Map<String, dynamic>? _logoDimensions;
  Map<String, dynamic>? _backgroundDimensions;

  // Required dimensions
  final Map<String, Map<String, dynamic>> _requiredDimensions = {
    'logo': {
      'minWidth': 200,
      'minHeight': 200,
      'maxWidth': 500,
      'maxHeight': 500,
      'description': '200x200 - 500x500 pixels',
    },
    'background': {
      'requiredWidth': 1408,
      'requiredHeight': 768,
      'description': '1408x768 pixels',
    },
  };

  @override
  void initState() {
    super.initState();
  }

  void _populateFormWithStoreData(AddStoreController c) {
    final store = widget.storeData!;

    // Fill text fields
    nameCtrl.text = store.name;
    mobileCtrl.text = store.mobile;
    _selectedCity = store.city;
    cityCtrl.text = store.city;
    addressCtrl.text = store.address;
    landmarkCtrl.text = store.landmark ?? '';
    descCtrl.text = store.description ?? '';

    // Set offline selling based on types - check for type 3 (Offline)
    c.sellOffline = store.types.contains(3);

    // Force rebuild to show/hide address fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Set delivery options
    c.selfPickup = store.selfPickup == 1;
    c.deliveryBySeller = store.deliveryBySeller == 1;

    // Parse working hours
    if (store.workingHours.isNotEmpty && store.workingHours != 'Not specified') {
      final hours = store.workingHours.split(' - ');
      if (hours.length == 2) {
        c.openingTime = _parseTime(hours[0]);
        c.closingTime = _parseTime(hours[1]);
      }
    }

    // Set return policy
    if (store.returnPolicy != null && store.returnPolicy!.isNotEmpty) {
      c.updatePolicy(store.returnPolicy);
    } else {
      c.updatePolicy(null);
    }

    // Set delivery policy
    if (store.deliveryPolicy != null && store.deliveryPolicy!.isNotEmpty) {
      c.updateDeliveryPolicy(store.deliveryPolicy);
    } else {
      c.updateDeliveryPolicy(null);
    }

    // Set delivery days
    if (store.deliveryDays != null && store.deliveryDays!.isNotEmpty) {
      c.updateDeliveryDays(store.deliveryDays);
    } else {
      c.updateDeliveryDays(null);
    }

    // Set social links
    if (store.socialLinks != null && store.socialLinks!.isNotEmpty) {
      final links = store.socialLinks!.map((link) =>
          SocialLink(
              type: link['type'] as String,
              url: link['url'] as String
          )
      ).toList();
      c.updateSocialLinks(links);
    } else {
      c.updateSocialLinks([]);
    }

    // Set background color
    if (store.backgroundColor != null && store.backgroundColor!.isNotEmpty) {
      try {
        final colorHex = store.backgroundColor!.replaceAll('#', '');
        final color = Color(int.parse('0xFF$colorHex'));
        c.updateStoreBackgroundColor(color);
      } catch (e) {
        print("Error parsing color: $e");
      }
    }

    // Load images from URLs - pass the controller
    if (store.logo != null && store.logo!.isNotEmpty) {
      _loadImageFromUrl(store.logo!, isLogo: true, c: c);
    }
    if (store.storeBackgroundImage != null && store.storeBackgroundImage!.isNotEmpty) {
      _loadImageFromUrl(store.storeBackgroundImage!, isLogo: false, c: c);
    }

    // Update UI after all data is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        c.notifyListeners();
      }
    });

    print("Store data populated successfully for: ${store.name}");
    print("Sell Offline: ${c.sellOffline}");
    print("Store Types: ${store.types}");
    print("Self Pickup: ${c.selfPickup}");
    print("Delivery By Seller: ${c.deliveryBySeller}");
    print("Opening Time: ${c.openingTime}");
    print("Closing Time: ${c.closingTime}");
    print("Return Policy: ${c.storePolicy}");
    print("Delivery Policy: ${c.deliveryPolicy}");
    print("Delivery Days: ${c.deliveryDays}");
    print("Social Links Count: ${c.socialLinks.length}");
    print("Logo URL: ${store.logo}");
    print("Background URL: ${store.storeBackgroundImage}");
  }



  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length == 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {}
    return TimeOfDay.now();
  }


  Future<void> _loadImageFromUrl(String url, {required bool isLogo, required AddStoreController c}) async {
    try {
      // Construct full URL
      final String fullUrl;
      if (url.startsWith('http')) {
        fullUrl = url;
      } else {
        // Use the correct path based on image type
        final path = isLogo ? ApiService.store_logo_URL : ApiService.store_background_URL;
        fullUrl = '${ApiService.ImagebaseUrl}$path$url';
      }

      print("Loading image from: $fullUrl");

      final http.Response response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);

        // Get dimensions
        final dimensions = await _getImageDimensions(file);

        if (mounted) {
          setState(() {
            if (isLogo) {
              c.storeProofImage = XFile(file.path);
              _logoDimensions = dimensions;
            } else {
              c.storeBackgroundImage = XFile(file.path);
              _backgroundDimensions = dimensions;
            }
          });
          c.notifyListeners();
        }
      } else {
        print("Failed to load image: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error loading image from URL: $e");
    }
  }


  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    landmarkCtrl.dispose();
    descCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  /// Get image dimensions
  Future<Map<String, dynamic>?> _getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      await Future.delayed(Duration.zero);
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to read image dimensions');
      return null;
    }
  }

  /// Logo validation
  bool _validateLogoDimensions(
      Map<String, dynamic> dimensions,
      Map<String, dynamic> requirements,
      ) {
    final width = dimensions['width'] as int;
    final height = dimensions['height'] as int;

    if (width < (requirements['minWidth'] as int) ||
        height < (requirements['minHeight'] as int)) {
      _showDimensionError(
          'Image too small',
          'Minimum size: ${requirements['minWidth']}x${requirements['minHeight']}px\n'
              'Your image: ${width}x${height}px'
      );
      return false;
    }

    if (width > (requirements['maxWidth'] as int) ||
        height > (requirements['maxHeight'] as int)) {
      _showDimensionError(
          'Image too large',
          'Maximum size: ${requirements['maxWidth']}x${requirements['maxHeight']}px\n'
              'Your image: ${width}x${height}px'
      );
      return false;
    }

    return true;
  }

  /// Background validation
  bool _validateBackgroundDimensions(
      Map<String, dynamic> dimensions,
      Map<String, dynamic> requirements,
      ) {
    final width = dimensions['width'] as int;
    final height = dimensions['height'] as int;

    final requiredWidth = requirements['requiredWidth'] as int;
    final requiredHeight = requirements['requiredHeight'] as int;

    if (width != requiredWidth || height != requiredHeight) {
      _showDimensionError(
          'Invalid Background Image',
          'Required size: ${requiredWidth}x${requiredHeight}px\n'
              'Your image: ${width}x${height}px\n\n'
              'Please upload an image with exact dimensions 1408x768 pixels.'
      );
      return false;
    }

    return true;
  }

  void _showDimensionError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Image picker with validation
  Future<void> _pickImageWithValidation(
      BuildContext context,
      AddStoreController c,
      String imageType,
      ) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      final dimensions = await _getImageDimensions(file);
      if (dimensions == null) return;

      if (imageType == 'logo') {
        final isValid = _validateLogoDimensions(
          dimensions,
          _requiredDimensions['logo']!,
        );

        if (!isValid) return;

        setState(() {
          c.storeProofImage = pickedFile;
          _logoDimensions = dimensions;
        });

        c.notifyListeners();

        Fluttertoast.showToast(
          msg: 'Logo uploaded (${dimensions['width']}x${dimensions['height']})',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else if (imageType == 'background') {
        final isValid = _validateBackgroundDimensions(
          dimensions,
          _requiredDimensions['background']!,
        );

        if (!isValid) return;

        setState(() {
          c.storeBackgroundImage = pickedFile;
          _backgroundDimensions = dimensions;
        });

        c.notifyListeners();

        Fluttertoast.showToast(
          msg: 'Background uploaded (${dimensions['width']}x${dimensions['height']})',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Image Pick Error: $e");
      Fluttertoast.showToast(
        msg: "Failed to pick image",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// Open city selection
  Future<void> _selectCity() async {
    final city = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CitySearchScreen(),
      ),
    );

    if (city != null) {
      setState(() {
        _selectedCity = city.name;
        cityCtrl.text = city.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddStoreController(),
      child: Consumer<AddStoreController>(
        builder: (context, c, _) {
          // Populate form when store data is available and name field is empty
          if (widget.storeData != null && nameCtrl.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _populateFormWithStoreData(c);
              }
            });
          }

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(widget.storeData != null ? "Edit Store" : "Create Store"),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: Form(
              key: c.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// STORE INFO
                    sectionTitle("Store Information"),
                    label("Store Name *"),
                    textField(nameCtrl, "Enter store name"),

                    label("Mobile Number *"),
                    textField(
                      mobileCtrl,
                      "Enter mobile number",
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    /// DO YOU SELL OFFLINE? TOGGLE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Do you sell offline?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Enable if you have a physical store location",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: c.sellOffline,
                            onChanged: (value) {
                              setState(() {
                                c.sellOffline = value;
                                if (!value) {
                                  addressCtrl.clear();
                                  landmarkCtrl.clear();
                                }
                              });
                              c.notifyListeners();
                            },
                            activeColor: Colors.black,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// CITY SELECTION (Always shown)
                    label("City *"),
                    InkWell(
                      onTap: _selectCity,
                      child: InputDecorator(
                        decoration: inputDecoration("Select city").copyWith(
                          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ),
                        child: Text(
                          _selectedCity ?? "Select city",
                          style: TextStyle(
                            color: _selectedCity == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    /// ADDRESS FIELDS (Only shown if selling offline)
                    if (c.sellOffline) ...[
                      const SizedBox(height: 16),
                      label("Store Address *"),
                      textField(
                        addressCtrl,
                        "Enter complete store address",
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      label("Landmark (Optional)"),
                      optionalTextField(landmarkCtrl, "Enter landmark (e.g., near city mall)"),
                    ],

                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text("Self Pickup"),
                      value: c.selfPickup,
                      onChanged: (v) {
                        c.selfPickup = v;
                        c.notifyListeners();
                      },
                    ),

                    SwitchListTile(
                      title: const Text("Delivery By Seller"),
                      value: c.deliveryBySeller,
                      onChanged: (v) {
                        c.deliveryBySeller = v;
                        c.notifyListeners();
                      },
                    ),

                    /// TIMING
                    sectionTitle("Store Timing"),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => c.pickTime(context, true),
                            child: Text(
                              c.openingTime == null
                                  ? "Opening Time"
                                  : c.openingTime!.format(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => c.pickTime(context, false),
                            child: Text(
                              c.closingTime == null
                                  ? "Closing Time"
                                  : c.closingTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// BACKGROUND IMAGE
                    sectionTitle("Store Background Image *"),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Background Image Requirements:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Exact size required: ${_requiredDimensions['background']!['description']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '• Please ensure your image is exactly 1408x768 pixels',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (c.storeBackgroundImage == null) ...[
                      uploadBox(
                        title: "Tap to Upload Background Image",
                        subtitle: "Must be exactly 1408x768 pixels",
                        icon: Icons.image,
                        onTap: () => _pickImageWithValidation(context, c, 'background'),
                      ),
                    ] else ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(c.storeBackgroundImage!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  c.clearStoreBackground();
                                  _backgroundDimensions = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          if (_backgroundDimensions != null)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_backgroundDimensions!['width']} x ${_backgroundDimensions!['height']} px',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ),
                          if (_backgroundDimensions != null &&
                              (_backgroundDimensions!['width'] != 1408 || _backgroundDimensions!['height'] != 768))
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Wrong Size! Must be 1408x768',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    /// STORE LOGO
                    sectionTitle("Store Logo *"),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Required size: ${_requiredDimensions['logo']!['description']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (c.storeProofImage == null) ...[
                      uploadBox(
                        title: "Tap to Upload Logo",
                        subtitle: "200x200 to 500x500 pixels",
                        icon: Icons.store,
                        onTap: () => _pickImageWithValidation(context, c, 'logo'),
                      ),
                    ] else ...[
                      Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(c.storeProofImage!.path),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  c.clearStoreProof();
                                  _logoDimensions = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          if (_logoDimensions != null)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_logoDimensions!['width']} x ${_logoDimensions!['height']} px',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    /// DESCRIPTION
                    sectionTitle("Description"),
                    textField(
                      descCtrl,
                      "Enter store description",
                      maxLines: 3,
                    ),

                    /// RETURN POLICY SECTION
                    sectionTitle("Return Policy"),
                    const SizedBox(height: 8),
                    PolicySelectionWidget(
                      initialPolicy: c.storePolicy, // Pass the existing policy
                      onPolicyChanged: (policy) {
                        c.updatePolicy(policy);
                      },
                    ),
                    const SizedBox(height: 20),

                    /// DELIVERY POLICY SECTION
                    sectionTitle("Delivery Policy"),
                    const SizedBox(height: 8),
                    DeliveryPolicyWidget(
                      initialPolicy: c.deliveryPolicy, // Pass existing delivery policy
                      initialDays: c.deliveryDays, // Pass existing delivery days
                      onPolicyChanged: (policy) {
                        c.updateDeliveryPolicy(policy);
                      },
                      onDaysChanged: (days) {
                        c.updateDeliveryDays(days);
                      },
                    ),
                    /// SOCIAL LINKS SECTION
                    sectionTitle("Social & Contact Links"),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Add your social media links',
                                style: TextStyle(fontSize: 14),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SocialLinksPage(
                                        existingLinks: c.socialLinks.map((link) => SocialLink(
                                          type: link['type']!,
                                          url: link['url']!,
                                        )).toList(),
                                        onSave: (links) {
                                          c.updateSocialLinks(links);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Manage Links'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Display added links
                          if (c.socialLinks.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: c.socialLinks.map((link) {
                                IconData icon;
                                switch (link['type']) {
                                  case 'email':
                                    icon = Icons.email;
                                    break;
                                  case 'instagram':
                                    icon = Icons.photo_camera;
                                    break;
                                  case 'facebook':
                                    icon = Icons.facebook;
                                    break;
                                  case 'youtube':
                                    icon = Icons.play_circle_filled;
                                    break;
                                  default:
                                    icon = Icons.link;
                                }
                                return Chip(
                                  avatar: Icon(icon, size: 16),
                                  label: Text(link['type']!),
                                  backgroundColor: Colors.grey.shade100,
                                );
                              }).toList(),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.share, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No social links added yet',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap "Manage Links" to add',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// PREVIEW BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (nameCtrl.text.isEmpty) {
                            Fluttertoast.showToast(msg: "Please enter store name");
                            return;
                          }

                          String workingHours = "Not specified";
                          if (c.openingTime != null && c.closingTime != null) {
                            workingHours = "${c.openingTime!.format(context)} - ${c.closingTime!.format(context)}";
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StorePreviewScreen(
                                storeName: nameCtrl.text,
                                storeMobile: mobileCtrl.text,
                                storeDescription: descCtrl.text,
                                storeCity: _selectedCity ?? "",
                                storeAddress: addressCtrl.text,
                                storeLandmark: landmarkCtrl.text,
                                sellOffline: c.sellOffline,
                                selfPickup: c.selfPickup,
                                deliveryBySeller: c.deliveryBySeller,
                                workingHours: workingHours,
                                logoImage: c.storeProofImage,
                                backgroundImage: c.storeBackgroundImage,
                                storePolicy: c.storePolicy,
                                socialLinks: c.socialLinks,
                                onColorSaved: (color) {
                                  c.updateStoreBackgroundColor(color);
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text("Preview Store", style: TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: c.submitting
                            ? null
                            : () async {
                          if (!c.formKey.currentState!.validate()) return;

                          if (_selectedCity == null) {
                            Fluttertoast.showToast(msg: "Please select city");
                            return;
                          }

                          if (c.sellOffline && addressCtrl.text.trim().isEmpty) {
                            Fluttertoast.showToast(msg: "Please enter store address");
                            return;
                          }

                          if (c.storeBackgroundImage == null) {
                            Fluttertoast.showToast(msg: "Background image required");
                            return;
                          }

                          if (_backgroundDimensions != null) {
                            if (_backgroundDimensions!['width'] != 1408 ||
                                _backgroundDimensions!['height'] != 768) {
                              Fluttertoast.showToast(
                                msg: "Background image must be exactly 1408x768 pixels",
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }
                          }

                          if (c.storeProofImage == null) {
                            Fluttertoast.showToast(msg: "Logo image required");
                            return;
                          }

                          // Build full address
                          String fullAddress = '';
                          if (c.sellOffline) {
                            fullAddress = addressCtrl.text.trim();
                            if (landmarkCtrl.text.trim().isNotEmpty) {
                              fullAddress += ', ${landmarkCtrl.text.trim()}';
                            }
                          } else {
                            fullAddress = _selectedCity ?? '';
                          }

                          if (widget.storeData != null) {
                            // Update existing store
                            await c.updateStore(
                              storeId: widget.storeData!.id,
                              name: nameCtrl.text,
                              mobile: mobileCtrl.text,
                              city: _selectedCity!,
                              address: fullAddress,
                              description: descCtrl.text,
                              latitude: null,
                              longitude: null,
                            );
                          } else {
                            // Create new store
                            await c.submitStore(
                              name: nameCtrl.text,
                              mobile: mobileCtrl.text,
                              city: _selectedCity!,
                              address: fullAddress,
                              description: descCtrl.text,
                              latitude: null,
                              longitude: null,
                            );
                          }
                        },
                        child: c.submitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          widget.storeData != null ? "Update Store" : "Create Store",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget optionalTextField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: inputDecoration(hint),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget textField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: inputDecoration(hint),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget uploadBox({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}