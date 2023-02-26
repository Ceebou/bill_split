
class Currency {
  String symbol;
  String name;
  String code;

  Currency.all(this.symbol, this.name, this.code);

  Currency.fromJson(Map<String, dynamic> json):
      symbol = json["symbol"],
      name = json["name"],
      code = json["code"];



}