class ShippingAddressModel {
  final String receiverName;
  final String phone;
  final String detailAddress;
  final String ward;
  final String district;
  final String province;

  const ShippingAddressModel({
    required this.receiverName,
    required this.phone,
    required this.detailAddress,
    required this.ward,
    required this.district,
    required this.province,
  });

  factory ShippingAddressModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ShippingAddressModel(
      receiverName: json['receiverName'] ?? '',
      phone: json['phone'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      province: json['province'] ?? '',
    );
  }

  String get fullAddress =>
      '$detailAddress, $ward, $district, $province';
}