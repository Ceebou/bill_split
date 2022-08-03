import 'package:bill_split/Bill.dart';

class Person {
  int? id;
  String name;
  int cent;

  Person(this.name, this.cent);
  Person.all(this.id, this.name, this.cent);


  Map<String, dynamic> toMap(int billId) {
    return {
      "id": id,
      "name": name,
      "cent": cent,
      "bill": billId,
    };
  }

  static Person fromMap(Map<String, dynamic> map){
    return Person.all(map["id"], map["name"], map["cent"]);
  }
}