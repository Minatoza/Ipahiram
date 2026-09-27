import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/loan_repository.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    DevicePreview(
      // Keeping the device_preview wrapper, as in the Module 4/5 starters
      // (proposal, Section 7). Disabled outside debug builds.
      enabled: !kReleaseMode,
      builder: (context) => const IpahiramApp(),
    ),
  );
}

class IpahiramApp extends StatefulWidget {
  const IpahiramApp({super.key});

  @override
  State<IpahiramApp> createState() => _IpahiramAppState();
}

class _IpahiramAppState extends State<IpahiramApp> {
  final LoanRepository _repository = LoanRepository();

  @override
  void initState() {
    super.initState();
    _repository.load(); // Week 1 spike: read the saved list on launch.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ipahiram',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: appTheme,
      home: HomeScreen(repository: _repository),
    );
  }
}
