import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Encrypted Hive Storage
  // Initialize Firebase App
  // Initialize drift sqlite
  
  runApp(const MCSFApp());
}

class MCSFApp extends StatelessWidget {
  const MCSFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimodal Cognitive Screening Framework',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const InitializationScreen(),
    );
  }
}

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.biotech, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              'MCSF v0.02',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Initializing Secure Modules...'),
          ],
        ),
      ),
    );
  }
}
