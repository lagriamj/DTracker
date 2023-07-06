import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:dtracket_project/landingpage.dart';
import 'package:dtracket_project/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF30336b),
            ),
      ),
      home: AnimatedSplashScreen(
        splash: Center(
          child: Container(
            child: Lottie.asset('assets/images/corgi1.json'),
          ),
        ),
        duration: 3000,
        backgroundColor: color,
        splashIconSize: 300,
        splashTransition: SplashTransition.fadeTransition,
        nextScreen: MyHomePage(),
      ),
    );
  }

  Color color = const Color(0xFF30336b);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Center(
                  child: SpinKitPouringHourGlassRefined(
                    size: 60,
                    color: colortitle,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            } else if (snapshot.hasData) {
              return const LandingPage();
            } else {
              return const LoginPage();
            }
          },
        ),
      );
  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);
}
