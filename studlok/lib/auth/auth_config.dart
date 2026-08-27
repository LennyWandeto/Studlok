import 'package:supabase_flutter/supabase_flutter.dart';

class AuthConfig {
  AuthConfig._();

  static const supabaseUrl = 'https://fgsncfngdcwbfaibdqpc.supabase.co';
  static const supabasePublishableKey = 'sb_publishable_ERjO-FjiOAIgeibt2ZSzSg_nKct4bgL';

  static const googleIosClientId =
      '491196225038-r0v0239us18krhtoj2bk763s4d7lrcao.apps.googleusercontent.com';
  static const googleWebClientId =
      '491196225038-7olpevd4rlkpg9udp04evnkhi82vqm1n.apps.googleusercontent.com';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }
}
