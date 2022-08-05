import 'dart:ffi';

import 'package:bill_split/Bill.dart';
import 'package:bill_split/BillDatabase.dart';
import 'package:bill_split/Person.dart';
import 'package:bill_split/ResultWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PeopleWidget extends StatefulWidget {
  final Bill bill;

  const PeopleWidget({Key? key, required this.bill}) : super(key: key);

  @override
  State<PeopleWidget> createState() => _PeopleWidgetState();
}

class _PeopleWidgetState extends State<PeopleWidget> {

  String inputText = "";
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  void addPerson(){
    persistPerson(Person(textEditingController.value.text, 0));
    textEditingController.clear();
    Navigator.pop(context);
  }

  void persistPerson(Person person) async {
    person = await BillDatabase.billDatabase.addPerson(person, widget.bill);
    setState(() {
      widget.bill.people.add(person);
    });
  }

  Future<void> _displayPersonNameInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Persons Name'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },

              controller: textEditingController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            actions: <Widget>[
              TextButton(onPressed: addPerson, child: const Text("Add"))

            ],
          );
        });
  }

  void addMoney(Person person){
    setState((){
      int toAdd = (double.parse(textEditingController.value.text) * 100).floor();
      person.cent += toAdd;
      BillDatabase.billDatabase.updatePerson(person, widget.bill);
    });
    textEditingController.clear();
    Navigator.pop(context);
  }

  Future<void> _displayPersonAddMoneyInputDialog(Person person) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Money'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: textEditingController,
              decoration: const InputDecoration(hintText: "0.00"),
            ),
            actions: <Widget>[
              TextButton(onPressed: () => addMoney(person), child: const Text("Add"))
            ],
          );
        });
  }

  Future<void> _displayEditPersonDialog(Person person) async {
    textEditingController.text = person.name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Persons Name'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
              controller: textEditingController,
              decoration: const InputDecoration(hintText: "Name",),
            ),
            actions: <Widget>[
              TextButton(onPressed: (){deletePerson(person);}, child: const Icon(Icons.delete)),
              TextButton(onPressed: (){editPerson(person);}, child: const Text("Edit"))
            ],
          );
        });
  }

  void editPerson(Person person){
    setState((){
      person.name = textEditingController.value.text;
      BillDatabase.billDatabase.updatePerson(person, widget.bill);
    });
    Navigator.pop(context);
  }

  void deletePerson(Person person){
    setState(() {
      widget.bill.people.remove(person);
      BillDatabase.billDatabase.removePerson(person);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Icon(Icons.arrow_back, color: Color(0xff212121),),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.bill.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResultWidget(bill: widget.bill))),
              child: const Icon(Icons.calculate, color: Color(0xff212121))),
        ],
      ),
      body: ListView(
        children: widget.bill.people.map((person) => Card(
          child: ListTile(
            title: Row(
              children: [
                Text(person.name),
                const Spacer(),
                Text(person.centToString()),
                const SizedBox(width: 10,),
                ElevatedButton(
                    onPressed: () =>_displayPersonAddMoneyInputDialog(person),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.add),
                )
              ],
            ),
            onLongPress: (){_displayEditPersonDialog(person);},
          ),
        )).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayPersonNameInputDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
