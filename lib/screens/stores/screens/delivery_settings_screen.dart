// import 'package:flutter/material.dart';
//
// import '../../../extensions/context_extension.dart';
// import '../../citys/CityService.dart';
//
// class DeliveryConfigModel {
//   final String city;
//   bool enabled;
//   String deliveryType; // courier / taxi
//   int deliveryTimeValue; // 3 / 6 / 9 / 12 / 1
//   String deliveryTimeUnit; // hours / day
//   String description;
//
//   DeliveryConfigModel({
//     required this.city,
//     this.enabled = false,
//     this.deliveryType = 'courier',
//     this.deliveryTimeValue = 3,
//     this.deliveryTimeUnit = 'hours',
//     this.description = 'Door delivery',
//   });
//
//   Map<String, String> toApiMap() {
//     return {
//       'city': city,
//       'enabled': enabled ? '1' : '0',
//       'delivery_type': deliveryType,
//       'delivery_time_value': deliveryTimeValue.toString(),
//       'delivery_time_unit': deliveryTimeUnit,
//       'description': deliveryType == 'courier'
//           ? 'Door delivery'
//           : 'Taxi / intercity station delivery',
//     };
//   }
// }
//
// class DeliverySettingsScreen extends StatefulWidget {
//   final List<DeliveryConfigModel> initialConfigs;
//
//   const DeliverySettingsScreen({
//     super.key,
//     required this.initialConfigs,
//   });
//
//   @override
//   State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
// }
//
// class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
//   final CityService cityService = CityService();
//
//   bool loading = true;
//   List<DeliveryConfigModel> configs = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadCities();
//   }
//
//   Future<void> loadCities() async {
//     final cities = await cityService.fetchCities();
//
//     final oldConfigs = widget.initialConfigs;
//
//     configs = cities.map((city) {
//       final match = oldConfigs.where(
//             (e) => e.city.trim().toLowerCase() == city.name.trim().toLowerCase(),
//       );
//
//       if (match.isNotEmpty) {
//         final old = match.first;
//         return DeliveryConfigModel(
//           city: city.name,
//           enabled: old.enabled,
//           deliveryType: old.deliveryType,
//           deliveryTimeValue: old.deliveryTimeValue,
//           deliveryTimeUnit: old.deliveryTimeUnit,
//           description: old.description,
//         );
//       }
//
//       return DeliveryConfigModel(city: city.name);
//     }).toList();
//
//     // ✅ If old delivery city is not found in city API list, still show it
//     for (final old in oldConfigs) {
//       final exists = configs.any(
//             (e) => e.city.trim().toLowerCase() == old.city.trim().toLowerCase(),
//       );
//
//       if (!exists) {
//         configs.add(old);
//       }
//     }
//
//     setState(() => loading = false);
//   }
//
//
//   String getDeliveryText(DeliveryConfigModel item) {
//     final time = item.deliveryTimeUnit == 'day'
//         ? '1 day'
//         : '${item.deliveryTimeValue} hours';
//
//     if (item.deliveryType == 'courier') {
//       return '🚚 Door delivery • $time';
//     }
//
//     return '🚕 Taxi / intercity delivery • $time';
//   }
//
//   String getEtaText(DeliveryConfigModel item) {
//     if (item.deliveryTimeUnit == 'day') {
//       return context.tr('txt_tomorrow');
//     }
//
//     return context.tr('txt_today');
//   }
//
//   void save() {
//     final selected = configs.where((e) => e.enabled).toList();
//     Navigator.pop(context, selected);
//   }
//
//   void updateDeliveryType(DeliveryConfigModel item, String type) {
//     setState(() {
//       item.deliveryType = type;
//       item.description = type == 'courier'
//           ? 'Door delivery'
//           : 'Taxi / intercity station delivery';
//     });
//   }
//
//   void updateDeliveryTime(DeliveryConfigModel item, String value) {
//     final parts = value.split('_');
//
//     setState(() {
//       item.deliveryTimeValue = int.parse(parts[0]);
//       item.deliveryTimeUnit = parts[1];
//     });
//   }
//
//   String getDropdownValue(DeliveryConfigModel item) {
//     return '${item.deliveryTimeValue}_${item.deliveryTimeUnit}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF6F6F6),
//       appBar: AppBar(
//         title: const Text('Delivery Settings'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         actions: [
//           TextButton(
//             onPressed: save,
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: configs.length,
//         itemBuilder: (context, index) {
//           final item = configs[index];
//
//           return Container(
//             margin: const EdgeInsets.only(bottom: 14),
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CheckboxListTile(
//                   contentPadding: EdgeInsets.zero,
//                   value: item.enabled,
//                   title: Text(
//                     item.city,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text(
//                     item.enabled
//                         ? '${getDeliveryText(item)}\n${getEtaText(item)}'
//                         : context.tr('txt_delivery_disabled'),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       item.enabled = value ?? false;
//                     });
//                   },
//                 ),
//
//                 if (item.enabled) ...[
//                   const SizedBox(height: 10),
//
//                   Text(
//                     context.tr('txt_delivery_type'),
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ChoiceChip(
//                           label:  Text(context.tr('txt_delivery_time')),
//                           selected: item.deliveryType == 'courier',
//                           onSelected: (_) {
//                             updateDeliveryType(item, 'courier');
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ChoiceChip(
//                           label:  Text(context.tr('txt_taxi')),
//                           selected: item.deliveryType == 'taxi',
//                           onSelected: (_) {
//                             updateDeliveryType(item, 'taxi');
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 14),
//
//                    Text(
//                     context.tr('txt_delivery_time'),
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   DropdownButtonFormField<String>(
//                     value: getDropdownValue(item),
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.grey.shade50,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     items: const [
//                       DropdownMenuItem(
//                         value: '3_hours',
//                         child: Text('3 hours'),
//                       ),
//                       DropdownMenuItem(
//                         value: '6_hours',
//                         child: Text('6 hours'),
//                       ),
//                       DropdownMenuItem(
//                         value: '9_hours',
//                         child: Text('9 hours'),
//                       ),
//                       DropdownMenuItem(
//                         value: '12_hours',
//                         child: Text('12 hours'),
//                       ),
//                       DropdownMenuItem(
//                         value: '1_day',
//                         child: Text('1 day'),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       if (value == null) return;
//                       updateDeliveryTime(item, value);
//                     },
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   Text(
//                     getDeliveryText(item),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       color: Colors.green,
//                     ),
//                   ),
//
//                   const SizedBox(height: 4),
//
//                   Text(
//                     getEtaText(item),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../extensions/context_extension.dart';
import '../../citys/CityService.dart';

class DeliveryConfigModel {
  final String city;
  bool enabled;
  String deliveryType; // courier / taxi
  int deliveryTimeValue; // 3 / 6 / 9 / 12 / 1
  String deliveryTimeUnit; // hours / day
  String description;

  DeliveryConfigModel({
    required this.city,
    this.enabled = false,
    this.deliveryType = 'courier',
    this.deliveryTimeValue = 3,
    this.deliveryTimeUnit = 'hours',
    this.description = 'Door delivery',
  });

  Map<String, String> toApiMap() {
    return {
      'city': city,
      'enabled': enabled ? '1' : '0',
      'delivery_type': deliveryType,
      'delivery_time_value': deliveryTimeValue.toString(),
      'delivery_time_unit': deliveryTimeUnit,
      'description': deliveryType == 'courier'
          ? 'Door delivery'
          : 'Taxi / intercity station delivery',
    };
  }
}

class DeliverySettingsScreen extends StatefulWidget {
  final List<DeliveryConfigModel> initialConfigs;

  const DeliverySettingsScreen({
    super.key,
    required this.initialConfigs,
  });

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  final CityService cityService = CityService();

  bool loading = true;
  List<DeliveryConfigModel> configs = [];

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    final cities = await cityService.fetchCities();
    final oldConfigs = widget.initialConfigs;

    configs = cities.map((city) {
      final match = oldConfigs.where(
            (e) => e.city.trim().toLowerCase() == city.name.trim().toLowerCase(),
      );

      if (match.isNotEmpty) {
        final old = match.first;
        return DeliveryConfigModel(
          city: city.name,
          enabled: old.enabled,
          deliveryType: old.deliveryType,
          deliveryTimeValue: old.deliveryTimeValue,
          deliveryTimeUnit: old.deliveryTimeUnit,
          description: old.description,
        );
      }

      return DeliveryConfigModel(city: city.name);
    }).toList();

    for (final old in oldConfigs) {
      final exists = configs.any(
            (e) => e.city.trim().toLowerCase() == old.city.trim().toLowerCase(),
      );

      if (!exists) {
        configs.add(old);
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  String getDeliveryText(DeliveryConfigModel item) {
    final time = item.deliveryTimeUnit == 'day'
        ? context.tr('txt_1_day')
        : '${item.deliveryTimeValue} ${context.tr('txt_hours')}';

    if (item.deliveryType == 'courier') {
      return '🚚 ${context.tr('txt_door_delivery')} • $time';
    }

    return '🚕 ${context.tr('txt_taxi_intercity_delivery')} • $time';
  }

  String getEtaText(DeliveryConfigModel item) {
    if (item.deliveryTimeUnit == 'day') {
      return context.tr('txt_tomorrow');
    }

    return context.tr('txt_today');
  }

  void save() {
    final selected = configs.where((e) => e.enabled).toList();
    Navigator.pop(context, selected);
  }

  void updateDeliveryType(DeliveryConfigModel item, String type) {
    setState(() {
      item.deliveryType = type;
      item.description = type == 'courier'
          ? 'Door delivery'
          : 'Taxi / intercity station delivery';
    });
  }

  void updateDeliveryTime(DeliveryConfigModel item, String value) {
    final parts = value.split('_');

    setState(() {
      item.deliveryTimeValue = int.parse(parts[0]);
      item.deliveryTimeUnit = parts[1];
    });
  }

  String getDropdownValue(DeliveryConfigModel item) {
    return '${item.deliveryTimeValue}_${item.deliveryTimeUnit}';
  }

  String getTimeLabel(String value) {
    if (value == '1_day') {
      return context.tr('txt_1_day');
    }

    final hours = value.split('_').first;
    return '$hours ${context.tr('txt_hours')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        title: Text(context.tr('txt_delivery_settings')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: save,
            child: Text(context.tr('txt_save')),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final item = configs[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: item.enabled,
                  title: Text(
                    item.city,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    item.enabled
                        ? '${getDeliveryText(item)}\n${getEtaText(item)}'
                        : context.tr('txt_delivery_disabled'),
                  ),
                  onChanged: (value) {
                    setState(() {
                      item.enabled = value ?? false;
                    });
                  },
                ),

                if (item.enabled) ...[
                  const SizedBox(height: 10),

                  Text(
                    context.tr('txt_delivery_type'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(context.tr('txt_courier')),
                          selected: item.deliveryType == 'courier',
                          onSelected: (_) {
                            updateDeliveryType(item, 'courier');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(context.tr('txt_taxi')),
                          selected: item.deliveryType == 'taxi',
                          onSelected: (_) {
                            updateDeliveryType(item, 'taxi');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    context.tr('txt_delivery_time'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: getDropdownValue(item),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '3_hours',
                        child: Text(getTimeLabel('3_hours')),
                      ),
                      DropdownMenuItem(
                        value: '6_hours',
                        child: Text(getTimeLabel('6_hours')),
                      ),
                      DropdownMenuItem(
                        value: '9_hours',
                        child: Text(getTimeLabel('9_hours')),
                      ),
                      DropdownMenuItem(
                        value: '12_hours',
                        child: Text(getTimeLabel('12_hours')),
                      ),
                      DropdownMenuItem(
                        value: '1_day',
                        child: Text(getTimeLabel('1_day')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      updateDeliveryTime(item, value);
                    },
                  ),

                  const SizedBox(height: 12),

                  Text(
                    getDeliveryText(item),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    getEtaText(item),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}