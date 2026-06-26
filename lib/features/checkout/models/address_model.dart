class AddressModel {
  final String id;
  final String receiverName;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String detailAddress;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.receiverName,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.detailAddress,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id:
          (json['id'] ?? json['_id'] ?? json['addressId'] ?? json['address_id'])
              ?.toString() ??
          '',
      receiverName: json['receiverName'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
