class AppUser {
  final String uid;
  final String? email;
  final String? displayName; // Added displayName as it's common

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}
