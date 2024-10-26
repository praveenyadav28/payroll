class Employee {
  final String name;
  final String employeeCode;
  final double monthlySalary;
  final double workingHours;

  Employee({
    required this.name,
    required this.employeeCode,
    required this.monthlySalary,
    required this.workingHours,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['staff_Name'],
      employeeCode: json['biomaxId'],
      monthlySalary: double.parse(json['salary']),
      workingHours: double.parse(json['other1']),
    );
  }
}

class DeviceLog {
  final String employeeCode;
  final DateTime logDate;
  final DateTime punchTime;

  DeviceLog({
    required this.employeeCode,
    required this.logDate,
    required this.punchTime,
  });

  factory DeviceLog.fromJson(Map<String, dynamic> json) {
    return DeviceLog(
      employeeCode: json['EmployeeCode'],
      logDate: DateTime.parse("${json['LogDate']}"),
      punchTime: DateTime.parse("${json['LogDate']}"),
    );
  }
}
