import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  File city_stations_file = File('assets/city_stations.json');
  var city_stations_str = city_stations_file.readAsStringSync();
  Map<String, dynamic> city_stations = jsonDecode(city_stations_str);

  File subway_stations = File('assets/subway_stations.txt');
  var data = subway_stations.readAsLinesSync();
  var res = [];
  for (var i = 0; i < data.length; i++) {
    if (!data[i].endsWith("查看详细") && !res.contains(data[i])) {
      res.add(data[i]);
    }
  }
  city_stations['南京市'] = res;

  print(city_stations['上海市']);
  print(city_stations['南京市']);
  city_stations_str = jsonEncode(city_stations);
  city_stations_file.writeAsStringSync(city_stations_str);
}
