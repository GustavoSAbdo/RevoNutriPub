import 'package:complete/homePage/homePageItems/feedback_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:complete/homePage/home.dart';
import 'package:complete/regLogPage/register_screen.dart';
import 'package:complete/regLogPage/register_screen_two.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:complete/homePage/drawerItems/macrosManual/total_meal_goal_form.dart';
import 'package:complete/homePage/drawerItems/macrosManual/macros_manual_page.dart';
import 'package:complete/homePage/drawerItems/macrosManual/ref_meal_goal_form.dart';
import 'package:complete/regLogPage/sign_in.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeNotifier notifier = Provider.of<ThemeNotifier>(context);

    // Ensure MaterialApp is the top-level widget.
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: notifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português do Brasil
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            // Display loading screen while waiting for authentication
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          User? user = snapshot.data;
          if (user == null) {
            // User is not logged in
            return const CustomSignInScreen();
          }
          
          // Fetch user data and determine the initial route
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> docSnapshot) {
              if (docSnapshot.connectionState != ConnectionState.done) {
                // Show loading indicator while fetching user data
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (docSnapshot.hasData && docSnapshot.data != null) {
                var userData = docSnapshot.data!.data() as Map<String, dynamic>;
                bool regDoisCompleted = userData['regDois'] == true;
                return regDoisCompleted ? HomePage(userId: user.uid) : const RegistroParteDois();
              }
              
              // Default to Registration Part Two if data fetch is unsuccessful
              return const RegistroParteDois();
            },
          );
        },
      ),
      routes: {
        '/login': (context) => const CustomSignInScreen(),
        '/home': (context) => HomePage(userId: FirebaseAuth.instance.currentUser!.uid),
        '/register': (context) => const RegisterPage(),
        '/registerDois': (context) => const RegistroParteDois(),
        '/macrosDaDietaManualmente': (context) => const MealGoalFormPage(),
        '/macrosPage': (context) => const MacrosManualPage(),
        '/macrosRefPage': (context) => MealInputPage(),
        '/feedbackPage' : (context) => FeedbackUserDialog(),
      },
    );
  }
}
