// lib/blocs/auth/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zavadovskaya_client_app/config.dart';
import '../../data/repositories/auth_repository.dart';

part 'password_recovery_event.dart';
part 'password_recovery_state.dart';

class PasswordRecoveryBloc extends Bloc<PasswordRecoveryEvent, PasswordRecoveryState> {
  final AuthRepository authRepository;

  PasswordRecoveryBloc({required this.authRepository}) : super(PasswordRecoveryInitial()) {
    on<PasswordRecovery>(_passwordRecovery);
  }

Future<void> _passwordRecovery(PasswordRecovery event, Emitter<PasswordRecoveryState> emit) async {
  try {
    emit(PasswordRecoveryInitial()); // Сбросить состояние

    final recovery = await authRepository.passwordRecovery(event.login);
    emit(RecoveryPassword(recovery: recovery));
    Config.mprint('AuthBloc: восстановление успешно, результат: $recovery');
  } catch (e) {
    Config.mprint('AuthBloc: ошибка при восстановлении: $e');
    emit(const RecoveryPassword(recovery: false));
  }
}

  // Добавьте этот метод при необходимости:
  // Future<void> _onSubmitSmsCode(...) async { ... }
}
