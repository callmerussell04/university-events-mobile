class SigninRequestDto {
  final String username;
  final String password;
  final String? otp;

  SigninRequestDto({required this.username, required this.password, this.otp});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'otp': otp,
  };
}

class JwtResponse {
  final String? accessToken;
  final int id;
  final String username;
  final List<String> roles;
  final bool is2FaRequired;

  JwtResponse({
    this.accessToken,
    required this.id,
    required this.username,
    required this.roles,
    required this.is2FaRequired,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) => JwtResponse(
    accessToken: json['token'],
    id: json['id'],
    username: json['username'],
    roles: List<String>.from(json['roles']),
    is2FaRequired: json['mfaRequired'],
  );
}

class MessageResponse {
  final String message;

  MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) => MessageResponse(
    message: json['message'],
  );
}

class OtpResendRequestDto {
  final String username;

  OtpResendRequestDto({required this.username});

  Map<String, dynamic> toJson() => {
    'username': username,
  };
}

class DeviceTokenDto {
  final String? deviceToken;

  DeviceTokenDto({required this.deviceToken});

  Map<String, dynamic> toJson() => {
    'deviceToken': deviceToken,
  };
}