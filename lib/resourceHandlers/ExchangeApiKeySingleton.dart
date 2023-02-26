
import 'package:flutter/services.dart';

class ExchangeApiKeySingleton {
  static final ExchangeApiKeySingleton _singleton = ExchangeApiKeySingleton._internal();
  String apiKey;

  factory ExchangeApiKeySingleton() {
    return _singleton;
  }

  ExchangeApiKeySingleton._internal(): apiKey = "" {
    _loadApiKey();
  }
  
  void _loadApiKey(){
    rootBundle.loadString("res/exchangeApiKey")
        .then((value) => apiKey = value);
  }
}