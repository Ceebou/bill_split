
import 'package:bill_split/objects/Currency.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:search_choices/search_choices.dart';

import '../resourceHandlers/CurrenciesSingleton.dart';

class CurrencyPicker extends StatelessWidget {

  final Function onChanged;
  final String initialValue;

  const CurrencyPicker({super.key, required this.onChanged, this.initialValue = "EUR"});

  @override
  Widget build(BuildContext context) {

    return SearchChoices.single(
      items: CurrenciesSingleton().getAllCurrencies().keys.map((e) => DropdownMenuItem<Currency>(
        value: CurrenciesSingleton().getCurrencyByCode(e),
          child: Row( children: [
            Text(CurrenciesSingleton().getCurrencyByCode(e).name),
            const Spacer(),
            Text(CurrenciesSingleton().getCurrencyByCode(e).symbol)
          ],)
      )).toList(),
      onChanged: onChanged,
      value: CurrenciesSingleton().getCurrencyByCode(initialValue),
      isExpanded: true,
      displayClearIcon: false,
      searchFn: _customSearch,
    );
  }

  //allows case insensitive search through name, code and symbol of currencies
  List<int> _customSearch(String keyword, List<DropdownMenuItem<Currency>> items){
    List<int> indices = [];
    keyword = keyword.toLowerCase();

    items.forEachIndexed((index, element) {
      Currency currency = element.value!;
      if (currency.name.toLowerCase().contains(keyword) || currency.code.toLowerCase().contains(keyword) || currency.symbol.toLowerCase().contains(keyword)){
        indices.add(index);
      }
    });

    return indices;
  }

}
