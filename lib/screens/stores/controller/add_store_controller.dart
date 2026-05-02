
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/api_service.dart';
import '../screens/delivery_settings_screen.dart';
import '../screens/social_links_page.dart';

class AddStoreController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
// Add these properties to AddStoreController class
  Map<String, dynamic>? _deliveryPolicy;
  String? _deliveryDays;

  Map<String, dynamic>? get deliveryPolicy => _deliveryPolicy;
  String? get deliveryDays => _deliveryDays;

  List<DeliveryConfigModel> deliveryConfigs = [];

  void updateDeliveryConfigs(List<DeliveryConfigModel> configs) {
    deliveryConfigs = configs;
    notifyListeners();
  }

  void addDeliveryConfigFields(Map<String, String> fields) {
    for (int i = 0; i < deliveryConfigs.length; i++) {
      final item = deliveryConfigs[i].toApiMap();

      fields['delivery_config[$i][city]'] = item['city']!;
      fields['delivery_config[$i][enabled]'] = item['enabled']!;
      fields['delivery_config[$i][delivery_type]'] = item['delivery_type']!;
      fields['delivery_config[$i][delivery_time_value]'] =
      item['delivery_time_value']!;
      fields['delivery_config[$i][delivery_time_unit]'] =
      item['delivery_time_unit']!;
      fields['delivery_config[$i][description]'] = item['description']!;
    }
  }

  void updateDeliveryPolicy(Map<String, dynamic>? policy) {
    _deliveryPolicy = policy;
    notifyListeners();
  }

  void updateDeliveryDays(String? days) {
    _deliveryDays = days;
    notifyListeners();
  }
  /// ---------------- Images ----------------
  XFile? storeBackgroundImage;
  XFile? storeProofImage;

  /// ---------------- Store Info ----------------
  bool submitting = false;
  bool sellOffline = false; // Added this to track offline selling

  bool selfPickup = false;
  bool deliveryBySeller = true;

  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  /// ---------------- Time Picker ----------------
  Future<void> pickTime(BuildContext context, bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      if (isOpening) {
        openingTime = picked;
      } else {
        closingTime = picked;
      }
      notifyListeners();
    }
  }

  String _workingHoursString() {
    if (openingTime == null || closingTime == null) return '';

    return '${openingTime!.hour}:${openingTime!.minute.toString().padLeft(2, '0')}'
        ' - '
        '${closingTime!.hour}:${closingTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Get store types based on sellOffline flag
  /// Get store types based on sellOffline flag
  List<String> getStoreTypes() {
    if (sellOffline) {
      // Both Online and Offline
      return ['2', '3']; // 2 = Online, 4 = Offline
    } else {
      // Only Online
      return ['2']; // 2 = Online
    }
  }

  /// ---------------- Image Compression ----------------
  Future<XFile?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();

      int quality = 80;
      int width = 1000;
      int height = 1000;

      File? compressedFile;

      while (true) {
        final targetPath =
            "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

        final result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: quality,
          minWidth: width,
          minHeight: height,
          format: CompressFormat.jpeg,
        );

        if (result == null) return null;

        compressedFile = File(result.path);

        int size = await compressedFile.length();
        double sizeMB = size / (1024 * 1024);

        debugPrint(
            "Compressed -> ${sizeMB.toStringAsFixed(2)}MB | Q:$quality | W:$width");

        if (sizeMB <= 1) {
          return XFile(compressedFile.path);
        }

        if (quality > 30) {
          quality -= 10;
        } else if (width > 400) {
          width -= 200;
          height -= 200;
        } else {
          return XFile(compressedFile.path);
        }

        file = compressedFile;
      }
    } catch (e) {
      debugPrint("Compression Error: $e");
      return null;
    }
  }

  /// ---------------- Pick Background Image ----------------
  Future<void> pickStoreBackgroundImage() async {
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (img == null) return;

    File file = File(img.path);
    final compressed = await compressImage(file);

    if (compressed == null) return;

    int size = await compressed.length();
    double sizeMB = size / (1024 * 1024);

    if (sizeMB > 1) {
      Fluttertoast.showToast(msg: "Image must be less than 1MB");
      return;
    }

    storeBackgroundImage = XFile(compressed.path);
    notifyListeners();
  }

  void clearStoreBackground() {
    storeBackgroundImage = null;
    notifyListeners();
  }


  // Save background color to SharedPreferences
  Future<void> saveBackgroundColorToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_storeBackgroundColor != null) {
      prefs.setInt('store_background_color', _storeBackgroundColor!.value);
    }
  }

  Future<void> loadBackgroundColorFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('store_background_color');
    if (colorValue != null) {
      _storeBackgroundColor = Color(colorValue);
    } else {
      _storeBackgroundColor = const Color(0xFFF5F0EB); // Default warm color
    }
    notifyListeners();
  }



  /// ---------------- Pick Logo ----------------
  Future<void> pickStoreProofImage() async {
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (img == null) return;

    File file = File(img.path);
    final compressed = await compressImage(file);

    if (compressed == null) return;

    int size = await compressed.length();
    double sizeMB = size / (1024 * 1024);

    if (sizeMB > 1) {
      Fluttertoast.showToast(msg: "Image must be less than 1MB");
      return;
    }

    storeProofImage = XFile(compressed.path);
    notifyListeners();
  }

  void clearStoreProof() {
    storeProofImage = null;
    notifyListeners();
  }

  Map<String, dynamic>? _storePolicy;
  List<Map<String, String>> _socialLinks = [];

  Map<String, dynamic>? get storePolicy => _storePolicy;
  List<Map<String, String>> get socialLinks => _socialLinks;

  void updatePolicy(Map<String, dynamic>? policy) {
    _storePolicy = policy;
    notifyListeners();
  }

  void updateSocialLinks(List<SocialLink> links) {
    _socialLinks = links.map((link) => {
      'type': link.type,
      'url': link.url,
    }).toList();
    notifyListeners();
  }


  Future<void> submitStore({
    required String name,
    required String mobile,
    required String city,
    required String address,
    required String description,
    String? latitude,
    String? longitude,
  }) async {
    /// ---------- FORM VALIDATION ----------
    if (name.trim().isEmpty) {
      Fluttertoast.showToast(msg: "txt_store_name_required");
      return;
    }

    if (mobile.trim().isEmpty || mobile.length != 10) {
      Fluttertoast.showToast(msg: "Enter valid 10 digit mobile number");
      return;
    }

    if (city.trim().isEmpty) {
      Fluttertoast.showToast(msg: "City is required");
      return;
    }

    /// ---------- IMAGE VALIDATION ----------
    if (storeBackgroundImage == null) {
      Fluttertoast.showToast(msg: "txt_store_bg_required");
      return;
    }

    if (storeProofImage == null) {
      Fluttertoast.showToast(msg: "txt_store_logo_required");
      return;
    }

    /// ---------- WORKING HOURS ----------
    if (openingTime == null || closingTime == null) {
      Fluttertoast.showToast(msg: "txt_select_working_hours");
      return;
    }

    submitting = true;
    notifyListeners();

    try {
      /// ---------- TOKEN ----------
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        Fluttertoast.showToast(msg: "txt_auth_failed");
        submitting = false;
        notifyListeners();
        return;
      }

      /// ---------- IMAGE SIZE CHECK ----------
      int logoSize = await File(storeProofImage!.path).length();
      int bgSize = await File(storeBackgroundImage!.path).length();

      double logoMB = logoSize / (1024 * 1024);
      double bgMB = bgSize / (1024 * 1024);

      debugPrint("Logo Size: $logoMB MB");
      debugPrint("Background Size: $bgMB MB");

      if (logoMB > 1 || bgMB > 1) {
        submitting = false;
        notifyListeners();
        Fluttertoast.showToast(msg: "txt_image_max_1mb");
        return;
      }

      /// ---------- FILES ----------
      final Map<String, File> files = {
        'logo': File(storeProofImage!.path),
        'store_background_image': File(storeBackgroundImage!.path),
      };

      /// ---------- Extract email from social links ----------
      String? email;
      final socialLinksList = <Map<String, String>>[];

      for (var link in _socialLinks) {
        if (link['type'] == 'email' && link['url'] != null && link['url']!.trim().isNotEmpty) {
          email = link['url']!.trim();
          socialLinksList.add({
            'type': 'email',
            'url': email!,
          });
        } else if (link['url'] != null && link['url']!.trim().isNotEmpty) {
          socialLinksList.add(link);
        }
      }

      /// ---------- FIELDS ----------
      Map<String, String> fields = {
        'name': name.trim(),
        'mobile': mobile.trim(),
        'country': 'Tajikistan',
        'city': city.trim(),
        'address': address.trim(),
        'delivery_by_seller': deliveryBySeller ? '1' : '0',
        'self_pickup': selfPickup ? '1' : '0',
        'description': description.trim(),
        'working_hours': _workingHoursString(),
      };

      // Add email if found
      if (email != null && email.isNotEmpty) {
        fields['email'] = email;
      }

      // Add location only for offline stores
      if (sellOffline && latitude != null && longitude != null) {
        fields['latitude'] = latitude;
        fields['longitude'] = longitude;
      }

      // Add return policy as nested fields (NOT JSON)
      if (_storePolicy != null) {
        if (_storePolicy!['type'] != null) {
          fields['return_policy[type]'] = _storePolicy!['type'].toString();
        }
        if (_storePolicy!['days'] != null) {
          fields['return_policy[days]'] = _storePolicy!['days'].toString();
        }
        if (_storePolicy!['message'] != null) {
          fields['return_policy[message]'] = _storePolicy!['message'].toString();
        }
      }

      // Add delivery policy as nested fields (NOT JSON)
      if (_deliveryPolicy != null) {
        if (_deliveryPolicy!['type'] != null) {
          fields['delivery_policy[type]'] = _deliveryPolicy!['type'].toString();
        }
        if (_deliveryPolicy!['message'] != null) {
          fields['delivery_policy[message]'] = _deliveryPolicy!['message'].toString();
        }
        if (_deliveryPolicy!['days'] != null) {
          fields['delivery_policy[days]'] = _deliveryPolicy!['days'].toString();
        }
      }

      // Add delivery days
      if (_deliveryDays != null && _deliveryDays!.isNotEmpty) {
        fields['delivery_days'] = _deliveryDays.toString();
      }

      // Add background color
      if (_storeBackgroundColor != null) {
        final hex = '#${_storeBackgroundColor!.value.toRadixString(16).substring(2).toUpperCase()}';
        fields['background_color'] = hex;
      }

      /// ---------- STORE TYPES (As array - THIS IS WHERE TYPE IS SENT) ----------
      final storeTypes = getStoreTypes();
      for (int i = 0; i < storeTypes.length; i++) {
        fields['type[$i]'] = storeTypes[i];
      }

      /// ---------- SOCIAL LINKS (Send as separate fields with indexing) ----------
      if (socialLinksList.isNotEmpty) {
        for (int i = 0; i < socialLinksList.length; i++) {
          final link = socialLinksList[i];
          fields['social_links[$i][type]'] = link['type']!;
          fields['social_links[$i][url]'] = link['url']!;
        }
      }
      addDeliveryConfigFields(fields);
      debugPrint("========== STORE SUBMISSION DEBUG ==========");
      debugPrint("STORE TYPES (Array format):");
      for (int i = 0; i < storeTypes.length; i++) {
        debugPrint("  type[$i] = ${storeTypes[i]}");
      }
      debugPrint("EMAIL: $email");
      debugPrint("SOCIAL LINKS COUNT: ${socialLinksList.length}");
      debugPrint("DELIVERY POLICY: ${_deliveryPolicy}");
      debugPrint("RETURN POLICY: ${_storePolicy}");
      debugPrint("FIELDS COUNT: ${fields.length}");
      debugPrint("ALL FIELDS: $fields");
      debugPrint("============================================");

      /// ---------- API REQUEST ----------
      final res = await ApiService.multipart(
        endpoint: '/vendor/store/create',
        token: token,
        fields: fields,
        files: files,
      );

      submitting = false;
      notifyListeners();

      /// ---------- SUCCESS ----------
      if (res != null && (res['status'] == true || res['success'] == true)) {
        Fluttertoast.showToast(
          msg: res['message'] ?? "txt_store_created_success",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (formKey.currentContext != null) {
            Navigator.of(formKey.currentContext!).pop(true);
          }
        });
      } else {
        String errorMsg = "txt_store_create_failed";
        if (res != null) {
          if (res['message'] != null) {
            errorMsg = res['message'].toString();
          } else if (res['errors'] != null) {
            errorMsg = res['errors'].toString();
          }
        }

        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        debugPrint("API Error Response: $res");
      }
    } catch (e) {
      submitting = false;
      notifyListeners();

      debugPrint("Store create error: $e");
      debugPrint("Stack trace: ${StackTrace.current}");

      Fluttertoast.showToast(
        msg: "Something went wrong: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }


  Future<void> updateStore({
    required int storeId,
    required String name,
    required String mobile,
    required String city,
    required String address,
    required String description,
    String? latitude,
    String? longitude,
  }) async {
    // Similar validation as submitStore
    if (name.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Store name is required");
      return;
    }

    if (mobile.trim().isEmpty || mobile.length != 10) {
      Fluttertoast.showToast(msg: "txt_mobile_invalid");
      return;
    }

    if (city.trim().isEmpty) {
      Fluttertoast.showToast(msg: "txt_city_required");
      return;
    }

    submitting = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        Fluttertoast.showToast(msg: "Authentication failed. Login again.");
        submitting = false;
        notifyListeners();
        return;
      }

      // Prepare files (only if new images are selected)
      final Map<String, File> files = {};
      if (storeProofImage != null) {
        int logoSize = await File(storeProofImage!.path).length();
        double logoMB = logoSize / (1024 * 1024);
        if (logoMB > 1) {
          submitting = false;
          notifyListeners();
          Fluttertoast.showToast(msg: "txt_logo_max_1mb");
          return;
        }
        files['logo'] = File(storeProofImage!.path);
      }

      if (storeBackgroundImage != null) {
        int bgSize = await File(storeBackgroundImage!.path).length();
        double bgMB = bgSize / (1024 * 1024);
        if (bgMB > 1) {
          submitting = false;
          notifyListeners();
          Fluttertoast.showToast(msg: "txt_bg_max_1mb");
          return;
        }
        files['store_background_image'] = File(storeBackgroundImage!.path);
      }

      // Extract email from social links
      String? email;
      final socialLinksList = <Map<String, String>>[];

      for (var link in _socialLinks) {
        if (link['type'] == 'email' && link['url'] != null && link['url']!.trim().isNotEmpty) {
          email = link['url']!.trim();
          socialLinksList.add({
            'type': 'email',
            'url': email!,
          });
        } else if (link['url'] != null && link['url']!.trim().isNotEmpty) {
          socialLinksList.add(link);
        }
      }

      // Prepare fields
      Map<String, String> fields = {
        'name': name.trim(),
        'mobile': mobile.trim(),
        'country': 'Tajikistan',
        'city': city.trim(),
        'address': address.trim(),
        'delivery_by_seller': deliveryBySeller ? '1' : '0',
        'self_pickup': selfPickup ? '1' : '0',
        'description': description.trim(),
        'working_hours': _workingHoursString(),
      };

      // Add email if found
      if (email != null && email.isNotEmpty) {
        fields['email'] = email;
      }

      // Add location only for offline stores
      if (sellOffline && latitude != null && longitude != null) {
        fields['latitude'] = latitude;
        fields['longitude'] = longitude;
      }

      // Add return policy as nested fields
      if (_storePolicy != null) {
        if (_storePolicy!['type'] != null) {
          fields['return_policy[type]'] = _storePolicy!['type'].toString();
        }
        if (_storePolicy!['days'] != null) {
          fields['return_policy[days]'] = _storePolicy!['days'].toString();
        }
        if (_storePolicy!['message'] != null) {
          fields['return_policy[message]'] = _storePolicy!['message'].toString();
        }
      }

      // Add delivery policy as nested fields
      if (_deliveryPolicy != null) {
        if (_deliveryPolicy!['type'] != null) {
          fields['delivery_policy[type]'] = _deliveryPolicy!['type'].toString();
        }
        if (_deliveryPolicy!['message'] != null) {
          fields['delivery_policy[message]'] = _deliveryPolicy!['message'].toString();
        }
        if (_deliveryPolicy!['days'] != null) {
          fields['delivery_policy[days]'] = _deliveryPolicy!['days'].toString();
        }
      }

      // Add delivery days
      if (_deliveryDays != null && _deliveryDays!.isNotEmpty) {
        fields['delivery_days'] = _deliveryDays.toString();
      }

      // Add background color
      if (_storeBackgroundColor != null) {
        final hex = '#${_storeBackgroundColor!.value.toRadixString(16).substring(2).toUpperCase()}';
        fields['background_color'] = hex;
      }

      // Add store types
      final storeTypes = getStoreTypes();
      for (int i = 0; i < storeTypes.length; i++) {
        fields['type[$i]'] = storeTypes[i];
      }

      // Add social links
      if (socialLinksList.isNotEmpty) {
        for (int i = 0; i < socialLinksList.length; i++) {
          final link = socialLinksList[i];
          fields['social_links[$i][type]'] = link['type']!;
          fields['social_links[$i][url]'] = link['url']!;
        }
      }

      addDeliveryConfigFields(fields);

      debugPrint("========== STORE UPDATE DEBUG ==========");
      debugPrint("STORE ID: $storeId");
      debugPrint("ENDPOINT: /vendor/store/edit/$storeId");
      debugPrint("FIELDS: $fields");
      debugPrint("FILES COUNT: ${files.length}");
      debugPrint("========================================");

      // Make API request to update store
      final res = await ApiService.multipart(
        endpoint: '/vendor/store/edit/$storeId',
        token: token,
        fields: fields,
        files: files,
      );

      submitting = false;
      notifyListeners();

      if (res != null && (res['status'] == true || res['success'] == true)) {
        Fluttertoast.showToast(
          msg: res['message'] ?? "txt_store_updated_success",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (formKey.currentContext != null) {
            Navigator.of(formKey.currentContext!).pop(true);
          }
        });
      } else {
        String errorMsg = "txt_store_update_failed";
        if (res != null && res['message'] != null) {
          errorMsg = res['message'].toString();
        }

        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

        debugPrint("API Error Response: $res");
      }
    } catch (e) {
      submitting = false;
      notifyListeners();
      debugPrint("Store update error: $e");

      Fluttertoast.showToast(
        msg: "txt_something_wrong: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }



  // Background Color Property (Only one color)


  void updateStoreBackgroundColor(Color color) {
    _storeBackgroundColor = color;
    notifyListeners();
  }


  // Add these properties to AddStoreController class
  Color? _storePrimaryColor;
  Color? _storeAccentColor;
  Color? _storeBackgroundColor;
  Color? _storeCardColor;

  Color? get storePrimaryColor => _storePrimaryColor;
  Color? get storeAccentColor => _storeAccentColor;
  Color? get storeBackgroundColor => _storeBackgroundColor;
  Color? get storeCardColor => _storeCardColor;

  void updateStoreColors({
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
    required Color cardColor,
  }) {
    _storePrimaryColor = primaryColor;
    _storeAccentColor = accentColor;
    _storeBackgroundColor = backgroundColor;
    _storeCardColor = cardColor;
    notifyListeners();
  }


// Save store colors (could be saved to shared preferences or API)
  void saveStoreColors({
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
    required Color cardColor,
  }) {
    _storePrimaryColor = primaryColor;
    _storeAccentColor = accentColor;
    _storeBackgroundColor = backgroundColor;
    _storeCardColor = cardColor;

    // Save to shared preferences
    _saveColorsToPrefs();
    notifyListeners();
  }

  Future<void> _saveColorsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('store_primary_color', _storePrimaryColor!.value);
    prefs.setInt('store_accent_color', _storeAccentColor!.value);
    prefs.setInt('store_background_color', _storeBackgroundColor!.value);
    prefs.setInt('store_card_color', _storeCardColor!.value);
  }

  Future<void> loadStoreColors() async {
    final prefs = await SharedPreferences.getInstance();
    _storePrimaryColor = Color(prefs.getInt('store_primary_color') ?? Colors.black.value);
    _storeAccentColor = Color(prefs.getInt('store_accent_color') ?? Colors.amber.value);
    _storeBackgroundColor = Color(prefs.getInt('store_background_color') ?? Colors.white.value);
    _storeCardColor = Color(prefs.getInt('store_card_color') ?? Colors.grey.shade50.value);
    notifyListeners();
  }


}