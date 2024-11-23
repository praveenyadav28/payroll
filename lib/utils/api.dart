import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/transection/salaryModel.dart';

class ApiSalary {
  final String employeeApiUrl =
      'http://lms.muepetro.com/api/MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=${Preference.getString(PrefKeys.locationId)}';

  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse(employeeApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<List<DeviceLog>> fetchLogs(String fromDate, String toDate) async {
    final response = await http.get(Uri.parse(
        "http://103.178.113.149:82/api/v2/WebAPI/GetDeviceLogs?APIKey=555312092406&FromDate=$fromDate&ToDate=$toDate"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DeviceLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load device logs');
    }
  }
}
