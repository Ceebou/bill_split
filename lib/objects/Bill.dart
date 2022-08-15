import 'package:bill_split/db/BillDatabase.dart';
import 'package:bill_split/objects/Person.dart';

class Bill {
  int? id;
  String name;
  List<Person> people;

  Bill(this.name): people = [];
  Bill.all(this.id, this.name, this.people);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }

  //does not populate the people array, needs to be done separately
  static Bill fromMap(Map<String, dynamic> map){
    return Bill.all(map["id"], map["name"], []);
  }

  int getSum(){
    return people.map((e) => e.cent).fold(0, (previousValue, element) => previousValue + element);
  }

  String getAverage(){
    return (getSum() / 100 / people.length).toStringAsFixed(2);
  }

}