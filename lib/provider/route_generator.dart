import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/screens/admin_screen.dart';
import 'package:velayo_flutterapp/screens/home.dart';
import 'package:velayo_flutterapp/widgets/initialize.dart';

Map<String, Widget Function(BuildContext)> routeGenerator = {
  '/': (context) => const InitializeScreen(),
  '/home': (context) => const HomeScreen(),
  '/admin': (context) => const AdminScreen(),
};