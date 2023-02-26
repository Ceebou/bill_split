
import 'dart:convert';

import 'package:bill_split/resourceHandlers/ExchangeApiKeySingleton.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ExchangeApi  {

  static final ExchangeApi _singleton = ExchangeApi._internal();

  final apiKey = ExchangeApiKeySingleton().apiKey;
  final Map<String, Map<String, double>> _rateCache = {};

  factory ExchangeApi() {
    return _singleton;
  }

  ExchangeApi._internal();


  //make async
  Future<double> getExchangeRateFromTo(String from, String to) async {
    if (_cacheContains(from, to)){
      return _cacheLoad(from, to);
    }
    String uri = "${_buildBaseUri()}&base_currency=$from&currencies=$to";
    http.Response response = await http.get(Uri.parse(uri));
    if(response.statusCode == 200){
      double rate  = _getExchangeRateFromResponse(response.body, to);
      _cacheAdd(from, to, rate);
      return rate;
    } else {
      if (kDebugMode) {
        print("Error fetching exchange rate ${response.statusCode}");
      }
      return 1;
    }
  }

  Future<int> exchangeMoneyFromTo(int value, String from, String to) async {
    double rate = await getExchangeRateFromTo(from, to);
    return (value * rate).floor();
  }

  String _buildBaseUri(){
    return "https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey";
  }

  double _getExchangeRateFromResponse(String response, String to){
    Map<String, dynamic> jsonData = jsonDecode(response)["data"];
    return jsonData[to];
  }

  bool _cacheContains(String from, String to){
    if (_rateCache.containsKey(from)){
      if (_rateCache[from]!.containsKey(to)){
        return true;
      }
    }
    return false;
  }

  //does not check if queried value is present
  double _cacheLoad(String from, String to){
    return _rateCache[from]![to]!;
  }

  void _cacheAdd(String from, String to, double rate){
    if (!_rateCache.containsKey(from)){
      _rateCache[from] = {};
    }
    _rateCache[from]![to] = rate;
  }
}