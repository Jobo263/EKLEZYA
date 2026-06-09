import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserProfile> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in aborted');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    return _getOrCreateProfile(user);
  }

  @override
  Future<UserProfile> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    // Apple only provides name on first sign-in
    String displayName = user.displayName ?? '';
    if (displayName.isEmpty &&
        appleCredential.givenName != null) {
      displayName =
          '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
              .trim();
    }

    return _getOrCreateProfile(user, displayName: displayName);
  }

  @override
  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getOrCreateProfile(userCredential.user!);
  }

  @override
  Future<UserProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user!.updateDisplayName(displayName);
    return _getOrCreateProfile(userCredential.user!, displayName: displayName);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('User profile not found for uid: $uid');
    }
    return _profileFromFirestore(doc.data()!, uid);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(_profileToFirestore(profile), SetOptions(merge: true));
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<UserProfile> _getOrCreateProfile(
    User user, {
    String? displayName,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (doc.exists && doc.data() != null) {
      return _profileFromFirestore(doc.data()!, user.uid);
    }

    // Create new profile
    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName ?? 'Utilisateur',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    await ref.set(_profileToFirestore(profile));
    return profile;
  }

  UserProfile _profileFromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      parishName: data['parishName'] as String?,
      dioceseName: data['dioceseName'] as String?,
      country: data['country'] as String?,
      city: data['city'] as String?,
      preferredLanguage: data['preferredLanguage'] as String? ?? 'fr',
      preferredBibleTranslation:
          data['preferredBibleTranslation'] as String? ?? 'LSG',
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (t) => t.name == data['subscriptionTier'],
        orElse: () => SubscriptionTier.free,
      ),
      stats: UserStats(
        currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
        totalPrayersCompleted:
            (data['totalPrayersCompleted'] as num?)?.toInt() ?? 0,
        totalBibleChaptersRead:
            (data['totalBibleChaptersRead'] as num?)?.toInt() ?? 0,
        totalAiConversations:
            (data['totalAiConversations'] as num?)?.toInt() ?? 0,
      ),
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: data['darkModeEnabled'] as bool? ?? false,
      bibleFontSize: (data['bibleFontSize'] as num?)?.toDouble() ?? 18.0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'] as String))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _profileToFirestore(UserProfile profile) {
    return {
      'uid': profile.uid,
      'email': profile.email,
      'displayName': profile.displayName,
      'photoUrl': profile.photoUrl,
      'parishName': profile.parishName,
      'dioceseName': profile.dioceseName,
      'country': profile.country,
      'city': profile.city,
      'preferredLanguage': profile.preferredLanguage,
      'preferredBibleTranslation': profile.preferredBibleTranslation,
      'subscriptionTier': profile.subscriptionTier.name,
      'currentStreak': profile.stats.currentStreak,
      'longestStreak': profile.stats.longestStreak,
      'totalPrayersCompleted': profile.stats.totalPrayersCompleted,
      'totalBibleChaptersRead': profile.stats.totalBibleChaptersRead,
      'totalAiConversations': profile.stats.totalAiConversations,
      'notificationsEnabled': profile.notificationsEnabled,
      'darkModeEnabled': profile.darkModeEnabled,
      'bibleFontSize': profile.bibleFontSize,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
