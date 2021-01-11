import 'package:sqflite/sqflite.dart';

class UserSettings {
  final int id;
  final String domain;
  final int billDay;
  final double fix_0_100;
  final double fix_101;
  final double range_0_200;
  final double range_201_300;
  final double range_301_700;
  final double range_701;

  UserSettings(
      {this.id,
      this.domain,
      this.billDay,
      this.fix_0_100,
      this.fix_101,
      this.range_0_200,
      this.range_201_300,
      this.range_301_700,
      this.range_701});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'domain': domain,
      'billDay': billDay,
      'fix_0_100': fix_0_100,
      'fix_101': fix_101,
      'range_0_200': range_0_200,
      'range_201_300': range_201_300,
      'range_301_700': range_301_700,
      'range_701': range_701
    };
  }

  DateTime nextBillingDate() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if (now.month != 1) {
      if (now.day > billDay) {
        month = now.month - 1;
      }
    } else {
      year = now.year - 1;

      if (now.day < billDay) {
        month = 12;
      }
    }

    return DateTime(year, month, billDay, 12, 00, 0);
  }

  static Future<List<UserSettings>> toList(
      List<Map<String, dynamic>> maps) async {
    return List.generate(maps.length, (i) {
      return UserSettings(
        id: maps[i]['id'],
        domain: maps[i]['domain'],
        billDay: maps[i]['billDay'],
        fix_0_100: maps[i]['fix_0_100'],
        fix_101: maps[i]['fix_101'],
        range_0_200: maps[i]['range_0_200'],
        range_201_300: maps[i]['range_201_300'],
        range_301_700: maps[i]['range_301_700'],
        range_701: maps[i]['range_701'],
      );
    });
  }
}
