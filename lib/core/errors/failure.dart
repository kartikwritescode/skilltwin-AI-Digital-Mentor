abstract class Failure {
  final String message;
  Failure(this.message);
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
