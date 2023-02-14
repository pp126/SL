library exception;

class LogicException implements Exception {
  final int code;
  final String msg;

  const LogicException(this.code, this.msg);

  @override
  String toString() => msg;
}

class NetException implements Exception {
  final String msg;

  const NetException(this.msg);

  @override
  String toString() => msg;
}

class NotDataException implements Exception {
  final String msg;

  const NotDataException(this.msg);

  @override
  String toString() => msg;
}

class AuthException implements Exception {
  const AuthException();

  @override
  String toString() => '登录状态失效';
}
