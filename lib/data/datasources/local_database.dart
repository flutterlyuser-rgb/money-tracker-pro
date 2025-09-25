// import 'package:isar/isar.dart';
// import 'package:money_tracker/core/constants/app_constants.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:money_tracker/data/models/transaction_model.dart';

// class LocalDatabase {
//   static Isar? _instance;

//   static Future<Isar> initialize() async {
//     if (_instance != null) return _instance!;
    
//     final dir = await getApplicationDocumentsDirectory();
//     _instance = await Isar.open(
//       [TransactionModelSchema],
//       directory: dir.path,
//       name: AppConstants.databaseName,
//     );
    
//     return _instance!;
//   }

//   static Isar get instance {
//     if (_instance == null) {
//       throw Exception('Database not initialized. Call initialize() first.');
//     }
//     return _instance!;
//   }
// }