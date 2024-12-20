class Staff {
  final int id;
  final String name;
  final String mobile;
  final String biomaxId;
  final int designationId;
  final String monthlySalary;
  final String workingHours;

  Staff({
    required this.id,
    required this.name,
    required this.mobile,
    required this.biomaxId,
    required this.designationId,
    required this.monthlySalary,
    required this.workingHours,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['staff_Name'],
      mobile: json['mob'],
      biomaxId: json['biomaxId'],
      designationId: json['staff_Degination_Id'],
      monthlySalary: json['salary'],
      workingHours: json['other1'],
    );
  }
}
