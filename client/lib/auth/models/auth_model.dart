class LoginData {
  final String email;
  final String password;

  LoginData({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'username': email,
        'password': password,
      };
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

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      };
}

class ResetPasswordData {
  final String email;

  ResetPasswordData({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}
