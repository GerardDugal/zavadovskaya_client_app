// lib/blocs/payment/payment_state.dart

part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final PaymentResponse response;

  const PaymentSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class PaymentFailure extends PaymentState {
  final String error;

  const PaymentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
