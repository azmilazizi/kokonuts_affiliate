import 'package:flutter/material.dart';

import 'config.dart';
import 'home_page.dart';

void main() => runApp(const AffiliateApp());

class AffiliateApp extends StatelessWidget {
  const AffiliateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kokonuts Affiliate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kOrange, primary: kOrange),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
