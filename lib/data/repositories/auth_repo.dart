import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippify/core/errors/app_exception.dart';

abstract class AuthRepo {
  signUp({
    required String email,
    required String password,
    required String name,
    String? nickName,
  });
  signIn({required String email, required String password});
}

class AuthRepoImpl extends AuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    String? nickName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'name': name,
          'nickname': nickName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw InvalidInputException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw BadRequestException('The account already exists for that email.');
      } else {
        throw FetchDataException(e.message ?? 'Sign-up failed.');
      }
    } catch (e) {
      log('SignUp error: $e');
      throw FetchDataException('Unexpected error occurred.');
    }
  }

  @override
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UnauthorisedException('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw UnauthorisedException('Wrong password provided.');
      } else {
        throw FetchDataException(e.message ?? 'Sign-in failed.');
      }
    } catch (e) {
      log('SignIn error: $e');
      throw FetchDataException('Unexpected error occurred.');
    }
  }
}
