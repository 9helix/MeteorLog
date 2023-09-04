import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'MeteorLog';
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
            theme: ThemeData(
              canvasColor: Color(0xff1e1e1e),
              // Define the default brightness and colors.
              scaffoldBackgroundColor: Color(0xff121212),
              primaryColor: Color(0xff121212),

              // Define the default font family.
              fontFamily: 'Open Sans',

              // Define the default `TextTheme`. Use this to specify the default
              // text styling for headlines, titles, bodies of text, and more.
              textTheme: const TextTheme(
                displayLarge:
                    TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                titleLarge:
                    TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Open Sans'),
              ),
            ),
            home: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xff121212),
                  title: const Text(appTitle,
                      style: TextStyle(color: Color(0xFFB71C1C))),
                ),
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [const MyCustomForm()],
                    ),
                  ),
                ))));
  }
}

class MyAppState extends ChangeNotifier {
  void getNext(val) {
    notifyListeners();
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
  Future<String> read(int index) async {
    String text = await rootBundle.loadString('data/t$index.csv');
    return text;
  }

  Future<String> dir() async {
    String out;
    final directory = await getApplicationDocumentsDirectory();
    out = directory.path;
    return out;
  }

  bool firstWrite = true;
  int perTime = 15;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  //final meteorForm1 = TextEditingController();
  final meteorForm2 = TextEditingController();
  final showers = TextEditingController(text: 'SPO,');
  List<TextEditingController> observerControllers = [];
  List<TextEditingController> fovControllers = [];
  List<TextEditingController> obstructionControllers = [];
  List<TextEditingController> triangleControllers = [];
  List<TextEditingController> starControllers = [];
  bool readCsv = true;
  int mag = 0;
  late Map<int, Map<int, double>> fields = {};
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

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTimeInSeconds++;
        if (elapsedTimeInSeconds % (perTime * 60) == 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              '$perTime minutes have passed. Consider starting a new session.',
              style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(
              0xff1e1e1e,
            ),
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

  List<String> showerList = [];
  List<String> observers = [];
  List<bool> checks = [];
  String dropdownValue = '';
  @override
  void dispose() {
    timer.cancel();
    meteorForm2.dispose();
    showers.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }

  @override
  Widget build(BuildContext context) {
    if (readCsv) {
      readCharts();
    }

    List<TableRow> tableRows = [
      TableRow(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("Obs. num",
                style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("Obs. name",
                style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("RA,DEC in °",
                style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("Obstr. %",
                style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("Triangle",
                style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("Num of stars",
                style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ];

    List<Padding> meteor1 = [];
    List<Widget> meteor2 = [];
    for (int i = 0; i < obsNum; i++) {
      meteor1.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Text("${i + 1}",
              style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ));
      Color getColor(Set<MaterialState> states) {
        const Set<MaterialState> interactiveStates = <MaterialState>{
          MaterialState.pressed,
          MaterialState.hovered,
          MaterialState.focused,
        };
        if (states.any(interactiveStates.contains)) {
          return Color(0xff1e1e1e);
        }
        return Color(0xff1f1f1f);
      }

      meteor2.add(Center(
        child: Checkbox(
            fillColor: MaterialStateProperty.resolveWith(getColor),
            checkColor: Color(0xFFB71C1C),
            value: checks[i],
            onChanged: (bool? value) {
              setState(() {
                print(value);
                checks[i] = value! ? obsNum != 1 : value;
                print(checks);
              });
            }),
      ));
    }

    meteor1.addAll([
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Text("Radiant",
              style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Text("Brightness (mag.)",
              style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    ]);

    meteor2.addAll([
      /*TextFormField(
        controller: meteorForm1,
        cursorColor: Color(0xFFB71C1C),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
          ),
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: Color(0xFFB71C1C)),
        ),
        style: TextStyle(color: Color(0xFFB71C1C)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter a radiant';
          } else if (value.length != 3) {
            return 'Exactly 3 letters';
          } else if (!showerList.contains(value)) {
            return 'Enter observed radiant';
          }
          setState(() {
            //obsNum = int.parse(value);
          });
          return null;
        },
      ),*/
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(
            Icons.arrow_drop_down_outlined,
            color: Color(0xFFB71C1C),
          ),
          elevation: 16,
          style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 16),
          underline: Container(
            height: 2,
            color: Color(0xFFB71C1C),
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
      TextFormField(
        scrollPadding: EdgeInsets.all(-800.0),
        controller: meteorForm2,
        cursorColor: Color(0xFFB71C1C),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
          ),
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: Color(0xFFB71C1C)),
        ),
        style: TextStyle(color: Color(0xFFB71C1C)),
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

    Text create(int num) {
      return Text(num.toString(),
          style: TextStyle(
              color: Color(0xFFB71C1C),
              fontSize: 16,
              fontWeight: FontWeight.bold));
    }

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
            TextFormField(
              controller: observerControllers[i],
              enabled: edit,
              cursorColor: Color(0xFFB71C1C),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
              ),
              style: TextStyle(color: Color(0xFFB71C1C)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a name';
                } else if (value.length > 10) {
                  return 'Max 10 letters';
                }
                return null;
              },
            ),
            TextFormField(
              controller: fovControllers[i],
              enabled: edit,
              cursorColor: Color(0xFFB71C1C),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
              ),
              style: TextStyle(color: Color(0xFFB71C1C)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter an FOV';
                } else if (value.split(',').length != 2) {
                  return 'Follow input rules';
                } else if (int.parse(value.split(',')[0]) > 360 ||
                    int.parse(value.split(',')[0]) < 0 ||
                    int.parse(value.split(',')[1]) > 90 ||
                    int.parse(value.split(',')[0]) < -90) {
                  return 'Enter valid coordinates';
                }
                return null;
              },
            ),
            TextFormField(
              controller: obstructionControllers[i],
              enabled: edit,
              cursorColor: Color(0xFFB71C1C),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
              ),
              style: TextStyle(color: Color(0xFFB71C1C)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter obstruction';
                } else if (int.parse(value) > 100 || int.parse(value) < 0) {
                  return '0-100 range';
                }
                return null;
              },
            ),
            TextFormField(
              controller: triangleControllers[i],
              enabled: edit,
              cursorColor: Color(0xFFB71C1C),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
              ),
              style: TextStyle(color: Color(0xFFB71C1C)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter triangle number';
                } else if (int.parse(value) > 30 || int.parse(value) < 1) {
                  return 'Triangles are 1-30';
                }
                return null;
              },
            ),
            TextFormField(
              controller: starControllers[i],
              enabled: edit,
              cursorColor: Color(0xFFB71C1C),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: Color(0xFFB71C1C)),
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
                child: TextFormField(
                  enabled: edit,
                  cursorColor: Color(0xFFB71C1C),
                  autofocus: true,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFB71C1C), width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      // width: 0.0 produces a thin "hairline" border
                      borderSide:
                          BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                    ),
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Color(0xFFB71C1C)),
                    labelText: 'Number of observers',
                  ),
                  style: TextStyle(color: Color(0xFFB71C1C)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              SizedBox(width: 30),
              SizedBox(
                width: 175,
                child: TextFormField(
                  controller: showers,
                  enabled: edit,
                  cursorColor: Color(0xFFB71C1C),
                  autofocus: true,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFB71C1C), width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      // width: 0.0 produces a thin "hairline" border
                      borderSide:
                          BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                    ),
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Color(0xFFB71C1C)),
                    labelText: 'Meteor showers',
                  ),
                  style: TextStyle(color: Color(0xFFB71C1C)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter observed showers';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          SizedBox(
            width: 175,
            child: TextFormField(
              initialValue: '15',
              enabled: edit,
              cursorColor: Color(0xFFB71C1C),
              autofocus: true,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFB71C1C), width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.0),
                ),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFFB71C1C)),
                labelText: 'Period duration (in minutes)',
              ),
              style: TextStyle(color: Color(0xFFB71C1C)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter desired period';
                }
                perTime = int.parse(value);
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff1e1e1e), // Background color
                  foregroundColor:
                      Color(0xFFB71C1C), // Text Color (Foreground color)
                ),
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      table1 = true;
                    });
                    print(showerList);
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
                    border:
                        TableBorder.all(color: Color(0xFFB71C1C), width: 2.0),
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
                      backgroundColor: Color(0xff1e1e1e), // Background color
                      foregroundColor:
                          Color(0xFFB71C1C), // Text Color (Foreground color)
                    ),
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey2.currentState!.validate()) {
                        _formKey2.currentState!.save();
                        if (sessionButton == "Start session") {
                          sessionButton = "End session";
                          String showerTxt = showers.text.trim();
                          if (showerTxt.substring(showers.text.length - 1) ==
                              ',') {
                            showerTxt =
                                showerTxt.substring(0, showerTxt.length - 1);
                          }
                          showerList = showerTxt.split(',');
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
                                duration: Duration(seconds: 3),
                                backgroundColor: Color(
                                  0xff1e1e1e,
                                ),
                                content: Text(
                                  'Session started!',
                                  style: TextStyle(
                                      color: Color(0xFFB71C1C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
                          String day = DateFormat('dd').format(startNow);
                          String year = DateFormat('yyyy').format(startNow);
                          date = "$month $day $year";
                          hours = DateFormat('HH').format(startNow);
                          minutes = DateFormat('mm').format(startNow);
                          String filename =
                              year + month + day + hours + minutes;
                          for (final observer in observers) {
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
                                session[observer]![shower] = [];
                              }
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
                            Future<File> writeCounter(
                                String csv, String observer, int a) async {
                              String path = await dir();
                              path = "/storage/emulated/0/Download/";
                              if (a == 1) {
                                File f = File(
                                    "$path/${filename}_${observer}_count.csv");
                                print(
                                    "$path/${filename}_${observer}_count.csv");
                                return f.writeAsString(csv,
                                    mode: FileMode.append);
                              } else {
                                File f = File(
                                    "$path/${filename}_${observer}_mag.csv");
                                return f.writeAsString(csv2,
                                    mode: FileMode.append);
                              }
                            }

                            writeCounter(csv, observer, 1);
                            writeCounter(csv, observer, 2);
                          }
                          if (firstWrite) {
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
                          }
                          session = {};
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            duration: Duration(seconds: 3),
                            content: Text(
                              'Session ended!',
                              style: TextStyle(
                                  color: Color(0xFFB71C1C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Color(
                              0xff1e1e1e,
                            ),
                          ));
                        }
                      }
                    },
                    child: Text(
                      sessionButton,
                    )),
              ),
              SizedBox(width: 30),
              Visibility(
                visible: table2,
                child: Text(
                  formatElapsedTime(elapsedTimeInSeconds),
                  style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(height: 35),
          Visibility(
              visible: table2,
              child: Form(
                key: _formKey3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Table(
                    border:
                        TableBorder.all(color: Color(0xFFB71C1C), width: 2.0),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: meteor1),
                      TableRow(children: meteor2),
                    ],
                  ),
                ),
              )),
          SizedBox(height: 15),
          Visibility(
            visible: table2,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff1e1e1e), // Background color
                  foregroundColor:
                      Color(0xFFB71C1C), // Text Color (Foreground color)
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
                            ?[int.parse(meteorForm2.text) + 6] += 1;
                      }
                    }
                    if (obsNum != 1) {
                      checks.fillRange(0, checks.length, false);
                    }

                    meteorForm2.clear();
                    if (showerList.length != 1) {
                      dropdownValue = showerList.first;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          duration: const Duration(seconds: 3),
                          backgroundColor: Color(
                            0xff1e1e1e,
                          ),
                          content: Text(
                            "Submitted!",
                            style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                    );
                  } else if (checks.every((element) => element == false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          duration: const Duration(seconds: 3),
                          backgroundColor: Color(
                            0xff1e1e1e,
                          ),
                          content: Text(
                            "Check at least one observer",
                            style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                    );
                  }
                },
                child: Text(
                  "Submit",
                )),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
