import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'widgets/table_cell.dart';
import 'widgets/text_field.dart';
import 'colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'MeteorLog';
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return MaterialApp(
        theme: ThemeData(
          splashColor: Color(0xff151515),
          highlightColor: darkGrey,
          canvasColor: lightGrey,
          // Define the default brightness and colors.
          scaffoldBackgroundColor: darkGrey,
          primaryColor: darkGrey,

          // Define the default font family.
          fontFamily: 'Open Sans',

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Open Sans'),
          ),
        ),
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: darkGrey,
              title: const Text(appTitle, style: TextStyle(color: red)),
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const MyCustomForm()],
                ),
              ),
            )));
  }
}

// Multi Select widget
// This widget is reusable
class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

// meteor shower popup
class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = MyCustomFormState._selectedShowers;

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    if (_selectedItems.contains("SPO")) {
      _selectedItems.remove("SPO");
      _selectedItems.add("SPO");
    }

    Navigator.pop(context, _selectedItems);
    //print(MyCustomFormState._selectedShowers);
  }

  final MyCustomFormState main = MyCustomFormState();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      backgroundColor: darkGrey,
      title: const Text(
        'Select Meteor Showers',
        style: redNormal,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    fillColor: MaterialStateProperty.resolveWith(main.getColor),
                    checkColor: red,
                    value: _selectedItems.contains(item),
                    title: Text(item, style: redNormal),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: red, // foreground
          ),
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: midGrey, // Background color
            foregroundColor: red, // Text Color (Foreground color)
          ),
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.

  Future<String> readShowers() async {
    String text = await rootBundle.loadString('data/meteor_showers.xml');
    return text;
  }

  Future<String> dir() async {
    String out;
    final directory = await getApplicationDocumentsDirectory();
    out = directory.path;
    return out;
  }

//Observation upload link
  final Uri _url = Uri.parse(
      'https://www.imo.net/members/imo_observation/upload_observation');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  static const Duration showerDeviation = Duration(days: 15);
  List<String> currentShowers = [];
  Future<void> getShowers() async {
    Map<String, List<String>> showerMap = {};
    DateTime currentDate = DateTime.now();
    int currentYear = DateTime.now().year;
    //String formattedDate = DateFormat('MMM dd').format(currentDate);
    String xmlData = await readShowers();
    final document = XmlDocument.parse(xmlData);
    final showers = document.findAllElements('shower');

    for (final shower in showers) {
      final iauCode = shower.findElements('IAU_code').first.innerText;
      final showerStart = shower.findElements('start').first.innerText;
      final showerEnd = shower.findElements('end').first.innerText;
      DateTime startDate = DateFormat('MMM dd').parse(showerStart);

      DateTime endDate = DateFormat('MMM dd').parse(showerEnd);
      if (startDate.isAfter(endDate)) {
        endDate = DateTime(currentYear + 1, endDate.month, endDate.day);
      } else {
        endDate = DateTime(currentYear, endDate.month, endDate.day);
      }
      startDate = DateTime(currentYear, startDate.month, startDate.day);
      if (currentDate.isAfter(startDate.subtract(showerDeviation)) &&
          currentDate.isBefore(endDate.add(showerDeviation))) {
        showerMap[iauCode] = [showerStart, showerEnd];
      }
    }
    currentShowers = showerMap.keys.toList();
    currentShowers.add("SPO");
  }

  static List<String> _selectedShowers = ["SPO"];
  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    //final List<String> showers = await getShowers();
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: currentShowers);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedShowers = results;
      });
    }
  }

  bool firstWrite = true;
  int perTime = 15;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

//form controllers
  final meteorForm = TextEditingController();
  List<TextEditingController> observerControllers = [];
  List<TextEditingController> fovControllers = [];
  List<TextEditingController> obstructionControllers = [];
  List<TextEditingController> triangleControllers = [];
  List<TextEditingController> starControllers = [];

  bool readCsv = true;
  int mag = 0;
  late Map<int, Map<int, double>> fields = {};

//chart reading
  Future<String> read(int index) async {
    String text = await rootBundle.loadString('data/t$index.csv');
    return text;
  }

  Future<void> readCharts() async {
    readCsv = false;
    for (int i = 0; i < 3; i++) {
      String csv = await read(i + 1);
      bool first = true;
      List<String> csvList = csv.split("\n");
      csvList.removeAt(0);
      for (int j = 0; j < csvList.length; j++) {
        int ct = 0;
        List<String> line = csvList[j].split(";");
        for (int k = 0; k < line.length; k++) {
          ct += 1;
          String el = line[k];
          if (el == "") {
            continue;
          } else if (ct % 2 != 0) {
            mag = int.parse(el);
            if (first) {
              fields.putIfAbsent(((ct + 1) / 2).round() + i * 10, () => {});
            }
          } else {
            String a = el[0];
            String b = el.substring(1);
            try {
              fields[(ct / 2).round() + i * 10]?[mag] = double.parse("$a.$b");
            } catch (e) {
              continue;
            }
          }
        }
      }
      if (first) {
        first = false;
      }
    }
  }

  Map<String, Map<String, List<int>>> session = {};
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

  late Timer timer;
  int elapsedTimeInSeconds = 0;
  bool isTimerRunning = false;

  int obsNum = 0;
  bool table1 = false;
  bool table2 = false;
  String sessionButton = "Start session";

  var isChecked = false;
  bool edit = true;

  late DateTime startNow;
  late String date;
  late String startTime;
  late double fovRa;
  late double fovDe;
  late double obstr;
  late double limMag;
  late String observerName;

  //timer functions
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTimeInSeconds++;
        if (elapsedTimeInSeconds % (perTime * 60) == 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              '$perTime minutes have passed. Consider starting a new session.',
              style: redNormal,
            ),
            backgroundColor: lightGrey,
          ));
        }
      });
    });
    setState(() {
      isTimerRunning = true;
    });
  }

  void stopTimer() {
    timer.cancel();
    setState(() {
      isTimerRunning = false;
      elapsedTimeInSeconds = 0;
    });
  }

  String formatElapsedTime(int seconds) {
    Duration duration = Duration(seconds: seconds);
    return DateFormat('H:mm:ss').format(DateTime(
        0, 0, 0, 0, duration.inMinutes, duration.inSeconds.remainder(60)));
  }

  static const Duration snackbarDuration = Duration(seconds: 3);

  //checkbox styling
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return lightGrey;
    }
    return Color(0xff1f1f1f);
  }

  List<String> showerList = [];
  List<String> observers = [];
  List<bool> checks = [];
  String dropdownValue = '';

  //generating observer numbers
  Text create(int num) {
    return Text(num.toString(), style: redNormal);
  }

  String filename = "";
  @override
  void dispose() {
    timer.cancel();
    meteorForm.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }

  @override
  Widget build(BuildContext context) {
    if (readCsv) {
      readCharts();
      getShowers();
    }

    List<TableRow> tableRows = [
      TableRow(
        children: <Widget>[
          Cell("Obs. num"),
          Cell("Obs. name"),
          Cell("RA,DEC in °"),
          Cell("Obstr. %"),
          Cell("Triangle"),
          Cell("Num of stars"),
        ],
      ),
    ];

    List<Widget> meteor1 = [];
    List<Widget> meteor2 = [];
    for (int i = 0; i < obsNum; i++) {
      meteor1.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Text("${i + 1}", style: redNormal),
        ),
      ));

      meteor2.add(Center(
        child: Checkbox(
            fillColor: MaterialStateProperty.resolveWith(getColor),
            checkColor: red,
            value: checks[i],
            onChanged: (bool? value) {
              setState(() {
                //print(value);
                if (obsNum == 1) {
                  checks[i] = true;
                } else if (!value!) {
                  checks[i] = false;
                } else {
                  checks[i] = true;
                }
                //print(checks);
              });
            }),
      ));
    }

    meteor1.addAll([
      CenteredCell("Radiant"),
      CenteredCell("Brightness (mag.)"),
    ]);

    meteor2.addAll([
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(
            Icons.arrow_drop_down_outlined,
            color: red,
          ),
          elevation: 16,
          style: const TextStyle(color: red, fontSize: 16),
          underline: Container(
            height: 2,
            color: red,
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
            });
          },
          items: showerList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      TextForm(
        round: 0.0,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        //format: [FilteringTextInputFormatter.digitsOnly],
        scrollPadding: EdgeInsets.all(-200.0),
        controller: meteorForm,
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter magnitude';
          } else if (int.tryParse(value) == null) {
            return 'Input number';
          } else if (-6 > int.parse(value) || int.parse(value) > 7) {
            return 'Enter magnitude between -6 and 7';
          }
          setState(() {});
          return null;
        },
      ),
    ]);

    for (int i = 0; i < obsNum; i++) {
      observerControllers.add(TextEditingController());
      fovControllers.add(TextEditingController());
      obstructionControllers.add(TextEditingController());
      triangleControllers.add(TextEditingController());
      starControllers.add(TextEditingController());

      tableRows.add(
        TableRow(
          children: <Widget>[
            Center(
              child: create(i + 1),
            ),
            TextForm(
              scrollPadding: EdgeInsets.all(-150.0),
              round: 0.0,
              controller: observerControllers[i],
              enabled: edit,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a name';
                } else if (value.length > 10) {
                  return 'Max 10 letters';
                }
                return null;
              },
              keyboardType: TextInputType.name,
            ),
            TextForm(
              scrollPadding: const EdgeInsets.all(-150.0),
              round: 0.0,
              controller: fovControllers[i],
              enabled: edit,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter an FOV';
                } else if (value.split(',').length != 2) {
                  return 'Follow input rules';
                } else if (double.tryParse(value.split(',')[0]) != null &&
                        double.tryParse(value.split(',')[1]) != null &&
                        double.parse(value.split(',')[0]) > 360 ||
                    double.parse(value.split(',')[0]) < 0 ||
                    double.parse(value.split(',')[1]) > 90 ||
                    double.parse(value.split(',')[1]) < -90) {
                  return 'Enter valid coordinates';
                }
                return null;
              },
              keyboardType: TextInputType.text,
            ),
            TextForm(
              scrollPadding: EdgeInsets.all(-150.0),
              controller: obstructionControllers[i],
              enabled: edit,
              round: 0.0,
              keyboardType: TextInputType.number,
              format: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter obstruction';
                } else if (int.parse(value) > 100 || int.parse(value) < 0) {
                  return '0-100 range';
                }
                return null;
              },
            ),
            TextForm(
              scrollPadding: EdgeInsets.all(-150.0),
              controller: triangleControllers[i],
              enabled: edit,
              keyboardType: TextInputType.number,
              format: [FilteringTextInputFormatter.digitsOnly],
              round: 0.0,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter triangle number';
                } else if (int.parse(value) > 30 || int.parse(value) < 1) {
                  return 'Triangles are 1-30';
                }
                return null;
              },
            ),
            TextForm(
              scrollPadding: EdgeInsets.all(-150.0),
              round: 0.0,
              controller: starControllers[i],
              enabled: edit,
              keyboardType: TextInputType.number,
              format: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter number of stars';
                }
                return null;
              },
            ),
          ],
        ),
      );
    }
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 175,
                child: TextForm(
                  text: 'Number of observers',
                  enabled: edit,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  format: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a number';
                    } else if (int.parse(value) > 5 || int.parse(value) < 1) {
                      return '1-5 observers allowed';
                    }
                    setState(() {
                      obsNum = int.parse(value);
                      checks = [];
                      for (int i = 0; i < obsNum; i++) {
                        if (obsNum == 1) {
                          checks.add(true);
                        } else {
                          checks.add(false);
                        }
                      }
                    });
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 30),
              SizedBox(
                width: 175,
                child: TextForm(
                  init: '15',
                  enabled: edit,
                  autofocus: false,
                  text: 'Period duration (in minutes)',
                  keyboardType: TextInputType.number,
                  format: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter desired period';
                    }
                    perTime = int.parse(value);
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightGrey, // Background color
                  foregroundColor: red, // Text Color (Foreground color)
                ),
                onPressed: _showMultiSelect,
                child: const Text('Meteor Showers'),
              ),
              Wrap(
                direction: Axis.horizontal,
                spacing: 4,
                children: _selectedShowers
                    .map((e) => Chip(
                          backgroundColor: lightGrey,
                          label: Text(
                            e,
                            style: const TextStyle(color: red),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightGrey, // Background color
                  foregroundColor: red, // Text Color (Foreground color)
                ),
                onPressed: () {
                  if (_selectedShowers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          duration: snackbarDuration,
                          backgroundColor: lightGrey,
                          content: Text(
                            "Select at least one meteor shower",
                            style: redNormal,
                          )),
                    );
                  }
                  // Validate returns true if the form is valid, or false otherwise.
                  else if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      table1 = true;
                    });
                    //print(showerList);
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: const Text(
                  'Next',
                )),
          ),
          Padding(padding: const EdgeInsets.all(10.0)),
          Form(
            key: _formKey2,
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Visibility(
                  visible: table1,
                  child: Table(
                    border: TableBorder.all(color: red, width: 1.5),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: tableRows,
                  ),
                )),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: table1,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightGrey, // Background color
                      foregroundColor: red, // Text Color (Foreground color)
                    ),
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey2.currentState!.validate()) {
                        _formKey2.currentState!.save();
                        if (sessionButton == "Start session") {
                          sessionButton = "End session";
                          showerList = _selectedShowers;
                          dropdownValue = showerList.first;
                          if (firstWrite) {
                            for (int i = 0; i < showerList.length; i++) {
                              csvData[0].add(showerList[i]);
                              csvData[0].add('');
                            }
                          }

                          startTimer();
                          setState(() {
                            table2 = true;
                            edit = false;
                          });

                          startNow = DateTime.now().toUtc();
                          String month = DateFormat.MMM().format(startNow);
                          String day = DateFormat('dd').format(startNow);
                          String year = DateFormat('yyyy').format(startNow);
                          date = "$month $day $year";
                          String hours = DateFormat('HH').format(startNow);
                          String minutes = DateFormat('mm').format(startNow);
                          startTime = "$hours$minutes";

                          for (int i = 0; i < obsNum; i++) {
                            observerName = observerControllers[i].text;
                            observers.add(observerName);
                            limMag =
                                fields[int.parse(triangleControllers[i].text)]![
                                        int.parse(starControllers[i].text)]
                                    as double;
                            obstr = 1 /
                                (1 -
                                    int.parse(obstructionControllers[i].text) /
                                        100);
                            fovRa = double.parse(
                                fovControllers[i].text.split(",")[0]);
                            fovDe = double.parse(
                                fovControllers[i].text.split(",")[1]);

                            session[observerName] = {};
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                duration: snackbarDuration,
                                backgroundColor: lightGrey,
                                content: Text(
                                  'Session started!',
                                  style: redNormal,
                                )),
                          );
                        } else {
                          sessionButton = "Start session";
                          stopTimer();
                          setState(() {
                            table2 = false;
                            edit = true;
                          });

                          final now = DateTime.now().toUtc();
                          String hours = DateFormat('HH').format(now);
                          String minutes = DateFormat('mm').format(now);
                          String endTime = "$hours$minutes";
                          Duration difference = now.difference(startNow);
                          double teff = difference.inMinutes / 60.0;
                          String month = DateFormat('MM').format(startNow);
                          String month2 = DateFormat('MMM').format(startNow);
                          String day = DateFormat('dd').format(startNow);
                          String year = DateFormat('yyyy').format(startNow);
                          date = "$month2 $day $year";
                          hours = DateFormat('HH').format(startNow);
                          minutes = DateFormat('mm').format(startNow);
                          if (firstWrite) {
                            filename = year + month + day + hours + minutes;
                          }
                          for (final observer in observers) {
                            print(observers);
                            List<String> sessionData = [
                              date,
                              startTime,
                              endTime,
                              teff.toString(),
                              fovRa.toString(),
                              fovDe.toString(),
                              obstr.toString(),
                              limMag.toString(),
                            ];

                            for (final shower in showerList) {
                              sessionData.add('C');
                              int counter = 0;
                              if (session[observer]![shower] == null) {
                                session[observer]![shower] =
                                    List<int>.generate(14, (int index) => 0);
                              }
                              // number of spotted meteors per shower
                              for (final num in session[observer]![shower]!) {
                                counter += num;
                              }
                              sessionData.add(counter.toString());

                              List<String> showerData = [
                                date,
                                startTime,
                                endTime,
                                shower
                              ];
                              for (final meteoNum
                                  in session[observer]![shower]!) {
                                if (meteoNum == 0) {
                                  showerData.add('');
                                } else {
                                  showerData.add(meteoNum.toString());
                                }
                              }
                              csvData2.add(showerData);
                            }
                            csvData.add(sessionData);
                            String csv =
                                const ListToCsvConverter().convert(csvData);
                            String csv2 =
                                const ListToCsvConverter().convert(csvData2);
                            print(csv);
                            print(csv2);
                            Future<File> writeCounter(
                                String observer, int a) async {
                              //String path = await dir();
                              String path =
                                  "/storage/emulated/0/Download/MeteorLog";
                              final myDir = Directory(path);
                              var isThere = await myDir.exists();
                              if (!isThere) {
                                await myDir.create(recursive: true);
                                //print('Directory created');
                              }

                              if (a == 1) {
                                //print("first batch: $csvData");
                                File f = File(
                                    "$path/${filename}_${observer}_count.csv");
                                return f.writeAsString(csv);
                                //mode: FileMode.append);
                              } else {
                                //print("second batch: $csvData2");
                                File f = File(
                                    "$path/${filename}_${observer}_mag.csv");
                                return f.writeAsString(csv2);
                                //mode: FileMode.append);
                              }
                            }

                            writeCounter(observer, 1);
                            writeCounter(observer, 2);
                          }
                          /*if (firstWrite) {
                            csvData = [
                              [
                                "DATE UT",
                                "START",
                                "END",
                                "Teff",
                                "RA",
                                "Dec",
                                "F",
                                "Lm"
                              ]
                            ];
                            csvData2 = [
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
                          }*/
                          //csvData = [];
                          //csvData2 = [];
                          observers = [];
                          firstWrite = false;
                          session = {};
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 5),
                            content: const Text(
                              'Session ended!',
                              style: redNormal,
                            ),
                            action: SnackBarAction(
                              label: 'PUBLISH',
                              textColor: red,
                              onPressed: _launchUrl,
                            ),
                            backgroundColor: lightGrey,
                          ));
                        }
                      }
                    },
                    child: Text(
                      sessionButton,
                    )),
              ),
              const SizedBox(width: 20),
              Visibility(
                visible: table2,
                child: Text(
                  formatElapsedTime(elapsedTimeInSeconds),
                  style: redNormal,
                ),
              )
            ],
          ),
          const SizedBox(height: 35),
          Visibility(
              visible: table2,
              child: Form(
                key: _formKey3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Table(
                    border: TableBorder.all(color: red, width: 1.5),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: meteor1),
                      TableRow(children: meteor2),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 15),
          Visibility(
            visible: table2,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightGrey,
                  foregroundColor: red,
                ),
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.

                  if (_formKey3.currentState!.validate() &&
                      checks.any((element) => element == true)) {
                    _formKey3.currentState!.save();
                    String radiant = dropdownValue;
                    for (int i = 0; i < checks.length; i++) {
                      if (checks[i]) {
                        List<int> emptyMags = List<int>.filled(14, 0);
                        session[observers[i]]
                            ?.putIfAbsent(radiant, () => emptyMags);

                        session[observers[i]]?[radiant]
                            ?[int.parse(meteorForm.text) + 6] += 1;
                      }
                    }
                    if (obsNum != 1) {
                      checks.fillRange(0, checks.length, false);
                    }

                    meteorForm.clear();
                    /*if (showerList.length != 1) {
                      dropdownValue = showerList.first;
                    }*/
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          duration: snackbarDuration,
                          backgroundColor: lightGrey,
                          content: Text(
                            "Submitted!",
                            style: redNormal,
                          )),
                    );
                  } else if (checks.every((element) => element == false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          duration: snackbarDuration,
                          backgroundColor: lightGrey,
                          content: Text(
                            "Check at least one observer",
                            style: redNormal,
                          )),
                    );
                  }
                },
                child: const Text(
                  "Submit",
                )),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
