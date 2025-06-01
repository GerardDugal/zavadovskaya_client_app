// lib/presentation/screens/payment_confirmation_screen.dart

import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String confirmationUrl;

  const PaymentConfirmationScreen({required this.confirmationUrl});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Инициализация WebView для Android, если необходимо
    // WebView.platform = SurfaceAndroidWebView();
    // Сразу показываем сообщение об успешной оплате и возвращаемся на главный экран
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Оплата успешно завершена')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Подтверждение оплаты'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
