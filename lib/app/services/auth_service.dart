import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;

      notifyListeners();
    });
  }

  // Email va parol bilan ro'yxatdan o'tish
  Future<bool> signUpWithEmail(
      String email, String password, String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Username saqlash
      await result.user?.updateDisplayName(username);

      // Profil yangilash uchun reload qilish
      await result.user?.reload();
      _user = _auth.currentUser;

      // User ma'lumotlarini localStorage ga saqlash
      await _saveUserData(result.user);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      if (e.code == 'weak-password') {
        _errorMessage = 'Parol juda oson';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Bu email allaqachon ro\'yxatdan o\'tkazilgan';
      } else {
        _errorMessage = e.message;
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Email va parol bilan kirish
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // User ma'lumotlarini localStorage ga saqlash
      await _saveUserData(result.user);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      if (e.code == 'user-not-found') {
        _errorMessage = 'Bu email topilmadi';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Noto\'g\'ri parol';
      } else {
        _errorMessage = e.message;
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Google bilan kirish
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Google Sign-In dialog ochish
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User Google Sign-In ni bekor qildi
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Google Sign-In authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _isLoading = false;
        _errorMessage = "Google authentication tokenlari olinmadi";
        print("Google auth failed: Missing tokens");
        notifyListeners();
        return false;
      }

      // Firebase ga kirish uchun credential olish
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Credential bilan Firebase ga kirish
      UserCredential result = await _auth.signInWithCredential(credential);

      // User ma'lumotlarini localStorage ga saqlash
      await _saveUserData(result.user);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = "Firebase auth xato: ${e.message}";
      print("Firebase auth error: ${e.code} - ${e.message}");
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      print("Google sign in error: $_errorMessage");
      notifyListeners();
      return false;
    }
  }

  // Chiqish
  Future<void> signOut() async {
    try {
      // Google sign out
      await _googleSignIn.signOut();
      // Firebase sign out
      await _auth.signOut();

      // Local storage dan o'chirish
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Parolni tiklash
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // User ma'lumotlarini localStorage ga saqlash
  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', user.displayName ?? '');

      // await prefs.setString("user", jsonEncode(user.))
    }

    Future<String> getUsername() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      return prefs.getString("user_name") ?? "";
    }
  }
}
