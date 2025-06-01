import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _webViewController;
  bool isSubmitting = false;
  bool showWebView = false;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Можно добавить прогресс-индикатор
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: $error');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('payments/v2/success')) {
              _onPaymentSuccess();
              return NavigationDecision.prevent;
            }
            if (request.url.contains('failUrl') || request.url.contains('cancel')) {
              _onPaymentFailure();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<bool> _onWillPop() async {
    // Если WebView показан — прячем его, иначе позволяем выйти
    if (showWebView) {
      setState(() {
        showWebView = false;
      });
      return false;
    }
    return true;
  }

  void _onPayButtonPressed() {
    final paymentRequest = PaymentRequest(
      courseID: widget.courseID,
      amount: widget.coursePrice,
    );

    context.read<PaymentBloc>().add(
          PayForCourseRequested(paymentRequest: paymentRequest),
        );
  }

  void _onPaymentSuccess() {
    Navigator.pushReplacementNamed(context, '/home');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Оплата успешно завершена!')),
    );
  }

  void _onPaymentFailure() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Оплата была отменена или не удалась.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Оплата курса'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (showWebView) {
                setState(() {
                  showWebView = false;
                });
              } else {
                Navigator.pop(context);
              }
            },
            tooltip: 'Назад',
          ),
        ),
        body: BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) async {
            if (state is PaymentLoading) {
              setState(() => isSubmitting = true);
            } else {
              setState(() => isSubmitting = false);
            }

            if (state is PaymentSuccess) {
              final confirmationUrl = state.response.confirmationUrl;
              await _webViewController.loadRequest(Uri.parse(confirmationUrl));
              setState(() {
                showWebView = true;
              });
            }

            if (state is PaymentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: showWebView ? _buildWebView() : _buildInitialBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Цена курса: ${widget.coursePrice.toStringAsFixed(2)} рублей',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        if (isSubmitting)
          const Center(child: CircularProgressIndicator())
        else
          ElevatedButton(
            onPressed: _onPayButtonPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Оплатить',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (isSubmitting)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
