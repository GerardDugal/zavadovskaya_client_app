import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

  Future<void> _launchPaymentUrl(String url, BuildContext context) async {
    try {
      if (kIsWeb) {
        html.window.open(url, '_blank');
      } else {
        throw UnsupportedError('Запуск URL работает только в вебе');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка открытия оплаты: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Повторить',
            onPressed: () => _launchPaymentUrl(url, context),
          ),
        ),
      );
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
            _launchPaymentUrl(state.response.confirmationUrl, context);
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
