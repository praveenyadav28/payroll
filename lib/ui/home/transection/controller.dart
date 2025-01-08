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

//     for (var employee in employees) {
//       List<DeviceLog> employeeLogs = logs
//           .where((log) => log.employeeCode == employee.employeeCode
//           && log.serialNumber == 'C2612068A3121321')
//           .toList();

//       // Initialize variables
//       int actualAbsentDays = 0;
//       int workingDays = 0;
//       int halfDaysCount = 0;
//       double totalHours = 0;
//       double dailySalary = employee.monthlySalary / daysInMonth;

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
  ) {
    Map<String, dynamic> result = {};

    // Convert public holidays to DateTime
    List<DateTime> holidayDates =
        publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

    for (var employee in employees) {
      List<DeviceLog> employeeLogs = logs
          .where((log) =>
              log.employeeCode == employee.employeeCode &&
              log.serialNumber == Preference.getString(PrefKeys.coludId))
          .toList();

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

        List<DeviceLog> logsForDay = groupedLogs[currentDate] ?? [];
        if (logsForDay.isNotEmpty) {
          punchDays.add(currentDate);
          if (logsForDay.length == 1) {
            // Single log counts as 0 working hours
            totalHoursWorked += 0;
            workingDays++;
          } else {
            double hoursWorked = 0.0;
            if (logsForDay.length % 2 == 0) {
              for (int i = 0; i < logsForDay.length; i += 2) {
                Duration pairDuration = logsForDay[i + 1]
                    .punchTime
                    .difference(logsForDay[i].punchTime);
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
      };
    }

    return result;
  }
}

// //Double Shift Policy
// class WorkingShiftCalculator {
//   Map<String, dynamic> calculate(
//     List<Employee> employees,
//     List<DeviceLog> logs,
//     List<String> publicHolidays,
//     int daysInMonth,
//     int salaryYear,
//     int salaryMonth,
//     int absentDaysCalculate,
//   ) {
//     Map<String, dynamic> result = {};

//     // Convert public holidays to DateTime
//     List<DateTime> holidayDates =
//         publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

//     for (var employee in employees) {
//       List<DeviceLog> employeeLogs = logs
//           .where((log) =>
//               log.employeeCode == employee.employeeCode &&
//               log.serialNumber == Preference.getString(PrefKeys.coludId).trim())
//           .toList();

//       double standardShiftHours =
//           employee.workingHours; // Standard working hours per shift
//       double dailySalary =
//           employee.monthlySalary / daysInMonth; // Approximate daily salary
//       double hourlyRate = dailySalary / standardShiftHours; // Hourly rate

//       List<Map<String, String>> shifts = [];
//       double calculatedMonthlySalary = 0;
//       double hoursWorked = 0;

//       int totalShifts = 0; // To track the number of full shifts

//       // // Handle first log as punch out
//       // if (employeeLogs.isNotEmpty &&
//       //     employeeLogs.first.punchDirection == "out") {
//       //   DateTime punchOutTime = employeeLogs.first.punchTime;
//       //   DateTime midnight = DateTime(
//       //     punchOutTime.year,
//       //     punchOutTime.month,
//       //     punchOutTime.day,
//       //     0,
//       //     0,
//       //   );

//       //   hoursWorked =
//       //       punchOutTime.difference(midnight).inMinutes / 60.0; // Hours worked

//       //   double calculatedSalary;
//       //   String differenceText;
//       //   int shiftsCount;

//       //   if (hoursWorked < standardShiftHours) {
//       //     // Half-day logic
//       //     double missingHours = standardShiftHours - hoursWorked;
//       //     calculatedSalary = (hoursWorked * hourlyRate);
//       //     differenceText =
//       //         "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//       //     shiftsCount = 1;
//       //   } else if (hoursWorked >= standardShiftHours &&
//       //       hoursWorked < 2 * standardShiftHours) {
//       //     calculatedSalary = dailySalary; // Full day pay
//       //     differenceText =
//       //         "Worked: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//       //     shiftsCount = 1;
//       //   } else if (hoursWorked >= 2 * standardShiftHours) {
//       //     calculatedSalary = dailySalary * 2; // Full day pay
//       //     differenceText =
//       //         "Double Shift: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//       //     shiftsCount = 2;
//       //   } else {
//       //     // Overtime logic
//       //     shiftsCount = (hoursWorked / 8).floor();
//       //     calculatedSalary = shiftsCount * dailySalary;
//       //     differenceText =
//       //         "Over Time: ${(hoursWorked - 8.0).floor()}h ${((hoursWorked - 8.0).remainder(1) * 60).round()}m";
//       //   }

//       //   calculatedMonthlySalary += calculatedSalary;
//       //   totalShifts += shiftsCount;

//       //   shifts.add({
//       //     "Punch In": "$salaryYear-$salaryMonth-01 00:00:00.000",
//       //     "Punch Out": punchOutTime.toString(),
//       //     "Worked":
//       //         "${hoursWorked.floor()} hours ${(hoursWorked.remainder(1) * 60).round()} minutes",
//       //     "Difference": differenceText,
//       //     "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
//       //   });

//       //   // Remove the first log as it has been processed
//       //   employeeLogs.removeAt(0);
//       // }

//       // Process all other logs in pairs
//       for (int i = 0; i < employeeLogs.length - 1; i++) {
//         if (employeeLogs[i].punchDirection == "in") {
//           DateTime punchInTime = employeeLogs[i].punchTime;
//           DateTime? punchOutTime;

//           if (i + 1 < employeeLogs.length &&
//               employeeLogs[i + 1].punchDirection == "out") {
//             punchOutTime = employeeLogs[i + 1].punchTime;
//             hoursWorked =
//                 punchOutTime.difference(punchInTime).inMinutes / 60.0; // Hours
//           } else {
//             punchOutTime = null;
//             hoursWorked = 0; // Assume 0 hour worked
//           }

//           double calculatedSalary;
//           String differenceText;
//           int shiftsCount;

//           if (hoursWorked < standardShiftHours) {
//             // Half-day logic
//             double missingHours = standardShiftHours - hoursWorked;
//             calculatedSalary = (hoursWorked * hourlyRate);
//             differenceText =
//                 "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//             shiftsCount = 1;
//           } else if (hoursWorked >= standardShiftHours &&
//               hoursWorked < 2 * standardShiftHours) {
//             calculatedSalary = dailySalary; // Full day pay
//             differenceText =
//                 "Worked: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//             shiftsCount = 1;
//           } else if (hoursWorked >= 2 * standardShiftHours) {
//             calculatedSalary = dailySalary * 2; // Full day pay
//             differenceText =
//                 "Double Shift: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//             shiftsCount = 2;
//           } else {
//             // Overtime logic
//             shiftsCount = (hoursWorked / 8).floor();
//             calculatedSalary = shiftsCount * dailySalary;
//             differenceText =
//                 "Over Time: ${(hoursWorked - 8.0).floor()}h ${((hoursWorked - 8.0).remainder(1) * 60).round()}m";
//           }
//           calculatedMonthlySalary += calculatedSalary;
//           totalShifts += shiftsCount;

//           shifts.add({
//             "Punch In": punchInTime.toString(),
//             "Punch Out": punchOutTime?.toString() ?? "N/A(Assumed Full Shift)",
//             "Worked":
//                 "${hoursWorked.floor()} hours ${(hoursWorked.remainder(1) * 60).round()} minutes",
//             "Difference": differenceText,
//             "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
//           });
//         }
//       }
//       //   // Handle last log as punch in
//       //   if (employeeLogs.isNotEmpty && employeeLogs.last.punchDirection == "in") {
//       //     DateTime punchInTime = employeeLogs.last.punchTime;
//       //     DateTime midnight = DateTime(
//       //         punchInTime.year, punchInTime.month, punchInTime.day, 24, 00);

//       //     hoursWorked =
//       //         midnight.difference(punchInTime).inMinutes / 60.0; // Hours worked

//       //     double calculatedSalary;
//       //     String differenceText;
//       //     int shiftsCount;

//       //     if (hoursWorked < standardShiftHours) {
//       //       double missingHours = standardShiftHours - hoursWorked;
//       //       calculatedSalary = (hoursWorked * hourlyRate);
//       //       differenceText =
//       //           "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//       //       shiftsCount = 1;
//       //     } else if (hoursWorked > 2 * standardShiftHours) {
//       //       calculatedSalary = dailySalary; // Full day pay
//       //       differenceText =
//       //           "Double Shift: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//       //       shiftsCount = 1;
//       //     } else if (hoursWorked >= 2 * standardShiftHours) {
//       //       calculatedSalary = dailySalary * 2; // Full day pay
//       //       differenceText =
//       //           "Worked: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//       //       shiftsCount = 2;
//       //     } else {
//       //       // Overtime logic
//       //       shiftsCount = (hoursWorked / 8).floor();
//       //       calculatedSalary = shiftsCount * dailySalary;
//       //       differenceText =
//       //           "Over Time: ${(hoursWorked - 8.0).floor()}h ${((hoursWorked - 8.0).remainder(1) * 60).round()}m";
//       //     }

//       //     calculatedMonthlySalary += calculatedSalary;
//       //     totalShifts += shiftsCount;

//       //     shifts.add({
//       //       "Punch In": punchInTime.toString(),
//       //       "Punch Out": "$salaryYear-$salaryMonth-$daysInMonth 24:00:00.000",
//       //       "Worked":
//       //           "${hoursWorked.floor()} hours ${(hoursWorked.remainder(1) * 60).round()} minutes",
//       //       "Difference": differenceText,
//       //       "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
//       //     });

//       //     // Remove the first log as it has been processed
//       //     employeeLogs.removeAt(0);
//       //   }

//       // Public Holiday Calculation
//       int holidayDeductions = 0;
//       double holidaySalary = 0;

//       if (totalShifts > 6) {
//         // Full salary for all public holidays
//         holidaySalary = holidayDates.length * dailySalary;
//         calculatedMonthlySalary += holidaySalary;
//       } else {
//         // Deduct salary for public holidays
//         holidayDeductions = holidayDates.length;
//       }

//       result[employee.employeeCode] = {
//         'name': employee.name,
//         'employeeCode': employee.employeeCode,
//         'employeeWorkingHours': employee.workingHours,
//         'workingHours': hoursWorked,
//         'workingDays': totalShifts,
//         'absentDays': absentDaysCalculate - totalShifts - holidayDates.length,
//         'monthlySalary': employee.monthlySalary,
//         'dueSalary': calculatedMonthlySalary,
//         'holidayDeductions': holidayDeductions,
//         'holidaySalary': holidaySalary,
//         'dailyPunchLogInfo': shifts,
//       };
//     }

//     return result;
//   }
// }

// class WorkingShiftCalculator {
//   Map<String, dynamic> calculate(
//     List<Employee> employees,
//     List<DeviceLog> logs,
//     List<String> publicHolidays,
//     int daysInMonth,
//     int salaryYear,
//     int salaryMonth,
//     int absentDaysCalculate,
//   ) {
//     Map<String, dynamic> result = {};

//     // Convert public holidays to DateTime
//     List<DateTime> holidayDates =
//         publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

//     for (var employee in employees) {
//       List<DeviceLog> employeeLogs = logs
//           .where((log) =>
//               log.employeeCode == employee.employeeCode &&
//               log.serialNumber == Preference.getString(PrefKeys.coludId).trim())
//           .toList();

//       double standardShiftHours =
//           employee.workingHours; // Standard working hours per shift
//       double dailySalary =
//           employee.monthlySalary / daysInMonth; // Approximate daily salary
//       double hourlyRate = dailySalary / standardShiftHours; // Hourly rate

//       List<Map<String, String>> shifts = [];
//       List<String> punchTimes = []; // List for Punch Time entries
//       double calculatedMonthlySalary = 0;
//       int totalShifts = 0;

//       DateTime? lastPunchInTime;

//       for (int i = 0; i < employeeLogs.length; i++) {
//         var log = employeeLogs[i];
//         if (log.punchDirection == "in") {
//           DateTime punchInTime = log.punchTime;

//           if (lastPunchInTime != null &&
//               punchInTime.difference(lastPunchInTime).inHours < 10) {
//             // If the time difference is less than 10 hours, add to Punch Time
//             punchTimes.add(punchInTime.toString());
//             continue; // Skip further processing for this punch
//           }

//           lastPunchInTime = punchInTime; // Update lastPunchInTime

//           // Check for punch out
//           DateTime? punchOutTime;
//           if (i + 1 < employeeLogs.length &&
//               employeeLogs[i + 1].punchDirection == "out") {
//             punchOutTime = employeeLogs[i + 1].punchTime;
//             double hoursWorked =
//                 punchOutTime.difference(punchInTime).inMinutes / 60.0;

//             // Calculate salary and difference
//             double calculatedSalary;
//             String differenceText;

//             if (hoursWorked < standardShiftHours) {
//               double missingHours = standardShiftHours - hoursWorked;
//               calculatedSalary = hoursWorked * hourlyRate;
//               differenceText =
//                   "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//             } else if (hoursWorked >= standardShiftHours &&
//                 hoursWorked < 2 * standardShiftHours) {
//               calculatedSalary = dailySalary;
//               differenceText =
//                   "Over Time: ${(hoursWorked - standardShiftHours).floor()}h ${((hoursWorked - standardShiftHours).remainder(1) * 60).round()}m";
//             } else {
//               calculatedSalary = dailySalary * 2;
//               differenceText =
//                   "Double Shift: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//             }

//             shifts.add({
//               "Punch In": punchInTime.toString(),
//               "Punch Out": punchOutTime.toString(),
//               "Worked":
//                   "${hoursWorked.floor()} hours ${(hoursWorked.remainder(1) * 60).round()} minutes",
//               "Difference": differenceText,
//               "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
//             });

//             calculatedMonthlySalary += calculatedSalary;
//             totalShifts += 1;
//             i++; // Skip the next log as it was used for punch out
//           } else {
//             // If there's no punch out, record only punch in time in Punch Time
//             punchTimes.add(punchInTime.toString());
//           }
//         }
//       }

//       // Public Holiday Calculation
//       int holidayDeductions = 0;
//       double holidaySalary = 0;

//       if (totalShifts > 6) {
//         holidaySalary = holidayDates.length * dailySalary;
//         calculatedMonthlySalary += holidaySalary;
//       } else {
//         holidayDeductions = holidayDates.length;
//       }

//       result[employee.employeeCode] = {
//         'name': employee.name,
//         'employeeCode': employee.employeeCode,
//         'employeeWorkingHours': employee.workingHours,
//         'workingDays': totalShifts,
//         'absentDays': absentDaysCalculate - totalShifts - holidayDates.length,
//         'monthlySalary': employee.monthlySalary,
//         'dueSalary': calculatedMonthlySalary,
//         'holidayDeductions': holidayDeductions,
//         'holidaySalary': holidaySalary,
//         'dailyPunchLogInfo': shifts,
//         'Punch Time': punchTimes, // Add Punch Time list
//       };
//     }

//     return result;
//   }
// }

// class WorkingShiftCalculator {
//   Map<String, dynamic> calculate(
//     List<Employee> employees,
//     List<DeviceLog> logs,
//     List<String> publicHolidays,
//     int daysInMonth,
//     int salaryYear,
//     int salaryMonth,
//     int absentDaysCalculate,
//   ) {
//     Map<String, dynamic> result = {};

//     // Convert public holidays to DateTime
//     List<DateTime> holidayDates =
//         publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

//     for (var employee in employees) {
//       List<DeviceLog> employeeLogs = logs
//           .where((log) =>
//               log.employeeCode == employee.employeeCode &&
//               log.serialNumber == Preference.getString(PrefKeys.coludId).trim())
//           .toList();

//       double standardShiftHours =
//           employee.workingHours; // Standard working hours per shift
//       double dailySalary =
//           employee.monthlySalary / daysInMonth; // Approximate daily salary
//       double hourlyRate = dailySalary / standardShiftHours; // Hourly rate

//       List<Map<String, dynamic>> shifts = [];
//       double calculatedMonthlySalary = 0;
//       int totalShifts = 0;

//       DateTime? lastPunchInTime;
//       List<String> punchTimeList =
//           []; // List to collect punch times for the shift

//       for (int i = 0; i < employeeLogs.length; i++) {
//         var log = employeeLogs[i];
//         if (log.punchDirection == 'in' || log.punchDirection == ' ') {
//           DateTime punchInTime = log.punchTime;

//           // Check for consecutive punch-ins without punch-out
//           if (lastPunchInTime != null &&
//               punchInTime.difference(lastPunchInTime).inHours < 12) {
//             punchTimeList.add(punchInTime.toString());
//             continue; // Skip further processing for this punch
//           }

//           // Create a new shift if the time difference exceeds 12 hours
//           lastPunchInTime = punchInTime; // Update lastPunchInTime
//           punchTimeList = [
//             punchInTime.toString()
//           ]; // Start a new punch time list

//           // Check for punch out
//           DateTime? punchOutTime;
//           if (i + 1 < employeeLogs.length &&
//               employeeLogs[i + 1].punchDirection == "out") {
//             punchOutTime = employeeLogs[i + 1].punchTime;
//             double hoursWorked =
//                 punchOutTime.difference(punchInTime).inMinutes / 60.0;

//             // Calculate salary and difference
//             double calculatedSalary;
//             String differenceText;

//             if (hoursWorked < standardShiftHours - 0.5) {
//               double missingHours = standardShiftHours - hoursWorked;
//               calculatedSalary = hoursWorked * hourlyRate;
//               differenceText =
//                   "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//             } else if (hoursWorked > standardShiftHours - 0.5 &&
//                 hoursWorked < standardShiftHours) {
//               double missingHours = standardShiftHours - hoursWorked;
//               calculatedSalary = dailySalary;
//               differenceText =
//                   "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//             } else if (hoursWorked >= standardShiftHours &&
//                 hoursWorked < 2 * standardShiftHours - 0.5) {
//               calculatedSalary = dailySalary;
//               differenceText =
//                   "Over Time: ${(hoursWorked - standardShiftHours).floor()}h ${((hoursWorked - standardShiftHours).remainder(1) * 60).round()}m";
//             } else {
//               calculatedSalary = dailySalary * 2;
//               differenceText =
//                   "Double Shift: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//             }
//             punchTimeList.removeAt(0);
//             shifts.add({
//               "Punch In": punchInTime.toString(),
//               "Punch Out": punchOutTime.toString(),
//               "Punch Time": punchTimeList,
//               "Worked":
//                   "${hoursWorked.floor()} hours ${(hoursWorked.remainder(1) * 60).round()} minutes",
//               "Difference": differenceText,
//               "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
//             });

//             calculatedMonthlySalary += calculatedSalary;
//             totalShifts += 1;
//             i++; // Skip the next log as it was used for punch out
//           } else {
//             punchTimeList.removeAt(0);
//             // If there's no punch out, record only punch in time with 0 hours worked
//             shifts.add({
//               "Punch In": punchInTime.toString(),
//               "Punch Out": "N/A",
//               "Punch Time": punchTimeList,
//               "Worked": "0 hours",
//               "Difference": "N/A",
//               "Salary": "₹0.00",
//             });
//           }
//         }
//       }

//       // Public Holiday Calculation
//       int holidayDeductions = 0;
//       double holidaySalary = 0;

//       if (totalShifts > 6) {
//         holidaySalary = holidayDates.length * dailySalary;
//         calculatedMonthlySalary += holidaySalary;
//       } else {
//         holidayDeductions = holidayDates.length;
//       }

//       result[employee.employeeCode] = {
//         'name': employee.name,
//         'employeeCode': employee.employeeCode,
//         'employeeWorkingHours': employee.workingHours,
//         'workingDays': totalShifts,
//         'absentDays': absentDaysCalculate - totalShifts - holidayDates.length,
//         'monthlySalary': employee.monthlySalary,
//         'dueSalary': calculatedMonthlySalary,
//         'holidayDeductions': holidayDeductions,
//         'holidaySalary': holidaySalary,
//         'dailyPunchLogInfo': shifts,
//       };
//     }

//     return result;
//   }
// }

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

      List<Map<String, dynamic>> shifts = [];
      double calculatedMonthlySalary = 0;
      int totalShifts = 0;

      DateTime? lastPunchInTime;
      List<String> punchTimeList =
          []; // List to collect punch times for the shift

      for (int i = 0; i < employeeLogs.length; i++) {
        var log = employeeLogs[i];
        if ("${log.logDate}".contains(
                "${salaryMonth == 12 ? salaryYear + 1 : salaryYear}-${salaryMonth == 12 ? "01" : salaryMonth > 10 ? salaryMonth : "0${salaryMonth + 1}"}-") &&
            log.punchDirection == 'in') {
        } else if (log.punchDirection == 'in' || log.punchDirection == ' ') {
          DateTime punchInTime = log.punchTime;

          // Check for consecutive punch-ins without punch-out
          if (lastPunchInTime != null &&
              punchInTime.difference(lastPunchInTime).inHours < 10) {
            punchTimeList.add(punchInTime.toString());
            continue; // Skip further processing for this punch
          }

          // Create a new shift if the time difference exceeds 10 hours
          lastPunchInTime = punchInTime; // Update lastPunchInTime
          punchTimeList = [
            punchInTime.toString()
          ]; // Start a new punch time list

          // Check for punch out
          DateTime? punchOutTime;
          if (i + 1 < employeeLogs.length &&
              employeeLogs[i + 1].punchDirection == "out") {
            punchOutTime = employeeLogs[i + 1].punchTime;
            double hoursWorked =
                punchOutTime.difference(punchInTime).inMinutes / 60.0;

            // Calculate salary and difference
            double calculatedSalary;
            String differenceText;

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
            punchTimeList.removeAt(0);
            shifts.add({
              "Punch In": punchInTime.toString(),
              "Punch Out": punchOutTime.toString(),
              "Punch Time": punchTimeList,
              "Worked":
                  "${hoursWorked.floor()} hours ${(hoursWorked.remainder(1) * 60).round()} minutes",
              "Difference": differenceText,
              "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
            });

            calculatedMonthlySalary += calculatedSalary;
            totalShifts += 1;
            i++; // Skip the next log as it was used for punch out
          } else {
            punchTimeList.removeAt(0);
            // If there's no punch out, record only punch in time with 0 hours worked
            shifts.add({
              "Punch In": punchInTime.toString(),
              "Punch Out": "N/A",
              "Punch Time": punchTimeList,
              "Worked": "0 hours",
              "Difference": "N/A",
              "Salary": "₹0.00",
            });
            totalShifts += 1;
          }
        }
      }

      // Public Holiday Calculation
      int holidayDeductions = 0;
      double holidaySalary = 0;

      if (totalShifts > 6) {
        holidaySalary = holidayDates.length * dailySalary;
        calculatedMonthlySalary += holidaySalary;
      } else {
        holidayDeductions = holidayDates.length;
      }

      result[employee.employeeCode] = {
        'name': employee.name,
        'employeeCode': employee.employeeCode,
        'employeeWorkingHours': employee.workingHours,
        'workingDays': totalShifts,
        'absentDays': absentDaysCalculate - totalShifts - holidayDates.length,
        'monthlySalary': employee.monthlySalary,
        'dueSalary': calculatedMonthlySalary,
        'holidayDeductions': holidayDeductions,
        'holidaySalary': holidaySalary,
        'dailyPunchLogInfo': shifts,
      };
    }

    return result;
  }
}
