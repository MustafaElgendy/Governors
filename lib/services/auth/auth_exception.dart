//login exception
class UserNotFoundAuthExceotion implements Exception {}

class WrongPasswordFoundAuthException implements Exception {}

//register exception
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class OperationNotAllowedAuthException implements Exception {}

//generic exception
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class UserIsDisabled implements Exception {}
