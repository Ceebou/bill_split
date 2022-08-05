import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Bill.dart';
import 'Person.dart';

class ResultWidget extends StatelessWidget {
  final Bill bill;

  const ResultWidget({Key? key, required this.bill}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    List<PersonPayments> payments = calculateResult();
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xff212121)),
        ),
        title: const Text("Payout"),
      ),
      body: ListView(
        children: payments.map((payment) => Card(
          child: ListTile(
            title: Row(
              children: [
                Text(payment.from.name),
                const SizedBox(width: 5,),
                const Icon(Icons.arrow_right_alt_sharp),
                const SizedBox(width: 5,),
                Expanded(
                  child: Column(
                    children: payment.amounts.map((amount) => Row(
                      children: [
                        Text(amount.person.name),
                        const Spacer(),
                        Align(alignment: Alignment.topRight,child: Text((amount.value / 100).toStringAsFixed(2)),),
                      ],
                    )).toList(),
                  ),
                )
              ],
            ),
          ),
        )).toList(),
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
