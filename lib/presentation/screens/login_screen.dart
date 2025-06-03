import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../blocs/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final phoneMask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (isLogin) {
        context.read<AuthBloc>().add(LoginRequested(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            ));
      } else {
        context.read<AuthBloc>().add(RegistrationRequested(
              name: nameController.text.trim(),
              phone: phoneController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            ));
      }
    }
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
      style: TextStyle(color: Colors.white),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isLogin ? 'Вход' : 'Регистрация',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure && state.error.isNotEmpty) {
            // Вызов через microtask, чтобы не вызвать showDialog во время build
            Future.microtask(() {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: Text('Ошибка'),
                  content: Text(state.error),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('ОК'),
                    ),
                  ],
                ),
              );
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      isLogin ? 'Добро пожаловать!' : 'Создайте аккаунт',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    if (!isLogin) ...[
                      _buildTextField(
                        controller: nameController,
                        hint: 'Имя',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Введите имя' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: phoneController,
                        hint: 'Телефон',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [phoneMask],
                        validator: (_) {
                          final phone = phoneMask.getUnmaskedText();
                          if (phone.isEmpty || phone.length != 10) {
                            return 'Введите корректный номер';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    _buildTextField(
                      controller: emailController,
                      hint: 'Email или номер телефона',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Введите email или номер телефона';
                        
                        // Проверка на email
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        // Проверка на российский номер телефона (+7XXXXXXXXXX, 8XXXXXXXXXX, 7XXXXXXXXXX)
                        final phoneRegex = RegExp(r'^(\+7|7|8)?[\s\-]?\(?[0-9]{3}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$');
                        
                        if (!emailRegex.hasMatch(v) && !phoneRegex.hasMatch(v)) {
                          return 'Неверный формат email или номера телефона';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: passwordController,
                      hint: 'Пароль',
                      obscure: !isPasswordVisible,
                      isPasswordToggle: true,
                      toggleVisibility: () => setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      }),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Введите пароль';
                        if (v.length < 6) return 'Минимум 6 символов';
                        return null;
                      },
                    ),
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _buildTextField(
                          controller: confirmPasswordController,
                          hint: 'Подтвердите пароль',
                          obscure: !isConfirmPasswordVisible,
                          isPasswordToggle: true,
                          toggleVisibility: () => setState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
                          }),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Повторите пароль';
                            }
                            if (v != passwordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state is AuthLoading ? null : () => _onSubmit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is AuthLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isLogin ? 'Войти' : 'Зарегистрироваться',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        isLogin = !isLogin;
                        confirmPasswordController.clear();
                      }),
                      child: Text(
                        isLogin
                            ? 'Нет аккаунта? Зарегистрируйтесь'
                            : 'Уже есть аккаунт? Войти',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
