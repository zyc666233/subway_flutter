import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  File subway_shanghai = File('assets/subway_shanghai.txt');
  var data = subway_shanghai.readAsLinesSync();
  var res = [];
  for (var i = 0; i < data.length; i++) {
    if (!data[i].endsWith("查看详细") && !res.contains(data[i])) {
      res.add(data[i]);
    }
  }

  Map<String, dynamic> city_stations = Map();
  city_stations['上海市'] = res;
  String city_stations_str = jsonEncode(city_stations);
  File city_stations_file = File('assets/city_stations.json');
  city_stations_file.writeAsStringSync(city_stations_str);
}
