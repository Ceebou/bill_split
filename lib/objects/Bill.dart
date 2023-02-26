import 'package:bill_split/db/BillDatabase.dart';
import 'package:bill_split/objects/Person.dart';
import 'package:screenshot/screenshot.dart';

class Bill {
  int? id;
  String name;
  List<Person> people;
  String currencyCode;

  Bill(this.name, this.currencyCode): people = [];
  Bill.all(this.id, this.name, this.currencyCode, this.people);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "currencyCode": currencyCode
    };
  }

  //does not populate the people array, needs to be done separately
  static Bill fromMap(Map<String, dynamic> map){
    return Bill.all(map["id"], map["name"], map["currencyCode"], []);
  }

  int getSum(){
    return people.map((e) => e.cent).fold(0, (previousValue, element) => previousValue + element);
  }

  int getAverage(){
    return (getSum() / people.length).floor();
  }

}