abstract class EmailAvailabilityRepository {
  // Please note that the email address may already be taken by the user themselves, in which case you must indicate that the email address is valid.
  // You will need to search for the email address in the Register table and the User table, as someone else may be registering with the same email address.
  Future<bool> checkEmailAvailability({required String email});
}
