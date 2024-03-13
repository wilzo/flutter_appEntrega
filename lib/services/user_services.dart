import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto/models/userLocal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserServices {
  //Widget para autenticação do usuário
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //Widget para persistência do dados do usuário
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final UserLocal? _userLocal = UserLocal();

  //método do tipo get para obter uma referência da coleção no firebase
  CollectionReference get _collectionRef => _firestore.collection('users');

  //método para obter a referência do documento no firebase
  DocumentReference get _docRef => _firestore.doc('users/${_userLocal!.id!}');

  //método de registro de usuário no Firebase
  signUp(String userName, String email, String password) async {
    User? user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    _userLocal!.id = user!.uid;
    _userLocal!.email = user.email;
    _userLocal!.userName = userName;

    saveData();
  }

  //método para realizar a autenticação do usuário
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return Future.value(true);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  //Método para persistir dados do usuário no firebase firestore
  saveData() {
    _docRef.set(_userLocal!.toJson());
  }
}
