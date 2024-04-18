import 'package:complete/homePage/home.dart';
import 'package:complete/regLogPage/pag_registro_dois.dart';
import 'package:complete/regLogPage/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'regLogPage/sign_in.dart';
import 'package:complete/homePage/drawerItems/macrosManual/total_meal_goal_form.dart';
import 'package:complete/homePage/drawerItems/macrosManual/macros_manual_page.dart';
import 'package:complete/homePage/drawerItems/macrosManual/ref_meal_goal_form.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeNotifier notifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: notifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const CustomSignInScreen(),
      routes: {
        '/login': (context) => const CustomSignInScreen(),
        '/home': (context) {
          String? userId = FirebaseAuth.instance.currentUser?.uid;
          return userId != null
              ? HomePage(userId: userId)
              : const CustomSignInScreen();
        },
        '/register': (context) => const RegisterPage(),
        '/registerDois': (context) => const RegistroParteDois(),
        '/macrosDaDietaManualmente': (context) =>  const MealGoalFormPage(),
        '/macrosPage':(context) => const MacrosManualPage(),
        '/macrosRefPage':(context) =>  MealInputPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português do Brasil
      ],
    );
  }
}
