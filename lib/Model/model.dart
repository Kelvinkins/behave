class TraitModel {
  String name;
  // String alias;

  TraitModel({this.name});

  TraitModel.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    return data;

  }

  
}