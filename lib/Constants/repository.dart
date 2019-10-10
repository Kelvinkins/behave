import 'package:behave/Model/model.dart';

class Repository {
  // List<Map> getPositive() => positive;
  // List<Map> getNegative() => negative;
  // List<Map> getAll() => neutral;

  List<String> getPositive() => positive
      .map((map) => TraitModel.fromJson(map))
      .map((item) => item.name)
      .toList();

  List<String> getNegative() => negative
      .map((map) => TraitModel.fromJson(map))
      .map((item) => item.name)
      .toList();

  List<String> getNeutral() => neutral
      .map((map) => TraitModel.fromJson(map))
      .map((item) => item.name)
      .toList();

  List positive = [
    {"Name": "Accessible"},
    {"Name": "Active"},
    {"Name": "Adaptable"},
    {"Name": "Admirable"},
    {"Name": "Adventurous"}
  ];

  List negative = [
    {"Name": "Nccessible"},
    {"Name": "Nctive"},
    {"Name": "Ndaptable"},
    {"Name": "Ndmirable"},
    {"Name": "Ndventurous"}
  ];

  List neutral = [
    {"Name": "Tccessible"},
    {"Name": "Tctive"},
    {"Name": "Ndaptable"},
    {"Name": "Tdmirable"},
    {"Name": "Tdventurous"}
  ];
}
