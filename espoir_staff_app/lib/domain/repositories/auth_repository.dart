import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Stream<User?> get onAuthStateChanged;
}
