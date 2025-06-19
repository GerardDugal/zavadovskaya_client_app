import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';
import 'payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  PaymentRepositoryImpl({
    required this.baseUrl,
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<PaymentResponse> payForCourse(PaymentRequest paymentRequest) async {
    final headers = await _getHeaders();
    headers['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
    final response = await http.post(
      Uri.parse('$baseUrl/payment/payment/create/for_course/${paymentRequest.courseID}'),
      headers: headers,
      body: json.encode({'amount': paymentRequest.amount}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaymentResponse(
        confirmationUrl: data['confirmation_url'] ?? '',
      );
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка оплаты курса';
      throw Exception(error);
    }
  }
}