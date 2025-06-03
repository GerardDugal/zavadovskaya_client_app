import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zavadovskaya_client_app/blocs/auth/auth_bloc.dart';
import 'package:zavadovskaya_client_app/blocs/password_recovery/password_recovery_bloc.dart';
import 'package:zavadovskaya_client_app/presentation/screens/login_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
  String input = emailController.text.trim();

  // Если это номер телефона — извлечь только последние 10 цифр
  final phoneDigits = input.replaceAll(RegExp(r'\D'), '');
  if (phoneDigits.length >= 10 && !input.contains('@')) {
    input = phoneDigits.substring(phoneDigits.length - 10); // последние 10 цифр
  }

  context.read<PasswordRecoveryBloc>().add(PasswordRecovery(
    login: input,
  ));
}


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    bool isPasswordToggle = false,
    void Function()? toggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPasswordToggle
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: toggleVisibility,
              )
            : null,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordRecoveryBloc, PasswordRecoveryState>(
      listener: (context, state) {
        if (state is RecoveryPassword) {
          if (state.recovery) {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Неправильный логин')),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'Восстановление пароля',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                     controller: emailController,
                     hint: "Email или номер телефона, введённый при регистрации",
                     keyboardType: TextInputType.emailAddress,
                     validator: (v) {
                       if (v == null || v.isEmpty) return 'Введите email или номер телефона';
                   
                       final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                       final phoneRegex = RegExp(r'^(\+7|7|8)?[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}$');
                   
                       if (!emailRegex.hasMatch(v) && !phoneRegex.hasMatch(v)) {
                         return 'Неверный формат email или номера телефона';
                       }
                       return null;
                     },
                   ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _onSubmit();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Отправить ссылку на почту',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
