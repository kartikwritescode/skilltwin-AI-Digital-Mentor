abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network Unavailable']) : super(message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server Error']) : super(message);
}

class AuthFailure extends Failure {
  AuthFailure([String message = 'Authentication Failed']) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure([String message = 'Invalid Input']) : super(message);
}

class QuotaFailure extends Failure {
  QuotaFailure([String message = 'API usage limit reached (quota exceeded). Please try again later or verify your API key.']) : super(message);
}
