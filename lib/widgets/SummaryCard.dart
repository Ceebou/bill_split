import 'package:bill_split/communication/ExchangeApi.dart';
import 'package:bill_split/objects/Bill.dart';
import 'package:bill_split/objects/Currency.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final Bill bill;
  final Currency targetCurrency;

  const SummaryCard({Key? key, required this.bill, required this.targetCurrency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      elevation: 0,
      child: ListTile(
        title: Column(
          children: [
            Row(
              children: [
                const Text("Sum"),
                const Spacer(),
                FutureBuilder<int>(
                  future: getSum(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                      if  (snapshot.hasData){
                        return Text("${centToString(snapshot.data!)} ${targetCurrency.symbol}");
                      } else {
                        return const Text("...");
                      }
                    }
                ),
              ],
            ),
            const SizedBox(height: 2,),
            Row(
              children: [
                const Text("Per Person"),
                const Spacer(),
                FutureBuilder<int>(
                    future: getAverage(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                      if  (snapshot.hasData){
                        return Text("${centToString(snapshot.data!)} ${targetCurrency.symbol}");
                      } else {
                        return const Text("...");
                      }
                    }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<int> getSum(){
    int sumFromBill = bill.getSum();
    return exchange(sumFromBill);
  }

  Future<int> getAverage(){
    int averageFromBill = bill.getAverage();
    return exchange(averageFromBill);
  }

  Future<int> exchange(int value) async {
    if (bill.currencyCode != targetCurrency.code){
       return await ExchangeApi().exchangeMoneyFromTo(value, bill.currencyCode, targetCurrency.code);
    } else {
      return value;
    }

  }

  String centToString(int value){
    return (value/100).toStringAsFixed(2);
  }
}
