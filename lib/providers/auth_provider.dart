import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_list/core/firebase/auth_service.dart';
import 'package:smart_list/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool isLoading = false;

  AuthProvider(this._authService) {
    _initAuthListener();
  }

  UserModel? get currentUser => _user;

  Future<void> _initAuthListener() async {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
      } else {
        _user = await _loadUserData(firebaseUser.uid);
      }
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading = true;
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );

      _user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
      );

      await _saveUserData(_user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final userCredential = await _authService.login(
        email,
        password,
      );

      _user = await _loadUserData(userCredential.user!.uid);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleLoginError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> _loadUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('Perfil do usuário não encontrado');
    }

    return UserModel.fromFirestore(doc);
  }

  Future<void> _saveUserData(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw _handleLogoutError(e);
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reautenticação
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Exclui dados do Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Exclui conta do Auth
        await user.delete();

        _user = null;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleDeleteAccountError(e);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'E-mail já está em uso';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'E-mail inválido';
      default:
        return 'Erro no cadastro: ${e.message}';
    }
  }

  String _handleLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      case 'user-disabled':
        return 'Conta desativada';
      default:
        return 'Erro no login: ${e.message}';
    }
  }

  String _handleDeleteAccountError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Senha incorreta';
      case 'requires-recent-login':
        return 'Sessão expirada. Faça login novamente';
      default:
        return 'Erro ao excluir conta: ${e.message}';
    }
  }

  String _handleLogoutError(dynamic error) {
    if (error is FirebaseAuthException) {
      return 'Erro ao sair: ${error.message}';
    }
    return 'Erro desconhecido ao sair';
  }
}
