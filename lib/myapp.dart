
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';



class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TwoFactorAuthDemo(),
    );
  }
}

class TwoFactorAuthDemo extends StatefulWidget {
  @override
  _TwoFactorAuthDemoState createState() => _TwoFactorAuthDemoState();
}

class _TwoFactorAuthDemoState extends State<TwoFactorAuthDemo> {
  String secretKey = ''; // Replace with your secret key
  int currentOTP = 0;

  @override
  void initState() {
    super.initState();
    loadSecretKey();
  }

  Future<void> loadSecretKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      secretKey = prefs.getString('secretKey') ?? '';
      currentOTP = generateOTP();
    });
  }

  int generateOTP() {
    if (secretKey.isNotEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final otp = OTP.generateTOTPCodeString(
        secretKey,
        now,
        interval: 30, // TOTP time interval in seconds (default is 30)
        length: 6,   // OTP length (default is 6)
        algorithm: Algorithm.SHA1, // You can change the hash algorithm
      );
      return int.parse(otp);
    }
    return 0;
  }

  Future<void> saveSecretKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secretKey', key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOTP Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Current OTP: $currentOTP', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newSecretKey = generateRandomSecretKey();
                saveSecretKey(newSecretKey);
                setState(() {
                  secretKey = newSecretKey;
                  currentOTP = generateOTP();
                });
              },
              child: Text('Generate New Secret Key'),
            ),
          ],
        ),
      ),
    );
  }

  String generateRandomSecretKey() {
    final random = Random.secure();
    final List<int> bytes = List.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}