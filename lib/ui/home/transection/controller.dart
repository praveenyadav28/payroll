import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/transection/salaryModel.dart';

////Sanwitch Rule Half Day///
// class WorkingHoursCalculator {
//   Map<String, dynamic> calculate(
//     List<Employee> employees,
//     List<DeviceLog> logs,
//     List<String> publicHolidays,
//     int daysInMonth,
//     int salaryYear,
//     int salaryMonth,
//   ) {
//     Map<String, dynamic> result = {};

//     // Convert public holidays to DateTime
//     List<DateTime> holidayDates =
//         publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

//       Set<String> punchDays = {};
//       Set<String> absentDays = {};

//       // Group logs by date
//       Map<String, List<DeviceLog>> groupedLogs = {};
//       for (var log in employeeLogs) {
//         String logDate = log.logDate.toIso8601String().split('T')[0];
//         groupedLogs.putIfAbsent(logDate, () => []).add(log);
//       }

//       for (int day = 1; day <= daysInMonth; day++) {
//         String currentDate = DateTime(salaryYear, salaryMonth, day)
//             .toIso8601String()
//             .split('T')[0];

//         if (holidayDates.any((holiday) =>
//             holiday.toIso8601String().split('T')[0] == currentDate)) {
//           continue;
//         }

//         List<DeviceLog> logsForDay = groupedLogs[currentDate] ?? [];

//         if (logsForDay.isEmpty) {
//           absentDays.add(currentDate);
//           actualAbsentDays++;
//         } else {
//           punchDays.add(currentDate);
//           if (logsForDay.length == 1) {
//             totalHours += employee.workingHours;
//             workingDays++;
//           } else {
//             DateTime firstPunch = logsForDay.first.punchTime;
//             DateTime lastPunch = logsForDay.last.punchTime;
//             Duration workedDuration = lastPunch.difference(firstPunch);
//             double hoursWorked =
//                 workedDuration.inHours + (workedDuration.inMinutes % 60) / 60.0;

//             totalHours += hoursWorked;
//             if (hoursWorked < 3) {
//               actualAbsentDays++;
//               absentDays.add(currentDate);
//             } else if (hoursWorked < 6) {
//               halfDaysCount++;
//             } else {
//               workingDays++;
//             }
//           }
//         }
//       }

//       // Apply Sandwich Rule
//       for (var holiday in holidayDates) {
//         String holidayDate = holiday.toIso8601String().split('T')[0];
//         DateTime dayBefore = holiday.subtract(const Duration(days: 1));
//         DateTime dayAfter = holiday.add(const Duration(days: 1));

//         if (absentDays.contains(dayBefore.toIso8601String().split('T')[0]) &&
//             absentDays.contains(dayAfter.toIso8601String().split('T')[0])) {
//           actualAbsentDays++;
//         }
//       }

//       double salaryDeduction =
//           (actualAbsentDays + (halfDaysCount / 2)) * dailySalary;
//       double dueSalary = employee.monthlySalary - salaryDeduction;

//       result[employee.employeeCode] = {
//         'name': employee.name,
//         'employeeCode': employee.employeeCode,
//         'employeeWorkingHours': employee.workingHours,
//         'workingHours': totalHours,
//         'workingDays': workingDays,
//         'absentDays': actualAbsentDays,
//         'halfDays': halfDaysCount,
//         'monthlySalary': employee.monthlySalary,
//         'dueSalary': dueSalary,
//         'dailyPunchLogInfo': groupedLogs
//       };
//     }

//     return result;
//   }
// }

//Working Hour Without Sandwich
class WorkingHoursCalculator {
  Map<String, dynamic> calculate(
      List<Employee> employees,
      List<DeviceLog> logs,
      List<String> publicHolidays,
      int daysInMonth,
      int salaryYear,
      int salaryMonth,
      int absentDaysCalculate,
      DateTime? excludeStartDate,
      DateTime? excludeEndDate) {
    Map<String, dynamic> result = {};

    // Convert public holidays to DateTime
    List<DateTime> holidayDates =
        publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

    for (var employee in employees) {
      List<DeviceLog> unignoredLogs = logs
          .where((log) =>
              excludeStartDate != null &&
              excludeEndDate != null &&
              (log.punchTime.isBefore(excludeStartDate) ||
                  log.punchTime.isAfter(excludeEndDate)))
          .toList();

      List<DeviceLog> employeeLogs = unignoredLogs
          .where((log) =>
              log.employeeCode == employee.employeeCode &&
              log.serialNumber == Preference.getString(PrefKeys.coludId))
          .toList();
      employeeLogs.sort((a, b) => a.logDate.compareTo(b.logDate));

      // Initialize variables
      int workingDays = 0;
      double totalHoursWorked = 0.0;
      double expectedDailyHours = employee.workingHours;
      double dailySalary =
          employee.monthlySalary / (daysInMonth * expectedDailyHours);

      Set<String> punchDays = {};

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

        // Skip public holidays
        if (holidayDates.any((holiday) =>
            holiday.toIso8601String().split('T')[0] == currentDate)) {
          continue;
        }

        // Get all logs for the current date (including punch direction ' ')
        List<DeviceLog> logsForDay = groupedLogs[currentDate] ?? [];

        // Filter logs with a time gap of more than 10 minutes between consecutive punches
        List<DeviceLog> filteredLogsForDay = [];
        if (logsForDay.isNotEmpty) {
          filteredLogsForDay.add(logsForDay.first); // Keep the first log
          for (int i = 1; i < logsForDay.length; i++) {
            Duration diff =
                logsForDay[i].punchTime.difference(logsForDay[i - 1].punchTime);
            if (diff.inMinutes > 10) {
              filteredLogsForDay.add(logsForDay[i]); // Add log if gap > 10 min
            }
          }
        }

        // Filter logs for working hours calculation (exclude direction ' ')
        List<DeviceLog> validLogsForDay = filteredLogsForDay
            .where((log) =>
                log.punchDirection == 'in' || log.punchDirection == 'out')
            .toList();

        punchDays.add(currentDate);

        if (validLogsForDay.isNotEmpty) {
          if (validLogsForDay.length == 1) {
            // Single log counts as 0 working hours
            totalHoursWorked += 0;
            workingDays++;
          } else {
            double hoursWorked = 0.0;

            // Only consider logs with even pairs
            if (validLogsForDay.length % 2 == 0) {
              for (int i = 0; i < validLogsForDay.length; i += 2) {
                Duration pairDuration = validLogsForDay[i + 1]
                    .punchTime
                    .difference(validLogsForDay[i].punchTime);
                hoursWorked +=
                    pairDuration.inHours + (pairDuration.inMinutes % 60) / 60.0;
              }

              // Cap hoursWorked to the employee's daily working hours
              hoursWorked = hoursWorked > expectedDailyHours
                  ? expectedDailyHours
                  : hoursWorked;
            } else {
              hoursWorked =
                  0.0; // Odd number of logs results in 0 working hours
            }

            // Add the calculated hours to total hours worked and increment working days
            totalHoursWorked += hoursWorked;
            workingDays++;
          }
        }
      }

      // Public holiday salary deduction policy
      double holidayHours = holidayDates.length * expectedDailyHours;
      bool eligibleForHolidaySalary = workingDays > 6;
      double holidaySalary =
          eligibleForHolidaySalary ? holidayHours * dailySalary : 0.0;

      // Calculate total salary
      double totalSalary = (totalHoursWorked * dailySalary) + holidaySalary;

      result[employee.employeeCode] = {
        'id': employee.id,
        'name': employee.name,
        'employeeCode': employee.employeeCode,
        'employeeWorkingHours': employee.workingHours,
        'workingHours': totalHoursWorked,
        'workingDays': workingDays,
        'absentDays': absentDaysCalculate - workingDays - holidayDates.length,
        'monthlySalary': employee.monthlySalary,
        'dueSalary': totalSalary,
        'dailyPunchLogInfo': groupedLogs,
        'dailySalary': dailySalary
      };
    }

    return result;
  }
}

//Working hours of shifts
class WorkingShiftCalculator {
  Map<String, dynamic> calculate(
    List<Employee> employees,
    List<DeviceLog> logs,
    List<String> publicHolidays,
    int daysInMonth,
    int salaryYear,
    int salaryMonth,
    int absentDaysCalculate,
  ) {
    Map<String, dynamic> result = {};

    // Convert public holidays to DateTime
    List<DateTime> holidayDates =
        publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

    for (var employee in employees) {
      // Filter logs specific to the current employee and cloud ID
      List<DeviceLog> employeeLogs = logs
          .where((log) =>
              log.employeeCode == employee.employeeCode &&
              log.serialNumber == Preference.getString(PrefKeys.coludId).trim())
          .toList();

      double standardShiftHours =
          employee.workingHours; // Standard working hours per shift
      double dailySalary =
          employee.monthlySalary / daysInMonth; // Approximate daily salary
      double hourlyRate = dailySalary / standardShiftHours; // Hourly rate

      employeeLogs.sort((a, b) => a.logDate.compareTo(b.logDate));
      List<Map<String, dynamic>> shifts = createShifts(employeeLogs);
      double calculatedMonthlySalary = 0;
      for (var shift in shifts) {
        double hoursWorked = shift['workinghours'];
        String differenceText = "";
        double calculatedSalary = 0;

        if (hoursWorked < standardShiftHours - 0.5) {
          double missingHours = standardShiftHours - hoursWorked;
          calculatedSalary = hoursWorked * hourlyRate;
          differenceText =
              "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
        } else if (hoursWorked > standardShiftHours - 0.5 &&
            hoursWorked < standardShiftHours) {
          double missingHours = standardShiftHours - hoursWorked;
          calculatedSalary = dailySalary;
          differenceText =
              "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
        } else if (hoursWorked >= standardShiftHours &&
            hoursWorked < 2 * standardShiftHours - 0.5) {
          calculatedSalary = dailySalary;
          differenceText =
              "Over Time: ${(hoursWorked - standardShiftHours).floor()}h ${((hoursWorked - standardShiftHours).remainder(1) * 60).round()}m";
        } else {
          calculatedSalary = dailySalary * 2;
          differenceText =
              "Double Shift: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
        }

        calculatedMonthlySalary += calculatedSalary;
        shift['Salary'] = "₹ ${calculatedSalary.toStringAsFixed(2)}";
        shift['differenceText'] = differenceText;
      }

      // Public Holiday Calculation
      int holidayDeductions = 0;
      double holidaySalary = 0;

      if (shifts.length > 6) {
        holidaySalary = holidayDates.length * dailySalary;
        calculatedMonthlySalary += holidaySalary;
      } else {
        holidayDeductions = holidayDates.length;
      }

      // Prepare the result for the current employee
      result[employee.employeeCode] = {
        'id': employee.id,
        'name': employee.name,
        'employeeCode': employee.employeeCode,
        'employeeWorkingHours': employee.workingHours,
        'workingDays': shifts.length,
        'absentDays': absentDaysCalculate - shifts.length - holidayDates.length,
        'monthlySalary': employee.monthlySalary,
        'dueSalary': calculatedMonthlySalary,
        'holidayDeductions': holidayDeductions,
        'holidaySalary': holidaySalary,
        'dailyPunchLogInfo': shifts,
      };
    }

    return result;
  }

  List<Map<String, dynamic>> createShifts(List<DeviceLog> logs) {
    logs.sort((a, b) => a.logDate.compareTo(b.logDate)); // Sort logs by date

    List<Map<String, dynamic>> shifts = [];
    List<DeviceLog> currentShiftLogs = [];
    List<DeviceLog> duplicateLogs = [];
    DateTime? shiftStartTime;
    DateTime shiftEndTime = DateTime(2000); // Placeholder

    for (int i = 0; i < logs.length; i++) {
      var log = logs[i];

      // Check if the current log is a duplicate (difference < 10 minutes)
      if (currentShiftLogs.isNotEmpty) {
        var lastLog = currentShiftLogs.last;
        Duration diff = log.logDate.difference(lastLog.logDate);
        if (diff.inMinutes < 10) {
          duplicateLogs.add(log); // Add to "Duplicate" key
          continue; // Skip adding to current shift
        }
      }

      // Define new shift logic
      if (log.punchDirection.toLowerCase() == "in" && log.logDate.hour >= 7) {
        if (currentShiftLogs.isNotEmpty && log.logDate.isAfter(shiftEndTime)) {
          // Save current shift
          shifts.add({
            "ShiftStart": shiftStartTime,
            "PunchTime": currentShiftLogs,
            "Duplicate": duplicateLogs,
            "workinghours": calculateWorkingHours(currentShiftLogs)
          });
          currentShiftLogs = []; // Reset for new shift
          duplicateLogs = []; // Reset duplicate logs
        }
        shiftStartTime = log.logDate;
        shiftEndTime = DateTime(
            log.logDate.year, log.logDate.month, log.logDate.day + 1, 7, 0, 0);
      }

      // Add log to current shift
      currentShiftLogs.add(log);
    }

    // Add the last shift if any logs remain
    if (currentShiftLogs.isNotEmpty) {
      shifts.add({
        "ShiftStart": shiftStartTime,
        "PunchTime": currentShiftLogs,
        "Duplicate": duplicateLogs,
        "workinghours": calculateWorkingHours(currentShiftLogs)
      });
    }

    return shifts;
  }

  /// Function to calculate working hours of a shift
  double calculateWorkingHours(List<DeviceLog> logs) {
    double totalHours = 0.0;
    List<DeviceLog> filteredLogs = logs
        .where((log) =>
            log.punchDirection.toLowerCase() == "in" ||
            log.punchDirection.toLowerCase() == "out")
        .toList();

    for (int i = 0; i < filteredLogs.length - 1; i++) {
      var current = filteredLogs[i];
      var next = filteredLogs[i + 1];

      // Check for valid in-out pair
      if (current.punchDirection.toLowerCase() == "in" &&
          next.punchDirection.toLowerCase() == "out") {
        totalHours += next.logDate.difference(current.logDate).inMinutes / 60.0;
      }
      // If sequence is irregular, return 0
      else if (current.punchDirection.toLowerCase() ==
          next.punchDirection.toLowerCase()) {
        return 0.0;
      }
    }
    return totalHours;
  }
}
