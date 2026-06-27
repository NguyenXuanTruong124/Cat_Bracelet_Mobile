class ShopLocation {
  final String id;
  final String shopName;
  final String shopAddress;
  final String province;
  final String district;
  final String ward;
  final String detailAddress;
  final String phoneNumber;
  final String workingHours;
  final double shopLatitude;
  final double shopLongitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopLocation({
    required this.id,
    required this.shopName,
    required this.shopAddress,
    required this.province,
    required this.district,
    required this.ward,
    required this.detailAddress,
    required this.phoneNumber,
    required this.workingHours,
    required this.shopLatitude,
    required this.shopLongitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopLocation.fromJson(Map<String, dynamic> json) {
    return ShopLocation(
      id: json['id'] ?? '',
      shopName: json['shopName'] ?? '',
      shopAddress: json['shopAddress'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      phoneNumber: json['phoneNumber'] ?? 'N/A',
      workingHours: json['workingHours'] ?? 'N/A',
      shopLatitude: (json['shopLatitude'] as num?)?.toDouble() ?? 0.0,
      shopLongitude: (json['shopLongitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
