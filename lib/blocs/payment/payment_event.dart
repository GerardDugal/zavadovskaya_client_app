// lib/blocs/payment/payment_event.dart

part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PayForCourseRequested extends PaymentEvent {
  final PaymentRequest paymentRequest;

  const PayForCourseRequested({required this.paymentRequest});

  @override
  List<Object?> get props => [paymentRequest];
}
