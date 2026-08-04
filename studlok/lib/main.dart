import 'package:flutter/material.dart';

import 'app_router.dart';
import 'theme/studlok_theme.dart';

void main() {
  runApp(const StudlokApp());
}

class StudlokApp extends StatelessWidget {
  const StudlokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studlok',
      theme: buildStudlokTheme(),
      home: const AppRouter(),
    );
  }
}
