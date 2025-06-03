class LoginData {
  final String email;
  final String password;

  LoginData({required this.email, required this.password});
}

class RegisterData {
  final String email;
  final String password;
  final String confirmPassword;

  RegisterData({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class ResetPasswordData {
  final String email;

  ResetPasswordData({required this.email});
}
