import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      SheetsApi.spreadsheetsScope,
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Sign in error: $error');
      return null;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<AuthClient?> getAuthenticatedClient() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) return null;

    final auth = await account.authentication;
    final authenticatedClient = AuthClient(
      http.Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          auth.accessToken!,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        _googleSignIn.scopes,
      ),
    );

    return authenticatedClient;
  }
}