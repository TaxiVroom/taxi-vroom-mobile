// We use a sealed class rather than an object with optional fields
// so that it is impossible to send an empty or inconsistent update.
// Each type contains only the fields it needs
sealed class RegistrationFlowUpdate {
  const RegistrationFlowUpdate();
}

final class EmailUpdate extends RegistrationFlowUpdate {
  const EmailUpdate({required this.email});

  final String email;
}

final class NameUpdate extends RegistrationFlowUpdate {
  const NameUpdate({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}
