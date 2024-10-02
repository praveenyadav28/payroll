import 'dart:convert';

List<Mismastermodel> mismastermodelFromJson(String str) =>
    List<Mismastermodel>.from(
        json.decode(str).map((x) => Mismastermodel.fromJson(x)));

String mismastermodelToJson(List<Mismastermodel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Mismastermodel {
  final int id;
  final String name;
  final int miscTypeId;

  Mismastermodel({
    required this.id,
    required this.name,
    required this.miscTypeId,
  });

  factory Mismastermodel.fromJson(Map<String, dynamic> json) => Mismastermodel(
        id: json["id"],
        name: json["name"],
        miscTypeId: json["miscTypeId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "miscTypeId": miscTypeId,
      };
}
