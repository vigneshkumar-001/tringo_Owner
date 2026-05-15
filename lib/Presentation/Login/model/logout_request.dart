class LogoutRequest {
  final String refreshToken;
  final String? sessionToken;

  const LogoutRequest({required this.refreshToken, this.sessionToken});

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
        if ((sessionToken ?? '').trim().isNotEmpty) 'sessionToken': sessionToken,
      };
}

