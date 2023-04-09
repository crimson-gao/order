import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:order/model/order.dart';
import 'package:path/path.dart' as p;
import 'package:smartlogger/smartlogger.dart';
import 'package:sqflite/sqflite.dart';

final dbProvider = FutureProvider<Database>(
    (ref) async => await SqlDatabase().initializedDatabase());

class SqlDatabase {
  String dbName = 'test.db';
  static const int _version = 1;
  Database? _database;

  SqlDatabase({String? name}) {
    dbName = name ?? dbName;
  }

  void _createDateBase(Database db, int version) async {
    await db.execute(Order.createTableSql);
    await db.execute(Goods.createTableSql);
    await db.execute(OrderItem.createTableSql);
  }

  Future<Database> initializedDatabase() async {
    if (_database != null) return Future.value(_database);
    var path = p.join(await getDatabasesPath(), dbName);
    _database =
        await openDatabase(path, version: _version, onCreate: _createDateBase);
    Log.i('database $dbName opened, path: $path');
    return Future.value(_database);
  }

  void close() async {
    await _database?.close();
    Log.i('database $dbName closed');
  }
}
