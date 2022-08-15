import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int sum;
  final String average;

  const SummaryCard({Key? key, required this.sum, required this.average}) : super(key: key);

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
                Text(centToString(sum.toDouble())),
              ],
            ),
            const SizedBox(height: 2,),
            Row(
              children: [
                const Text("Per Person"),
                const Spacer(),
                Text(average),
              ],
            )
          ],
        ),
      ),
    );
  }

  String centToString(double value){
    return (value/100).toStringAsFixed(2);
  }
}
