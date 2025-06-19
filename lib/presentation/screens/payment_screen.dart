import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;

import '../../blocs/payment/payment_bloc.dart';
import '../../data/models/payment.dart';

class PaymentScreen extends StatefulWidget {
  final int courseID;
  final double coursePrice;

  const PaymentScreen({
    Key? key,
    required this.courseID,
    required this.coursePrice,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? confirmationUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата'),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }

          if (state is PaymentSuccess) {
            setState(() {
              confirmationUrl = state.response.confirmationUrl;
            });
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Цена курса: ${widget.coursePrice.toStringAsFixed(2)} рублей',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    context.read<PaymentBloc>().add(
                      PayForCourseRequested(
                        paymentRequest: PaymentRequest(
                          courseID: widget.courseID,
                          amount: widget.coursePrice,
                        ),
                      ),
                    );
                  },
                  child: const Text('Создать оплату'),
                ),

                const SizedBox(height: 20),

                if (confirmationUrl != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Перейти к оплате'),
                    onPressed: () {
                      // В Safari этот вызов будет воспринят как действие пользователя
                      html.window.open(confirmationUrl!, '_blank');
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
