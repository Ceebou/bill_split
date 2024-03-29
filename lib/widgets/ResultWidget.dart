import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image, ImageByteFormat;

import 'package:bill_split/objects/Currency.dart';
import 'package:bill_split/resourceHandlers/CurrenciesSingleton.dart';
import 'package:bill_split/widgets/CurrencyPicker.dart';
import 'package:bill_split/widgets/SummaryCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';


import '../communication/ExchangeApi.dart';
import '../objects/Bill.dart';
import '../objects/Person.dart';

class ResultWidget extends StatefulWidget {

  final Bill bill;

  const ResultWidget({Key? key, required this.bill}): super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultWidgetState();

}

class _ResultWidgetState extends State<ResultWidget> {

  final ScreenshotController screenshotController = ScreenshotController();
  final String screenShotFileName = "screenshot.png";


  late Bill bill;
  late List<PersonPayments> payments;
  late Currency currency;

  @override
  void initState() {
    super.initState();
    bill = widget.bill;
    payments = calculateResult();
    currency = CurrenciesSingleton().getCurrencyByCode(widget.bill.currencyCode);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xff212121)),
        ),
        title: const Text("Payout"),
        actions: [
          TextButton(
              onPressed: () => _displayCurrencyExchangeInputDialog(context),
              child: const Icon(Icons.currency_exchange, color: Color(0xff212121))),
        ],
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 70),
            children: getListWidgets(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleShareScreenPressed,
        child: const Icon(Icons.share),
      ),
    );
  }

  Future<void> _displayCurrencyExchangeInputDialog(BuildContext context) async {
    Currency currentlySelected = currency;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState){
              return AlertDialog(
                title: const Text("Exchange"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CurrencyPicker(
                        initialValue: currentlySelected.code,
                        onChanged: (v) {
                          setState(() {
                            currentlySelected = v;
                          });
                        }
                    ),
                    if (bill.currencyCode != currentlySelected.code)
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(CurrenciesSingleton().getCurrencyByCode(bill.currencyCode).symbol),
                                const Icon(Icons.arrow_right_alt),
                                Text(currentlySelected.symbol)
                              ],
                            ),
                            FutureBuilder<double>(
                                future: ExchangeApi().getExchangeRateFromTo(bill.currencyCode, currentlySelected.code),
                                builder: (BuildContext context, AsyncSnapshot<double> snapshot){
                                  if  (snapshot.hasData){
                                    return Text(snapshot.data!.toStringAsFixed(5));
                                  } else {
                                    return const Text("...");
                                  }
                                }
                            ),
                          ],
                        ),
                      )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        _onExchangeCurrencyChanged(currentlySelected);
                        Navigator.pop(context);
                      },
                      child: const Text("Exchange")),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text("Close")),
                ],
              );
            },
          );
        });
  }

  void _handleShareScreenPressed() async {
    await screenShotList();
    shareScreenshot();
  }

  Future<void> screenShotList() async {
    screenshotController.captureAndSave(await getDatabasesPath(), fileName: screenShotFileName, pixelRatio: 1);
  }

  void shareScreenshot() async {
    String path = join(await getDatabasesPath(), screenShotFileName);
    Share.shareFiles([path], text: "Share Payout");
  }

  List<Widget> getListWidgets(){
    List<Widget> summary = [SummaryCard(bill: bill, targetCurrency: currency,), const Divider(thickness: 2, color: Colors.amber,)];
    List<Widget> payments = getPaymentWidgets();
    return summary + payments;
  }

  List<Widget> getPaymentWidgets(){
    List<PersonPayments> payments = this.payments;
    return payments.map((e) => paymentToCard(e)).toList();
  }

  Widget paymentToCard(PersonPayments payment){
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(payment.from.name),
            const SizedBox(width: 5,),
            const Icon(Icons.arrow_right_alt_sharp, color: Color(0xff757575)),
            const SizedBox(width: 5,),
            Expanded(
              child: Column(
                children: payment.amounts.map((amount) => Row(
                  children: [
                    Text(amount.person.name),
                    const Spacer(),
                    Align(alignment: Alignment.topRight,child: Text("${(amount.value / 100).toStringAsFixed(2)} ${currency.symbol}"),),
                  ],
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<PersonPayments> calculateResult(){
    // calculate starting values, set up map
    int sum = bill.people.map((e) => e.cent).fold<int>(0, (previousValue, element) => previousValue + element);
    double average = sum / bill.people.length;
    
    //get people that will receive money
    Map<Person, double> peopleToReceiveMoney = {};
    for (Person person in bill.people){
      if (person.cent > average){
        double toReceive = person.cent - average;
        peopleToReceiveMoney[person] = toReceive;
      }
    }

    //calculate payout
    List<PersonPayments> payments = [];
    for (Person person in bill.people){
      if (person.cent < average){
        double toPay = average - person.cent;
        payments.add(giveMoney(person, toPay, peopleToReceiveMoney));
      }
    }

    return payments;
  }

  PersonPayments giveMoney(Person from, double amount, Map<Person, double> peopleToReceiveMoney){
    Person toReceive = peopleToReceiveMoney.keys.first;
    PersonPayments payments = PersonPayments(from);

    if (peopleToReceiveMoney[toReceive]! > amount){
      payments.amounts.add(TuplePersonValue(toReceive, amount));
      peopleToReceiveMoney[toReceive] = peopleToReceiveMoney[toReceive]! - amount;
    } else {
      payments.amounts.add(TuplePersonValue(toReceive, peopleToReceiveMoney[toReceive]!));
      double leftToPay = amount - peopleToReceiveMoney[toReceive]!;
      peopleToReceiveMoney.remove(toReceive); // remove person that has received all their money
      if (leftToPay >= 0.01){
        PersonPayments remainingPayments = giveMoney(from, leftToPay, peopleToReceiveMoney); //recursive call to pay next person
        payments.amounts.addAll(remainingPayments.amounts);
      }
    }
    return payments;
  }

  void _onExchangeCurrencyChanged(Currency selectedCurrency) {
    if (currency.code != selectedCurrency.code){
      setState(() {   //maybe set state in recalc
        _recalculateResult(selectedCurrency);
        currency = selectedCurrency;
      });
    }
  }

  Future<void> _recalculateResult(Currency selectedCurrency) async {
    double rate = await ExchangeApi().getExchangeRateFromTo(currency.code, selectedCurrency.code);
    setState(() {
      for (PersonPayments payment in payments) {
        for (TuplePersonValue tuple in payment.amounts){
          tuple.value = (tuple.value * rate).toPrecision(0);
        }
      }
    });

  }
}

class PersonPayments {
  Person from;
  List<TuplePersonValue> amounts;

  PersonPayments(this.from): amounts = [];
}

class TuplePersonValue{
  Person person;
  double value;

  TuplePersonValue(this.person, this.value);
}
