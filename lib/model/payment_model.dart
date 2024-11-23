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
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
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
      );
}
