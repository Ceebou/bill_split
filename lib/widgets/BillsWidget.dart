import 'package:bill_split/db/BillDatabase.dart';
import 'package:bill_split/widgets/PeopleWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../objects/Bill.dart';

class BillsWidget extends StatefulWidget {

  const BillsWidget({Key? key}) : super(key: key);

  @override
  State<BillsWidget> createState() => _BillsWidgetState();

}

class _BillsWidgetState extends State<BillsWidget> {
  late List<Bill> bills;

  String inputText = "";
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    bills = [];
    loadBills();
  }

  void loadBills() async {
    List<Bill> temp = await BillDatabase.billDatabase.getBills();
    setState(() {
      bills = temp;
    });
  }

  void addBill() {
    Bill bill = Bill(textEditingController.value.text);
    persistBill(bill);
    textEditingController.clear();
    Navigator.pop(context);
  }

  void persistBill(Bill bill) async {
    bill = await BillDatabase.billDatabase.addBill(bill);
    setState(() {
      bills.add(bill);
    });
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
      BillDatabase.billDatabase.removeBill(bill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bills"),
      ),
      body: ListView(
          padding: const EdgeInsets.only(bottom: 70),
          children: bills.map((e) =>
            Card(
              child: ListTile(
                title: Text(e.name),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeopleWidget(bill: e))),
                trailing: TextButton(
                  onPressed: () => {deleteBill(e)},
                  child: const Icon(Icons.delete),
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




