// lib/src/auth/auth_service_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exception.dart';
import '../storage/storage_service.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final StorageService _storageService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthServiceImpl(
    this._storageService,
  );

  @override
  Future<void> initialize() async {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
      } else {
      }
    });
  }

  @override
  Future<void> dispose() async {
    await signOut();
  }

  @override
  Future<String> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _storageService.set('auth_token', token);
        await _storageService.set('user_id', credential.user!.uid);
      }

      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        'Sign in failed',
        originalError: e,
      );
    }
  }

  @override
  Future<String> signUp(
    String email,
    String password,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _storageService.set('auth_token', token);
        await _storageService.set('user_id', credential.user!.uid);
      }

      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        'Sign up failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _storageService.remove('auth_token');
      await _storageService.remove('user_id');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        'Password reset failed',
        originalError: e,
      );
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return await _storageService.get<String>('user_id');
    }
    return userId;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null ||
        await _storageService.get<String>('auth_token') != null;
  }

  @override
  Future<String?> getAuthToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return await _storageService.get<String>('auth_token');
  }

  @override
  Future<void> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        await _storageService.set('auth_token', token);
      }
    } catch (e) {
      rethrow;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed';
    }
  }
}

