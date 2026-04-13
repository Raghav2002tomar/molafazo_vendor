//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
//
//
//
// // lib/screens/address/address_selection_screen.dart
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// // lib/widgets/address_selection_screen.dart
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import '../screens/citys/CitySearchScreen.dart';
//
// class AddressSelectionScreen extends StatefulWidget {
//   final Function(String, double, double) onAddressSelected;
//   final String? initialAddress;
//   final double? initialLat;
//   final double? initialLng;
//
//   const AddressSelectionScreen({
//     super.key,
//     required this.onAddressSelected,
//     this.initialAddress,
//     this.initialLat,
//     this.initialLng,
//   });
//
//   @override
//   State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
// }
//
// class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final MapController _mapController = MapController();
//   final TextEditingController _cityController = TextEditingController();
//   String? selectedCity;
//   bool _isLoading = false;
//   bool _isSearching = false;
//   String? _selectedAddress;
//   LatLng? _selectedLocation;
//   List<Map<String, dynamic>> _searchResults = [];
//   Timer? _searchDebounce;
//   bool _isMapReady = false;
//   LatLng? _userLocation;
//
//   // Default location (India)
//   final LatLng _defaultLocation = const LatLng(28.6139, 77.2090);
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Set initial location if provided
//     if (widget.initialLat != null && widget.initialLng != null) {
//       _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
//       _selectedAddress = widget.initialAddress;
//     }
//
//     _initLocation();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchDebounce?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _initLocation() async {
//     await _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     PermissionStatus locationPermission = await Permission.location.request();
//
//     if (locationPermission.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//           timeLimit: const Duration(seconds: 10),
//         );
//
//         setState(() {
//           _userLocation = LatLng(position.latitude, position.longitude);
//           if (_selectedLocation == null) {
//             _selectedLocation = _userLocation;
//             _reverseGeocode(_userLocation!);
//           }
//         });
//
//         if (_isMapReady && _selectedLocation != null) {
//           _mapController.move(_selectedLocation!, 15);
//         }
//       } catch (e) {
//         print('Location error: $e');
//         if (_selectedLocation == null) {
//           setState(() {
//             _selectedLocation = _defaultLocation;
//           });
//           _reverseGeocode(_defaultLocation);
//         }
//       }
//     } else {
//       if (_selectedLocation == null) {
//         setState(() {
//           _selectedLocation = _defaultLocation;
//         });
//         _reverseGeocode(_defaultLocation);
//       }
//     }
//   }
//
//   Future<void> _reverseGeocode(LatLng ll) async {
//     try {
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(ll.latitude, ll.longitude);
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//
//         /// Use selected city if available
//         final cityName = selectedCity ?? place.locality ?? '';
//
//         final addressParts = [
//           place.street,
//           place.subLocality,
//           cityName,
//           place.administrativeArea,
//           place.postalCode,
//         ]
//             .where((s) => s != null && s.toString().trim().isNotEmpty)
//             .map((e) => e.toString())
//             .toList();
//
//         String address = addressParts.join(', ');
//
//         /// Force replace map city with selected city
//         if (selectedCity != null && place.locality != null) {
//           address = address.replaceAll(place.locality!, selectedCity!);
//         }
//
//         if (mounted) {
//           setState(() {
//             _selectedAddress =
//             address.isNotEmpty ? address : 'Selected location';
//           });
//         }
//       }
//     } catch (e) {
//       print('Reverse geocode error: $e');
//     }
//   }
//   void _onMapCreated() {
//     setState(() => _isMapReady = true);
//     if (_selectedLocation != null) {
//       _mapController.move(_selectedLocation!, 15);
//     }
//   }
//
//   void _onMapTap(LatLng latLng) {
//     setState(() {
//       _selectedLocation = latLng;
//     });
//     _reverseGeocode(latLng);
//   }
//
//   Future<void> _searchPlaces(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = [];
//         _isSearching = false;
//       });
//       return;
//     }
//
//     setState(() => _isSearching = true);
//
//     try {
//       await Future.delayed(const Duration(milliseconds: 500)); // Rate limiting
//
//       final response = await http.get(
//         Uri.parse(
//           'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=10&addressdetails=1',
//         ),
//         headers: {
//           'User-Agent': 'MolafzoVendor/1.0',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         if (mounted) {
//           setState(() {
//             _searchResults = data.cast<Map<String, dynamic>>();
//           });
//         }
//       }
//     } catch (e) {
//       print('Search error: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isSearching = false);
//       }
//     }
//   }
//
//   void _selectPlace(Map<String, dynamic> place) {
//     setState(() {
//       _searchResults = [];
//       _searchController.clear();
//       _isSearching = false;
//     });
//
//     try {
//       double lat = double.parse(place['lat']);
//       double lon = double.parse(place['lon']);
//
//       final newLocation = LatLng(lat, lon);
//
//       setState(() {
//         _selectedLocation = newLocation;
//       });
//
//       _mapController.move(newLocation, 17);
//       _reverseGeocode(newLocation);
//     } catch (e) {
//       _showErrorSnackBar('Failed to select location');
//     }
//   }
//
//   void _confirmSelection() {
//
//     if (selectedCity == null) {
//       _showErrorSnackBar("Please select city first");
//       return;
//     }
//
//     if (_selectedLocation == null) {
//       _showErrorSnackBar('Please select a location');
//       return;
//     }
//
//     widget.onAddressSelected(
//       _selectedAddress ?? 'Selected location',
//       _selectedLocation!.latitude,
//       _selectedLocation!.longitude,
//     );
//   }
//   void _moveToUserLocation() {
//     if (_userLocation != null) {
//       _mapController.move(_userLocation!, 15);
//       setState(() {
//         _selectedLocation = _userLocation;
//       });
//       _reverseGeocode(_userLocation!);
//     } else {
//       _getCurrentLocation();
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Select Address',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _confirmSelection,
//             child: Text(
//               'Done',
//               style: TextStyle(
//                 color: colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: TextField(
//               controller: _cityController,
//               readOnly: true,
//               decoration: InputDecoration(
//                 hintText: "Select City",
//                 prefixIcon: const Icon(Icons.location_city),
//                 suffixIcon: const Icon(Icons.arrow_drop_down),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onTap: () async {
//                 final city = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const CitySearchScreen(),
//                   ),
//                 );
//
//                 if (city != null) {
//                   setState(() {
//                     selectedCity = city.name;
//                     _cityController.text = city.name;
//                   });
//
//                   /// Update address with new selected city
//                   if (_selectedLocation != null) {
//                     _reverseGeocode(_selectedLocation!);
//                   }
//                 }
//               },            ),
//           ),
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _searchController,
//                     onChanged: (value) {
//                       _searchDebounce?.cancel();
//                       _searchDebounce = Timer(
//                         const Duration(milliseconds: 500),
//                             () => _searchPlaces(value),
//                       );
//                     },
//                     decoration: InputDecoration(
//                       hintText: 'Search for area, street, landmark...',
//                       hintStyle: TextStyle(color: Colors.grey.shade400),
//                       prefixIcon: Icon(Icons.search, color: colorScheme.primary),
//                       suffixIcon: _isSearching
//                           ? const Padding(
//                         padding: EdgeInsets.all(12),
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//
//                   // Search Results
//                   if (_searchResults.isNotEmpty)
//                     Container(
//                       constraints: const BoxConstraints(maxHeight: 200),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           top: BorderSide(color: Colors.grey.shade200),
//                         ),
//                       ),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: _searchResults.length,
//                         itemBuilder: (context, index) {
//                           final place = _searchResults[index];
//                           return ListTile(
//                             leading: Icon(Icons.location_on, color: colorScheme.primary, size: 20),
//                             title: Text(
//                               place['display_name'] ?? '',
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                             onTap: () => _selectPlace(place),
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Map View
//           Expanded(
//             child: Stack(
//               children: [
//                 FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _selectedLocation ?? _defaultLocation,
//                     initialZoom: 15,
//                     onTap: (_, latLng) => _onMapTap(latLng),
//                     onMapReady: _onMapCreated,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       userAgentPackageName: 'com.molafzo_vendor',
//                       maxZoom: 19,
//                     ),
//                     if (_selectedLocation != null)
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: _selectedLocation!,
//                             width: 80,
//                             height: 80,
//                             child: const MapPin(),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//
//                 // Center crosshair (always shows where you're pointing)
//                 Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 30,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: colorScheme.primary.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Container(
//                             width: 12,
//                             height: 12,
//                             decoration: BoxDecoration(
//                               color: colorScheme.primary,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 2),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Current Location Button
//                 Positioned(
//                   right: 16,
//                   bottom: 30,
//                   child: FloatingActionButton.small(
//                     onPressed: _moveToUserLocation,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.my_location,
//                       color: colorScheme.primary,
//                       size: 22,
//                     ),
//                   ),
//                 ),
//
//                 // Selected Address Preview
//                 if (_selectedAddress != null)
//                   Positioned(
//                     bottom: 100,
//                     left: 16,
//                     right: 16,
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: colorScheme.primary.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.location_on,
//                               color: colorScheme.primary,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               _selectedAddress!,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xFF1A1A2E),
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                 // OpenStreetMap Attribution
//                 Positioned(
//                   bottom: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(4),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: const Text(
//                       '© OpenStreetMap',
//                       style: TextStyle(fontSize: 10, color: Colors.black87),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Map Pin Widget
// class MapPin extends StatelessWidget {
//   const MapPin({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: colorScheme.primary,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: colorScheme.primary.withOpacity(0.5),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.location_on,
//             color: Colors.white,
//             size: 24,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Simple Map Pin Widget
//
// // Simple Map Pin Widget
//
// // Simple Map Pin Widget
//
// // Draggable Map Pin Widget
// class DraggableMapPin extends StatelessWidget {
//   const DraggableMapPin({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: cs.primary,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: cs.primary.withOpacity(0.5),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.location_on,
//             color: Colors.white,
//             size: 24,
//           ),
//         ),
//         Container(
//           width: 2,
//           height: 20,
//           color: cs.primary.withOpacity(0.5),
//         ),
//       ],
//     );
//   }
// }
//
// // lib/screens/address/model/address_model.dart
//
// class AddressModel {
//   final String id;
//   final String addressLine1;
//   final String? addressLine2;
//   final String city;
//   final String state;
//   final String country;
//   final String postalCode;
//   final double latitude;
//   final double longitude;
//   final AddressType type;
//   late final bool isDefault;
//
//   AddressModel({
//     required this.id,
//     required this.addressLine1,
//     this.addressLine2,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.postalCode,
//     required this.latitude,
//     required this.longitude,
//     required this.type,
//     this.isDefault = false,
//   });
//
//   String get fullAddress =>
//       '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}, $city, $state, $country - $postalCode';
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'address_line1': addressLine1,
//       'address_line2': addressLine2,
//       'city': city,
//       'state': state,
//       'country': country,
//       'postal_code': postalCode,
//       'latitude': latitude,
//       'longitude': longitude,
//       'type': type.index,
//       'is_default': isDefault,
//     };
//   }
//
//   factory AddressModel.fromJson(Map<String, dynamic> json) {
//     return AddressModel(
//       id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       addressLine1: json['address_line1'] ?? '',
//       addressLine2: json['address_line2'],
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       country: json['country'] ?? '',
//       postalCode: json['postal_code'] ?? '',
//       latitude: json['latitude']?.toDouble() ?? 0.0,
//       longitude: json['longitude']?.toDouble() ?? 0.0,
//       type: AddressType.values[json['type'] ?? 0],
//       isDefault: json['is_default'] ?? false,
//     );
//   }
// }
//
// enum AddressType {
//   home,
//   work,
//   other;
//
//   String get displayName {
//     switch (this) {
//       case AddressType.home:
//         return 'Home';
//       case AddressType.work:
//         return 'Work';
//       case AddressType.other:
//         return 'Other';
//     }
//   }
//
//   IconData get icon {
//     switch (this) {
//       case AddressType.home:
//         return Icons.home_outlined;
//       case AddressType.work:
//         return Icons.work_outline;
//       case AddressType.other:
//         return Icons.location_on_outlined;
//     }
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/citys/CitySearchScreen.dart';

class AddressSelectionScreen extends StatefulWidget {
  // final Function(String, double, double) onAddressSelected;
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;

  const AddressSelectionScreen({
    super.key,
    // required this.onAddressSelected,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  String? _selectedCity;
  String? _selectedAddress;

  // Mock coordinates - you can remove these if you don't need coordinates
  double _selectedLat = 0.0;
  double _selectedLng = 0.0;

  @override
  void initState() {
    super.initState();

    // Set initial values if provided
    if (widget.initialAddress != null) {
      _selectedAddress = widget.initialAddress;
      _addressController.text = widget.initialAddress!;
    }

    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedLat = widget.initialLat!;
      _selectedLng = widget.initialLng!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

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
        _cityController.text = city.name;
      });
    }
  }

  void _confirmSelection() {
    if (_selectedCity == null) {
      _showErrorSnackBar("Please select city first");
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your address");
      return;
    }

    // Build full address with landmark if provided
    String fullAddress = _addressController.text.trim();
    if (_landmarkController.text.trim().isNotEmpty) {
      fullAddress += ', ${_landmarkController.text.trim()}';
    }
    fullAddress += ', ${_selectedCity!}';

    Navigator.pop(context, {
      'address': fullAddress,
      'lat': _selectedLat,
      'lng': _selectedLng,
      'city': _selectedCity, // ✅ ADD THIS
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enter Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: Text(
              'Done',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Selection
            const Text(
              'City *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCity ?? "Select city",
                        style: TextStyle(
                          color: _selectedCity == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Address Field
            const Text(
              'Address *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter complete address (street, area, etc.)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Landmark Field (Optional)
            const Text(
              'Landmark (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _landmarkController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g., near city mall, opposite bank, etc.',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please enter your complete address including street, area, and any additional details for accurate delivery.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Example Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_disabled_rounded, color: Colors.grey.shade600, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Example Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '123 Main Street, Sector 15,\nNear Central Park,\nNew Delhi, Delhi ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/address/model/address_model.dart
class AddressModel {
  final String id;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final AddressType type;
  late final bool isDefault;

  AddressModel({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.isDefault = false,
  });

  String get fullAddress =>
      '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}, $city, $state, $country - $postalCode';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.index,
      'is_default': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      type: AddressType.values[json['type'] ?? 0],
      isDefault: json['is_default'] ?? false,
    );
  }
}

enum AddressType {
  home,
  work,
  other;

  String get displayName {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AddressType.home:
        return Icons.home_outlined;
      case AddressType.work:
        return Icons.work_outline;
      case AddressType.other:
        return Icons.location_on_outlined;
    }
  }
}