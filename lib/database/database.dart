import 'dart:io' as io;

import 'package:moor/moor.dart';
// These imports are only needed to open the database
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@UseMoor(
  // relative import for the moor file. Moor also supports `package:`
  // imports
  include: {'tables.moor'},
)
class AppDb extends _$AppDb {


  static AppDb _instance;

  static AppDb get(){
    if(_instance == null)
    {
      _instance = AppDb();
    }
    return _instance;
  }


  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;


  Future<int> insertNewScan(ScansCompanion data){
    return into(scans).insert(data);
  }
  Future<int> deleteRecordsById(List<int> idsToDelete){
    return (delete(scans)..where((tbl) => tbl.id.isIn(idsToDelete))).go();
  }

  Future<bool> updateScan(Scan scanToUpdate){
     return update(scans).replace(scanToUpdate);
  }

}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = io.File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}
