class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException(this.message, {this.prefix, this.statusCode});

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException(super.message)
    : super(prefix: "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException(super.message) : super(prefix: "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException(super.message) : super(prefix: "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException(super.message) : super(prefix: "Invalid Input: ");
}
