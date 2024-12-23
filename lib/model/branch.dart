class Branch {
  final int bid;
  final String bLocationName; // Company name
  final String? bCityName;
  final String? bStateName;
  final String? bDeviceSerialNo; // Biomax serial number
  final String? bDeviceName;
  final String? bEmailId;
  final String? other1; //Admin Password
  final String? other2; //User Type
  final String? other3; //Staff Password

  Branch({
    required this.bid,
    required this.bLocationName,
    this.bCityName,
    this.bStateName,
    this.bDeviceSerialNo,
    this.bDeviceName,
    this.bEmailId,
    this.other1,
    this.other2,
    this.other3,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      bid: json['bid'] as int,
      bLocationName: json['bLocation_Name'] as String,
      bCityName: json['bCity_Name'] as String?,
      bStateName: json['bState_Name'] as String?,
      bDeviceSerialNo: json['bDeviceSerialNo'] as String?,
      bDeviceName: json['bDeviceName'] as String?,
      bEmailId: json['bEmailId'] as String?,
      other1: json['other1'] as String?,
      other2: json['other2'] as String?,
      other3: json['other3'] as String?,
    );
  }
}
