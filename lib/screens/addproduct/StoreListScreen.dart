//
// import 'package:flutter/material.dart';
// import 'package:molafzo_vendor/screens/addproduct/contreller.dart';
// import 'package:molafzo_vendor/screens/addproduct/model.dart';
// import 'package:provider/provider.dart';
//
// class AddProductStoreScreen extends StatelessWidget {
//   final AddProductControllernew controller;
//   const AddProductStoreScreen({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: controller,
//       child: Consumer<AddProductControllernew>(
//         builder: (context, c, _) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               title: const Text('Select Store'),
//               elevation: 0,
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () {
//                     c.fetchStores();
//                   },
//                 ),
//               ],
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Choose a Store',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Select the store where you want to list this product',
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Debug info - remove in production
//                   if (c.stores.isEmpty && !c.loadingStores)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Debug: No stores found. Check API response.',
//                         style: TextStyle(color: Colors.red.shade700, fontSize: 12),
//                       ),
//                     ),
//
//                   // Stores List
//                   Expanded(
//                     child: c.loadingStores
//                         ? const Center(child: CircularProgressIndicator())
//                         : c.stores.isEmpty
//                         ? _buildEmptyState(c)
//                         : ListView.builder(
//                       itemCount: c.stores.length,
//                       itemBuilder: (context, index) {
//                         final store = c.stores[index];
//                         return _buildStoreCard(
//                           context,
//                           c,
//                           store,
//                           isSelected: c.selectedStore == store,
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStoreCard(BuildContext context, AddProductControllernew c, StoreModel store,
//       {required bool isSelected}) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: isSelected ? Colors.green : Colors.transparent,
//           width: 2,
//         ),
//       ),
//       child: ListTile(
//         onTap: () {
//           c.selectedStore = store;
//           c.notifyListeners();
//           Navigator.pop(context, true); // Return to main page
//         },
//         leading: CircleAvatar(
//           backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
//           child: Icon(
//             Icons.store,
//             color: isSelected ? Colors.white : Colors.grey.shade600,
//           ),
//         ),
//         title: Text(
//           store.name,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(store.address ?? 'No address provided'),
//         trailing: isSelected
//             ? const Icon(Icons.check_circle, color: Colors.green)
//             : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(AddProductControllernew c) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.storefront, size: 64, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text(
//             'No Stores Found',
//             style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tap refresh to try again',
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: () => c.fetchStores(),
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// StoreListScreen.dart - Updated with black theme

import 'package:flutter/material.dart';
import 'package:molafzo_vendor/screens/addproduct/contreller.dart';
import 'package:molafzo_vendor/screens/addproduct/model.dart';
import 'package:provider/provider.dart';

class AddProductStoreScreen extends StatelessWidget {
  final AddProductControllernew controller;
  const AddProductStoreScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AddProductControllernew>(
        builder: (context, c, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text('Select Store', style: TextStyle(color: Colors.black, fontSize: 16)),
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    c.fetchStores();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Store',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select the store where you want to list this product',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: c.loadingStores
                        ? const Center(child: CircularProgressIndicator())
                        : c.stores.isEmpty
                        ? _buildEmptyState(c)
                        : ListView.builder(
                      itemCount: c.stores.length,
                      itemBuilder: (context, index) {
                        final store = c.stores[index];
                        return _buildStoreCard(context , c, store);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreCard(context, AddProductControllernew c, StoreModel store) {
    final isSelected = c.selectedStore == store;

    return InkWell(
      onTap: () {
        c.selectedStore = store;
        c.notifyListeners();
        Navigator.pop(context, true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
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
              child: Icon(Icons.store, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store.address ?? 'No address provided',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.black : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AddProductControllernew c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No Stores Found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap refresh to try again',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => c.fetchStores(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }
}