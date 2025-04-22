import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'screens/landing_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/interest_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/chat_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDa7BPmsP9XV3aBumnKIN8JyArqEziLmXc",
          authDomain: "chatapp-f2460.firebaseapp.com",
          projectId: "chatapp-f2460",
          storageBucket: "chatapp-f2460.firebasestorage.app",
          messagingSenderId: "258107692441",
          appId: "1:258107692441:android:6b792133d4e0d3d53aaf08",
          measurementId: "G-QXY91P16MZ"
        ),
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        title: 'Interest Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingScreen(),
          '/signup': (context) => const SignupScreen(),
          '/signin': (context) => const SigninScreen(),
          '/interests': (context) => const InterestSelectionScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/matches': (context) => const MatchesScreen(),
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}
