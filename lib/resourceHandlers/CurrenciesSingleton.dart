import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import '../objects/Currency.dart';

class CurrenciesSingleton {
  static final CurrenciesSingleton _singleton = CurrenciesSingleton._internal();
  Map<String, Currency> _currencies;

  factory CurrenciesSingleton() {
    return _singleton;
  }

  CurrenciesSingleton._internal():_currencies = {}{
     _loadCurrencies();
  }

  Map<String, Currency> getAllCurrencies(){
    return _currencies;
  }

  void _loadCurrencies(){
    //File file = File("res/currencies.json");
    //Future<String> futureContent = file.readAsString();
    Future<String> futureContent = rootBundle.loadString("res/currencies.json");
    futureContent.then((value) {
      Map<String, dynamic> jsonData = jsonDecode(value)["data"];
      for (var code in jsonData.keys) {
        _currencies[code] = Currency.fromJson(jsonData[code]);
      }
    });
  }

  Currency getCurrencyByCode(String code){
    if (_currencies.containsKey(code)){
      return _currencies[code]!;
    }
    return _currencies["EUR"]!;
  }
}