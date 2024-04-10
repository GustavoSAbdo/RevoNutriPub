import 'package:complete/firebase_options.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/homePage/hive/hive_food_item.dart';
import 'package:complete/homePage/hive/hive_refeicao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late Box<HiveFoodItem> foodBox;
late Box<HiveFoodItem> dataBaseFoods;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(HiveFoodItemAdapter());
  Hive.registerAdapter(HiveRefeicaoAdapter());

  dataBaseFoods = await Hive.openBox<HiveFoodItem>('dataBaseFoods');
  foodBox = await Hive.openBox<HiveFoodItem>('foodBox');
  final refeicaoBox = await Hive.openBox<HiveRefeicao>('refeicaoBox');

  if (dataBaseFoods.isEmpty) {
    await transferDataToHive();
  }

  runApp(
    Provider<Box<HiveRefeicao>>.value(
      value: refeicaoBox,
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> transferDataToHive() async {
  // Buscar dados do Firebase
  var querySnapshot = await FirebaseFirestore.instance.collection('alimentos').get();
  for (var doc in querySnapshot.docs) {
    var foodItem = HiveFoodItem.fromMap(doc.data()); // Supondo que você tenha um método fromMap
    await dataBaseFoods.put(doc.id, foodItem);
  }
}