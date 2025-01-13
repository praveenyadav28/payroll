import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:payroll/model/payment_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:excel/excel.dart';

Future<void> createExcelPayment(
  List<PaymentModel> dataList,
) async {
  var excel = Excel.createExcel();
  var sheet = excel.sheets[excel.getDefaultSheet()];

  // Add headers

  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
      TextCellValue('Customer Name');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
      TextCellValue('Customer Id');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
      TextCellValue('Voucher Number');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
      TextCellValue('Payment Date');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
      TextCellValue('Payable Amount');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
      TextCellValue('Settlement Amount');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
      TextCellValue('Mode');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value =
      TextCellValue('Monthly Salary');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value =
      TextCellValue('Paid Amount');
  sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0)).value =
      TextCellValue('Remark');

  // Add data rows
  int rowIndex = 1;
  for (var data in dataList) {
    sheet!
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(data.ledgerName ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = TextCellValue(data.ledgerId.toString());
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = TextCellValue(data.pvNo.toString());
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value =
        TextCellValue(
            data.paymentDate!.substring(0, data.paymentDate!.length - 12));

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        .value = TextCellValue(data.other2 ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        .value = TextCellValue(data.totalAmount ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
        .value = TextCellValue(data.mode ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
        .value = TextCellValue(data.other3 ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
        .value = TextCellValue(data.cashAmount ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
        .value = TextCellValue(data.other1 ?? "");
    rowIndex++;
  }

  var bytes = excel.encode();
  if (kIsWeb) {
    AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes!)}')
      ..setAttribute('download', 'Output.xlsx')
      ..click();
  } else if (Platform.isAndroid) {
    var i = DateTime.now();
    var directory = await getApplicationDocumentsDirectory();

    var file = File("${directory.path}/Output$i.xlsx");
    await file.writeAsBytes(bytes!);

    await OpenFile.open(file.path);
  } else {
    var directory = await getApplicationDocumentsDirectory();

    var file = File("${directory.path}/Output.xlsx");
    await file.writeAsBytes(bytes!);

    await OpenFile.open(file.path);
  }
}
