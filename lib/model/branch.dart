class Branch {
  final int bid;
  final String bLocationName; // Company name
  final String? bCityName;
  final String? bStateName;
  final String? bDeviceSerialNo; // Biomax serial number
  final String? bDeviceName;

  Branch({
    required this.bid,
    required this.bLocationName,
    this.bCityName,
    this.bStateName,
    this.bDeviceSerialNo,
    this.bDeviceName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      bid: json['bid'] as int,
      bLocationName: json['bLocation_Name'] as String,
      bCityName: json['bCity_Name'] as String?,
      bStateName: json['bState_Name'] as String?,
      bDeviceSerialNo: json['bDeviceSerialNo'] as String?,
      bDeviceName: json['bDeviceName'] as String?,
    );
  }
}
