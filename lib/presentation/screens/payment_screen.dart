import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../data/models/payment.dart';

class PaymentScreen extends StatelessWidget {
  final int courseID;
  final double coursePrice;

  const PaymentScreen({
    Key? key,
    required this.courseID,
    required this.coursePrice,
  }) : super(key: key);

  Future<void> _launchPaymentUrl(String url) async {
  try {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppWebView, // Изменено для Safari
        webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'Accept': 'text/html'},
        ),
      );
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl( // Fallback для iOS
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата курса'),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            _launchPaymentUrl(state.response.confirmationUrl);
          }
          if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Цена курса: ${coursePrice.toStringAsFixed(2)} рублей',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(
                        PayForCourseRequested(
                          paymentRequest: PaymentRequest(
                            courseID: courseID,
                            amount: coursePrice,
                          ),
                        ),
                      );
                    },
                    child: const Text('Оплатить'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}