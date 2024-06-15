import 'dart:convert';

class SettingModel {
  String title;
  double value;
  double step;

  SettingModel({required this.title, required this.value, required this.step});

  factory SettingModel.fromJson(Map<String, dynamic> jsonData) {
    return SettingModel(
      title: jsonData['title'],
      value: jsonData['value'],
      step: jsonData['step'],
    );
  }

  static Map<String, dynamic> toMap(SettingModel item) => {
        'title': item.title,
        'value': item.value,
        'step': item.step,
      };

  static String encode(List<SettingModel> musics) => json.encode(
        musics
            .map<Map<String, dynamic>>((music) => SettingModel.toMap(music))
            .toList(),
      );

  static List<SettingModel> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<SettingModel>((item) => SettingModel.fromJson(item))
          .toList();
}
