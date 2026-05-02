// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/translate_provider.dart';
//
// extension TranslateX on BuildContext {
//   String tr(String key) {
//     return watch<TranslateProvider>().t(key);
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translate_provider.dart';

extension TranslateX on BuildContext {
  String tr(String key) {
    return Provider.of<TranslateProvider>(this, listen: false).t(key);
  }
}