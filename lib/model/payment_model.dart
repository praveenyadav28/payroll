class PaymentModel {
  int? srNo;
  int? pvNo;
  int? ledgerId;
  String? ledgerName;
  String? paymentDate;
  String? totalAmount;
  String? cashAmount;
  String? balanceAmount;
  int? voucherModeId;
  String? mode;
  int? locationId;
  String? other1;
  String? other2;
  String? other3;
  List<String>? imageUrls; // Add this field to store image URLs

  PaymentModel({
    this.srNo,
    this.pvNo,
    this.ledgerId,
    this.ledgerName,
    this.paymentDate,
    this.totalAmount,
    this.cashAmount,
    this.balanceAmount,
    this.voucherModeId,
    this.mode,
    this.locationId,
    this.other1,
    this.other2,
    this.other3,
    this.imageUrls, // Add imageUrls to constructor
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      srNo: json["sr_No"],
      pvNo: json["pv_No"],
      ledgerId: json["ledger_Id"],
      ledgerName: json["ledger_Name"],
      paymentDate: json["payment_Date"],
      totalAmount: json["total_Amount"],
      cashAmount: json["cash_Amount"],
      balanceAmount: json["balance_Amount"],
      voucherModeId: json["voucher_Mode_Id"],
      mode: json["mode"],
      locationId: json["location_Id"],
      other1: json["other1"],
      other2: json["other2"],
      other3: json["other3"],
      imageUrls: json["imageUrls"] != null
          ? List<String>.from(json["imageUrls"])
          : [], // Handle imageUrls here
    );
  }
}

class ImageUrlsModel {
  List<String> imageUrls;

  ImageUrlsModel({required this.imageUrls});

  factory ImageUrlsModel.fromJson(Map<String, dynamic> json) {
    return ImageUrlsModel(
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}
