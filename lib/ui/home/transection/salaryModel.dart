class Employee {
  final int id;
  final String name;
  final String employeeCode;
  final double monthlySalary;
  final double workingHours;

  Employee({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.monthlySalary,
    required this.workingHours,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['staff_Name'],
      employeeCode: json['biomaxId'],
      monthlySalary: double.parse(json['salary']),
      workingHours: double.parse(json['other1']),
    );
  }
}

class DeviceLog {
  final String employeeCode;
  final String punchDirection;
  final String serialNumber;
  final DateTime logDate;
  final DateTime punchTime;

  DeviceLog({
    required this.employeeCode,
    required this.punchDirection,
    required this.serialNumber,
    required this.logDate,
    required this.punchTime,
  });

  factory DeviceLog.fromJson(Map<String, dynamic> json) {
    return DeviceLog(
      employeeCode: json['EmployeeCode'],
      punchDirection: json['PunchDirection'],
      serialNumber: json['SerialNumber'],
      logDate: DateTime.parse("${json['LogDate']}"),
      punchTime: DateTime.parse("${json['LogDate']}"),
    );
  }
}
