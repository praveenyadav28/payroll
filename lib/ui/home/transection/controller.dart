import 'package:payroll/ui/home/transection/salaryModel.dart';

class WorkingHoursCalculator {
  Map<String, dynamic> calculate(
    List<Employee> employees,
    List<DeviceLog> logs,
    List<String> publicHolidays,
    int daysInMonth,
    int salaryYear,
    int salaryMonth,
  ) {
    Map<String, dynamic> result = {};

    // Convert public holidays to DateTime
    List<DateTime> holidayDates =
        publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

    for (var employee in employees) {
      List<DeviceLog> employeeLogs = logs
          .where((log) => log.employeeCode == employee.employeeCode)
          .toList();

      // Initialize variables
      int actualAbsentDays = 0;
      int workingDays = 0;
      int halfDaysCount = 0;
      double totalHours = 0;
      double dailySalary = employee.monthlySalary / daysInMonth;

      Set<String> punchDays = {};
      Set<String> absentDays = {};

      // Group logs by date
      Map<String, List<DeviceLog>> groupedLogs = {};
      for (var log in employeeLogs) {
        String logDate = log.logDate.toIso8601String().split('T')[0];
        groupedLogs.putIfAbsent(logDate, () => []).add(log);
      }

      for (int day = 1; day <= daysInMonth; day++) {
        String currentDate = DateTime(salaryYear, salaryMonth, day)
            .toIso8601String()
            .split('T')[0];

        if (holidayDates.any((holiday) =>
            holiday.toIso8601String().split('T')[0] == currentDate)) {
          continue;
        }

        List<DeviceLog> logsForDay = groupedLogs[currentDate] ?? [];

        if (logsForDay.isEmpty) {
          absentDays.add(currentDate);
          actualAbsentDays++;
        } else {
          punchDays.add(currentDate);
          if (logsForDay.length == 1) {
            totalHours += 8;
            workingDays++;
          } else {
            DateTime firstPunch = logsForDay.first.punchTime;
            DateTime lastPunch = logsForDay.last.punchTime;
            Duration workedDuration = lastPunch.difference(firstPunch);
            double hoursWorked =
                workedDuration.inHours + (workedDuration.inMinutes % 60) / 60.0;

            totalHours += hoursWorked;
            if (hoursWorked < 3) {
              actualAbsentDays++;
              absentDays.add(currentDate);
            } else if (hoursWorked < 6) {
              halfDaysCount++;
            } else {
              workingDays++;
            }
          }
        }
      }

      // Apply Sandwich Rule
      for (var holiday in holidayDates) {
        String holidayDate = holiday.toIso8601String().split('T')[0];
        DateTime dayBefore = holiday.subtract(const Duration(days: 1));
        DateTime dayAfter = holiday.add(const Duration(days: 1));

        if (absentDays.contains(dayBefore.toIso8601String().split('T')[0]) &&
            absentDays.contains(dayAfter.toIso8601String().split('T')[0])) {
          actualAbsentDays++;
        }
      }

      double salaryDeduction =
          (actualAbsentDays + (halfDaysCount / 2)) * dailySalary;
      double dueSalary = employee.monthlySalary - salaryDeduction;

      result[employee.employeeCode] = {
        'name': employee.name,
        'employeeCode': employee.employeeCode,
        'workingHours': totalHours,
        'workingDays': workingDays,
        'absentDays': actualAbsentDays,
        'halfDays': halfDaysCount,
        'monthlySalary': employee.monthlySalary,
        'dueSalary': dueSalary,
        'dailyPunchLogInfo': groupedLogs
      };
    }

    return result;
  }
}
