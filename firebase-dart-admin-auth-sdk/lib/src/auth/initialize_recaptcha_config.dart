import 'dart:convert';
import 'package:firebase_dart_admin_auth_sdk/firebase_dart_admin_auth_sdk.dart';

class InitializeRecaptchaConfigService {
  final FirebaseAuth auth;

  InitializeRecaptchaConfigService(this.auth);

  Future<void> initialize() async {
    final url = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/recaptchaConfig',
      {'key': auth.apiKey},
    );

    final response = await auth.httpClient.post(
      url,
      body: json.encode({
        'projectId': auth.projectId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw FirebaseAuthException(
        code: 'recaptcha-init-failed',
        message:
            'Failed to initialize reCAPTCHA configuration: ${response.body}',
      );
    }

    // Process the response if needed
    // final responseData = json.decode(response.body);
  }
}
