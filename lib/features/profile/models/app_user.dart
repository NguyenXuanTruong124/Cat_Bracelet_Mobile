class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatar;
  final String? vipLevelName;
  final String? vipBenefits;
  final String totalSpending;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatar,
    this.vipLevelName,
    this.vipBenefits,
    required this.totalSpending,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final vipLevel = json['vipLevel'];

    return AppUser(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? 'Khach hang').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      vipLevelName: vipLevel is Map<String, dynamic>
          ? (vipLevel['levelName'] ?? vipLevel['level_name'])?.toString()
          : null,
      vipBenefits: vipLevel is Map<String, dynamic>
          ? vipLevel['benefits']?.toString()
          : null,
      totalSpending: (json['totalSpending'] ?? json['total_spending'] ?? '0').toString(),
    );
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatar,
    String? vipLevelName,
    String? vipBenefits,
    String? totalSpending,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      vipLevelName: vipLevelName ?? this.vipLevelName,
      vipBenefits: vipBenefits ?? this.vipBenefits,
      totalSpending: totalSpending ?? this.totalSpending,
    );
  }
}
