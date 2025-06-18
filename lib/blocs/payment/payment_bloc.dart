import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment.dart';
import '../../data/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<PayForCourseRequested>(_onPayForCourseRequested);
  }

  Future<void> _onPayForCourseRequested(
    PayForCourseRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final response = await paymentRepository.payForCourse(event.paymentRequest);
      emit(PaymentSuccess(response: response));
    } catch (e) {
      emit(PaymentFailure(error: e.toString()));
    }
  }
}