import 'package:isar_community/isar.dart';

part 'account.g.dart';

enum AccountType { user, business, admin }

@Collection()
class Account {
  Account({
    required this.uid,
    required this.email,
    this.phone,
    required this.displayName,
    this.businessName,
    this.accountType = AccountType.user,
    required this.city,
    required this.state,
    required this.country,
    this.verified = false,
    this.isBanned = false,
    this.banUntil,
    required this.createdAt,
    required this.updatedAt,
  });


  factory Account.newAccount({
    required String uid,
    required String email,
    String? phone,
    required String displayName,
    String? businessName,
    AccountType accountType = AccountType.user,
    required String city,
    required String state,
    required String country,
    bool verified = false,
    bool isBanned = false,
    DateTime? banUntil,
  }) {
    final now = DateTime.now();
    return Account(
      uid: uid,
      email: email,
      phone: phone,
      displayName: displayName,
      businessName: businessName,
      accountType: accountType,
      city: city,
      state: state,
      country: country,
      verified: verified,
      isBanned: isBanned,
      banUntil: banUntil,
      createdAt: now,
      updatedAt: now,
    );
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String uid;

  @Index()
  String email;

  String? phone;
  String displayName;

  String? businessName;

  @enumerated
  AccountType accountType;

  String city;
  String state;
  String country;

  bool verified;
  bool isBanned;
  DateTime? banUntil;

  DateTime createdAt;
  DateTime updatedAt;

  // Optional local JSON mapping (millis)
  static DateTime? _fromMillis(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static int _toMillis(DateTime dt) => dt.millisecondsSinceEpoch;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      displayName: (json['displayName'] ?? '') as String,
      businessName: json['businessName'] as String?,
      accountType: AccountType.values.firstWhere(
            (e) => e.name == (json['accountType'] ?? 'user'),
        orElse: () => AccountType.user,
      ),
      city: (json['city'] ?? '') as String,
      state: (json['state'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      verified: (json['verified'] ?? false) as bool,
      isBanned: (json['isBanned'] ?? false) as bool,
      banUntil: _fromMillis(json['banUntil']),
      createdAt: _fromMillis(json['createdAt']) ?? DateTime.now(),
      updatedAt: _fromMillis(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'displayName': displayName,
      'businessName': businessName,
      'accountType': accountType.name,
      'city': city,
      'state': state,
      'country': country,
      'verified': verified,
      'isBanned': isBanned,
      'banUntil': banUntil == null ? null : _toMillis(banUntil!),
      'createdAt': _toMillis(createdAt),
      'updatedAt': _toMillis(updatedAt),
    };
  }
}