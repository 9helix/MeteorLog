import 'coordinates.dart';

class Observer {
  String? name;
  double? limMag;
  double? obstr;
  Coordinates? coords;
  List<List<dynamic>> csvData = [
    ["DATE UT", "START", "END", "Teff", "RA", "Dec", "F", "Lm"]
  ];
  List<List<dynamic>> csvData2 = [
    [
      "DATE UT",
      "START",
      "END",
      "SHOWER",
      "-6",
      "-5",
      "-4",
      "-3",
      "-2",
      "-1",
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7"
    ]
  ];
}
