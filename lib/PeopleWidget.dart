import 'dart:ffi';

import 'package:bill_split/Bill.dart';
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
    setState((){
      widget.bill.people.add(Person(textEditingController.value.text, 0));
    });
    textEditingController.clear();
    Navigator.pop(context);
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
      person.cent += (double.parse(textEditingController.value.text) * 100).floor();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.bill.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResultWidget(bill: widget.bill))),
              child: const Icon(Icons.calculate, color: Colors.white,)),
        ],
      ),
      body: ListView(
        children: widget.bill.people.map((person) => Card(
          child: ListTile(
            title: Row(
              children: [
                Text(person.name),
                Spacer(),
                Text(person.cent.toString()),
                ElevatedButton(onPressed: () =>_displayPersonAddMoneyInputDialog(person),
                    child: const Icon(Icons.add)
                )
              ],
            ),
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
