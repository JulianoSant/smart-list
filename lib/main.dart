import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/core/app_routes.dart';
import 'package:smart_list/core/firebase/auth_service.dart';
import 'package:smart_list/core/firebase/firestore_service.dart';
import 'package:smart_list/core/services/api_service.dart';
import 'package:smart_list/core/themes.dart';
import 'package:smart_list/providers/auth_provider.dart';
import 'package:smart_list/providers/contact_provider.dart';
import 'package:smart_list/views/home/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCaHmZZOpaIwvEhS0AtIyyC3sj6AfKuPrc",
        authDomain: "smart-list-f380b.firebaseapp.com",
        projectId: "smart-list-f380b",
        storageBucket: "smart-list-f380b.firebasestorage.app",
        messagingSenderId: "384410847965",
        appId: "1:384410847965:web:41f5816137cb6bdecaa934"),
  );

  final authService = AuthService();
  final firestoreService = FirestoreService();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactProvider(firestoreService, apiService),
        ),
        Provider(create: (_) => ApiService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      // darkTheme: AppThemes.darkTheme,
      routerConfig: AppRoutes.router,
      builder: (context, child) {
        final auth = Provider.of<AuthProvider>(context);

        return auth.isInitialized ? child! : const InitializationScreen();
      },
    );
  }
}
