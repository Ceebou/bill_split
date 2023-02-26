import 'package:bill_split/objects/Currency.dart';
import 'package:bill_split/resourceHandlers/CurrenciesSingleton.dart';
import 'package:bill_split/db/BillDatabase.dart';
import 'package:bill_split/widgets/CurrencyPicker.dart';
import 'package:bill_split/widgets/PeopleWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:search_choices/search_choices.dart';

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
  late Currency? dropdownSelection;

  @override
  void initState() {
    super.initState();
    CurrenciesSingleton();
    textEditingController = TextEditingController();
    bills = [];
    loadBills();
    dropdownSelection = null;
  }

  void loadBills() async {
    List<Bill> temp = await BillDatabase.billDatabase.getBills();
    setState(() {
      bills = temp;
    });
  }

  void addBill() {
    dropdownSelection ??= CurrenciesSingleton().getCurrencyByCode("EUR");
    Bill bill = Bill(textEditingController.value.text, dropdownSelection!.code);
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
            content: Column(
              mainAxisSize: MainAxisSize.min, //important, else there is a lot of blank space at the bottom
              children: [
                TextField(
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      inputText = value;
                    });
                  },
                  controller: textEditingController,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                Center(
                  child: CurrencyPicker(
                    onChanged: (a)=>{dropdownSelection = a},
                  ),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(onPressed: addBill, child: const Text("Add")),
            ],
          );
        });
  }

  Future<void> _showDeleteConfirmationDialog(Bill bill) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete'),
            content: Text("Are you sure you want to delete ${bill.name}?"),
            actions: <Widget>[
              TextButton(onPressed: (){deleteBill(bill); Navigator.pop(context);}, child: const Text("Delete")),
              TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Cancel"))
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
                  onPressed: () => {_showDeleteConfirmationDialog(e)},
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




