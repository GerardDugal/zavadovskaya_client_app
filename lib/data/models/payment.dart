// lib/data/models/payment.dart

import 'package:equatable/equatable.dart';

class PaymentRequest extends Equatable {
  final int courseID;
  final double amount;

  const PaymentRequest({
    required this.courseID,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseID': courseID,
      'amount': amount,
    };
  }

  @override
  List<Object?> get props => [courseID, amount];
}

class PaymentResponse extends Equatable {
  final String confirmationUrl;

  const PaymentResponse({
    required this.confirmationUrl,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      confirmationUrl: json['confirmation_url'],
    );
  }

  @override
  List<Object?> get props => [confirmationUrl];
}

// class PaymentStatus extends Equatable {
//   final String confirmationUrl;

//   const PaymentResponse({
//     required this.confirmationUrl,
//   });

//   factory PaymentResponse.fromJson(Map<String, dynamic> json) {
//     return PaymentResponse(
//       confirmationUrl: json['confirmation_url'],
//     );
//   }

//   @override
//   List<Object?> get props => [confirmationUrl];
// }