import 'package:bill_split/Person.dart';

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

  static Bill fromMap(Map<String, dynamic> map){
    //TODO get people
    return Bill.all(map["id"], map["name"], []);
  }

}