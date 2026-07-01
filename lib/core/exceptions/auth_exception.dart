class SessionExpiredException implements Exception {
  final String message;

  const SessionExpiredException([
    this.message = 'Phiên đăng nhập đã hết hạn',
  ]);

  @override
  String toString() => message;
}