// lib/data/repositories/payment_repository.dart

import '../models/payment.dart';

abstract class PaymentRepository {
  Future<PaymentResponse> payForCourse(PaymentRequest paymentRequest);
}