// lib/blocs/payment/payment_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/auth_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;
  final AuthRepository authRepository;

  PaymentBloc({
    required this.paymentRepository,
    required this.authRepository,
  }) : super(PaymentInitial()) {
    on<PayForCourseRequested>(_onPayForCourseRequested);
  }

  Future<void> _onPayForCourseRequested(
    PayForCourseRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    try {
      final response = await paymentRepository.payForCourse(event.paymentRequest);
      // При успехе возвращаем PaymentSuccess с объектом PaymentResponse,
      // где есть confirmationUrl
      emit(PaymentSuccess(response: response));
    } catch (e) {
      emit(PaymentFailure(error: e.toString()));
    }
  }
}
