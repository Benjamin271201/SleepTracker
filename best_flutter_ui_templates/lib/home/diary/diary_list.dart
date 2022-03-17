import 'package:best_flutter_ui_templates/home/diary/sleep.dart';
import 'package:best_flutter_ui_templates/home/diary/sleep_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/HttpService.dart';
import '../home_theme.dart';

class DiaryList extends StatefulWidget {
  const DiaryList({Key? key}) : super(key: key);

  @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList> {
  List<Sleep>? listSleep;
  String? username;
  int month = 3, year = 2022, userId = 6;
  var isLoaded = false;
  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  DateTime selectedDate = DateTime.now();
  TextEditingController dateinput = TextEditingController();

  @override
  void initState() {
    dateinput.text = DateFormat('yyyy-MM').format(DateTime.now());
    setSelectedMonth(int.parse(dateinput.text.split("-")[1]));
    setSelectedYear(int.parse(dateinput.text.split("-")[0]));
    getUser();
    getDiary();
    super.initState();
  }

  setSelectedMonth(int month) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("month", month);
  }

  setSelectedYear(int year) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("year", year);
  }

  Future<bool> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("id")!;
      username = prefs.getString("username");
    });
    return true;
  }

  Future<bool> getDiary() async {
    if (await getUser()) {
      listSleep = await HttpService().getSleepDiaryByMonth(userId, month, year);
      if (listSleep != null && mounted)
        setState(() {
          isLoaded = true;
        });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getDiary(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!isLoaded) {
          return Center(
              child: Text(
            "Loading",
            style: TextStyle(fontSize: 30),
          ));
        } else {
          return Column(children: <Widget>[
            SizedBox(
                height: 20,
                child: InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showMonthPicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(
                            2000), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101),
                        locale: null,
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM').format(pickedDate);
                        setState(() {
                          dateinput.text = formattedDate;
                          selectedDate = pickedDate;
                          year = int.parse(formattedDate.split("-")[0]);
                          month = int.parse(formattedDate.split("-")[1]);
                        });
                        getDiary();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.calendar_today,
                                color: HomeTheme.grey,
                                size: 18,
                              )),
                          Text(
                            dateinput.text,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: HomeTheme.fontName,
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              letterSpacing: -0.2,
                              color: HomeTheme.darkerText,
                            ),
                          ),
                        ],
                      ),
                    ))),
            SizedBox(
                height: 500,
                width: double.infinity,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: listSleep!.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    final item = listSleep![index];
                    return InkWell(
                        onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SleepDetail(
                                          sleep: listSleep![index])))
                            },
                        child: Card(
                            color: Colors.white,
                            child: Row(children: <Widget>[
                              Expanded(
                                  child: ListTile(
                                      title: Text(formatter
                                          .format(item.sleepDate)
                                          .toString()))),
                              SizedBox(
                                width: 100,
                                child: ListTile(
                                  title: Text("Mood: " + item.mood.toString()),
                                  textColor: Colors.red,
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: ListTile(
                                    title: Text("Duration: " +
                                        convertToHours(item.sleepDuration)),
                                    textColor: Colors.green),
                              ),
                              InkWell(
                                  onTap: () => removeSleep(item.id),
                                  child: SizedBox(
                                      child: Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  )))
                            ])));
                  },
                ))
          ]);
        }
      },
    );
  }

  String convertToHours(int sleepTime) {
    int hours = sleepTime ~/ 60;
    int mins = sleepTime - (hours * 60);
    return hours.toString() + "h" + mins.toString();
  }

  void removeSleep(int sleepId) async {
    bool result = await HttpService().removeSleep(sleepId);
    if (result) getDiary();
  }
}