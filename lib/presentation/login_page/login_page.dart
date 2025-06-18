import 'package:flutter/material.dart';
import 'package:university_events/data/services/auth_service.dart';
import 'package:university_events/presentation/home_page/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _message;
  bool _isLoading = false;
  bool _is2FaRequired = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await _authService.signIn(
        _usernameController.text,
        _passwordController.text,
        otp: _is2FaRequired ? _otpController.text : null,
      );

      if (response.is2FaRequired) {
        setState(() {
          _is2FaRequired = true;
          _message = 'OTP отправлен на вашу почту. Введите его для входа.';
        });
      } else {

        setState(() {
          _message = 'Вход выполнен успешно!';
        });

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _message = 'Ошибка: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await _authService.resendOtp(_usernameController.text);
      setState(() {
        _message = response.message;
      });
    } catch (e) {
      setState(() {
        _message = 'Ошибка при повторной отправке OTP: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход в приложение')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Имя пользователя'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            if (_is2FaRequired)
              Column(
                children: [
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'OTP'),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: const Text('Отправить OTP повторно'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _signIn,
              child: Text(_is2FaRequired ? 'Подтвердить OTP и войти' : 'Войти'),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.startsWith('Ошибка') ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}