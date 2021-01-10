import 'package:path/path.dart';
import 'package:peta_app/Models/Settings.dart';
import 'package:sqflite/sqflite.dart';

class AppDataBase {
  Database _db;

  Future initDB() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'peta_db.db'),
        version: 1, onCreate: (Database db, int version) {
      db.execute(
          "CREATE TABLE settings (id INTEGER PRIMARY KEY, domain TEXT, billDay INTEGER, fix_0_100 NUMERIC, fix_101 NUMERIC, range_0_200 NUMERIC, range_201_300 NUMERIC, range_301_700 NUMERIC, range_701 NUMERIC)");
      db.execute(
          "INSERT INTO settings (id, billDay, fix_0_100, fix_101, range_0_200, range_201_300, range_301_700, range_701 ) VALUES (1, 1, 37.95, 137.25, 4.44, 6.97, 10.86, 11.10)");
    });
  }

  Future<List<UserSettings>> getUserSettings() async {
    if (_db != null) {
      List<Map<String, dynamic>> maps = await _db.query('settings');

      return await UserSettings.toList(maps);
    }
  }

  Future<bool> deleteDb() async {
    bool databaseDeleted = false;

    try {
      String path = join(join(await getDatabasesPath(), 'peta_db.db'));
      await deleteDatabase(path).whenComplete(() {
        databaseDeleted = true;
      }).catchError((onError) {
        databaseDeleted = false;
      });
    } on DatabaseException catch (error) {
      print(error);
    } catch (error) {
      print(error);
    }

    return databaseDeleted;
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _db.update(
      'settings',
      settings.toMap(),
      where: "id = ?",
      whereArgs: [settings.id],
    );
  }

  Future<void> insertSettings(UserSettings settings) async {
    await _db.insert(
      'settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
