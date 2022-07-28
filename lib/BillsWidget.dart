import 'package:bill_split/PeopleWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Bill.dart';

class BillsWidget extends StatefulWidget {

  const BillsWidget({Key? key}) : super(key: key);

  @override
  State<BillsWidget> createState() => _BillsWidgetState();
}

class _BillsWidgetState extends State<BillsWidget> {
  late List<Bill> bills;

  String inputText = "";
  late TextEditingController textEditingController;


  _BillsWidgetState(){
    bills = []; //TODO load bills
  }


  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  void addBill(){
    setState(() {
      bills.add(Bill(textEditingController.value.text));
    });
    textEditingController.clear();
    Navigator.pop(context);
  }


  Future<void> _displayBillTitleInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Bill Title'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
              controller: textEditingController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            actions: <Widget>[
              TextButton(onPressed: addBill, child: const Text("Add"))

            ],
          );
        });
  }

  void deleteBill(Bill bill){
    setState((){
      bills.remove(bill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bills"),
      ),
      body: ListView(
        children: bills.map((e) =>
            Card(
              child: ListTile(
                tileColor: Colors.lightGreen,
                title: Text(e.name),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeopleWidget(bill: e))),
                trailing: TextButton(
                  onPressed: () => {deleteBill(e)},
                  child: const Icon(Icons.delete, color: Colors.white,),
                ),
              ),
            )
        ).toList()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayBillTitleInputDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}




