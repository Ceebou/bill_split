import 'dart:ffi';

import 'package:bill_split/communication/ExchangeApi.dart';
import 'package:bill_split/objects/Currency.dart';
import 'package:bill_split/resourceHandlers/CurrenciesSingleton.dart';
import 'package:bill_split/objects/Bill.dart';
import 'package:bill_split/db/BillDatabase.dart';
import 'package:bill_split/objects/Person.dart';
import 'package:bill_split/widgets/CurrencyPicker.dart';
import 'package:bill_split/widgets/ResultWidget.dart';
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
  late Currency currencySelection;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    currencySelection = CurrenciesSingleton().getCurrencyByCode(widget.bill.currencyCode);
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
              autofocus: true,
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

  void addMoney(Person person) async {
    String toParse = textEditingController.value.text;
    if (currencySelection.code != widget.bill.currencyCode){
      getConvertedMoney().then((value){
        setState(() {
          _parseAndAdd(value, person);
        });
      });
    } else {
      setState((){
        _parseAndAdd(toParse, person);
      });
    }
    textEditingController.clear();
    Navigator.pop(context);
  }

  void _parseAndAdd(String toParse, Person person){
    int toAdd = (double.parse(toParse.replaceAll(",", ".")) * 100).floor();
    person.cent += toAdd;
    BillDatabase.billDatabase.updatePerson(person, widget.bill);
  }

  void setCurrencySelection(Currency selected){
    setState(() {
      currencySelection = selected;
    });
  }

  Future<String> getConvertedMoney() async {
    int initial = (double.parse(textEditingController.value.text.replaceAll(",", ".")) * 100).floor();
    int converted = await ExchangeApi().exchangeMoneyFromTo(initial, currencySelection.code, widget.bill.currencyCode);

    return (converted / 100).toStringAsFixed(2);
  }

  Future<void> _displayPersonAddMoneyInputDialog(Person person) async {
    textEditingController.clear();
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Money'),
                content: Column(
                  mainAxisSize: MainAxisSize.min, //important, else there is a lot of blank space at the bottom
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          inputText = value;
                        });
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      controller: textEditingController,
                      decoration: const InputDecoration(hintText: "0.00"),
                    ),
                    Center(
                      child: CurrencyPicker(
                        initialValue: currencySelection.code,
                          onChanged: (v) {
                            setState(() {
                              currencySelection = v;
                            });
                          }),
                    ),
                    if (currencySelection.code != widget.bill.currencyCode &&
                        textEditingController.value.text != "")
                      Column(children: [
                        const Text("Equal to:"),
                        FutureBuilder<String>(
                          future: getConvertedMoney(),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if ( snapshot.hasData) {
                              return Text("${snapshot.data} ${CurrenciesSingleton().getCurrencyByCode(widget.bill.currencyCode).symbol}");
                            } else {
                              return const Text("...");
                            }
                      },)
                      ],)
                  ],
                ),
                actions: <Widget>[
                  TextButton(onPressed: () => addMoney(person),
                      child: const Text("Add"))
                ],
              );
            }
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
    textEditingController.clear();
    Navigator.pop(context);
  }

  void deletePerson(Person person){
    setState(() {
      widget.bill.people.remove(person);
      BillDatabase.billDatabase.removePerson(person);
    });
    textEditingController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Icon(Icons.arrow_back, color: Color(0xff212121),),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text("${widget.bill.name} - "),
            Text(CurrenciesSingleton().getCurrencyByCode(widget.bill.currencyCode).symbol)
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (widget.bill.people.isNotEmpty){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResultWidget(bill: widget.bill)));
                }
                },
              child: const Icon(Icons.calculate, color: Color(0xff212121))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 70),
        children: widget.bill.people.map((person) => Card(
          child: ListTile(
            title: Row(
              children: [
                Text(person.name),
                const Spacer(),
                Text("${person.centToString()} ${CurrenciesSingleton().getCurrencyByCode(widget.bill.currencyCode).symbol}"),
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
