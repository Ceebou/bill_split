import 'package:bill_split/objects/Bill.dart';
import 'package:bill_split/objects/Person.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class BillDatabase {

  BillDatabase._();
  static final BillDatabase billDatabase = BillDatabase._();

  Database? _db;

  Future<Database> get db async => _db??=await getDatabaseInstance();

  Future<Database> getDatabaseInstance() async {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'bill_database.db'),
      onCreate: (db,version) async {
        await db.execute(
            'CREATE TABLE bills(id INTEGER PRIMARY KEY, name TEXT, currencyCode TEXT)'

        );
        return db.execute(
            'CREATE TABLE people(id INTEGER PRIMARY KEY, name TEXT, cent INTEGER, bill INTEGER, FOREIGN KEY(bill) REFERENCES bill(id) ON DELETE CASCADE);'
        );
      },
      version: 1,
    );
    return database;
  }

  Future<List<Bill>> getBills() async {
    Database db = await billDatabase.db;
    var result = await db.query("bills");
    List<Bill> bills = result.isNotEmpty ? result.map((e) => Bill.fromMap(e)).toList() : [];

    for(Bill bill in bills){
      List<Person> people = await getPeopleByBill(bill);
      bill.people = people;
    }

    return bills;
  }

  Future<Bill> addBill(Bill bill) async {
    Database db = await billDatabase.db;
    int id = await db.insert("bills", bill.toMap());
    bill.id = id;
    return bill;
  }

  Future<int> removeBill(Bill bill) async {
    Database db = await billDatabase.db;
    return await db.delete("bills", where: "id = ?", whereArgs: [bill.id]);
  }
  
  Future<List<Person>> getPeopleByBill(Bill bill) async {
    Database db = await billDatabase.db;
    var result = await db.query("people", where: "bill = ?", whereArgs: [bill.id]);
    List<Person> people = result.isNotEmpty ? result.map((e) => Person.fromMap(e)).toList() : [];
    return people;
  }

  Future<Person> getPersonById(int id) async {
    Database db = await billDatabase.db;
    var result = await db.query("people", where: "id = ?", whereArgs: [id]);
    Person people = result.isNotEmpty ? result.map((e) => Person.fromMap(e)).toList().first : throw Exception("No Person with id $id");
    return people;
  }

  Future<Person> addPerson(Person person, Bill bill) async {
    Database db = await billDatabase.db;
    int id = await db.insert("people", person.toMap(bill.id!));
    person.id = id;
    return person;
  }

  Future<Person> updatePerson(Person person, Bill bill) async {
    Database db = await billDatabase.db;
    int id = await db.update("people", person.toMap(bill.id!), where: "id = ?", whereArgs: [person.id]);
    person.id = id;
    return person;
  }

  Future<int> removePerson(Person person) async {
    Database db = await billDatabase.db;
    return await db.delete("people", where: "id = ?", whereArgs: [person.id]);
  }
}


