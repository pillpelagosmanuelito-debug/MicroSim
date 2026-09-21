import 'package:flutter/material.dart';

import 'modules/home/home_shell.dart';
import 'theme/app_theme.dart';

class MicroSimApp extends StatelessWidget {
  const MicroSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroSim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      home: const HomeShell(),
      builder: (context, child) => SafeArea(child: child!),
    );
  }
}
