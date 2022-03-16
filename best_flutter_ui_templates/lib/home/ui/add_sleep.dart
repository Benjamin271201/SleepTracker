import 'package:best_flutter_ui_templates/model/moodSleep.dart';
import 'package:best_flutter_ui_templates/service/HttpService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../model/user.dart';
import '../home_screen.dart';

class AddSleep extends StatefulWidget {
  final User user;

  AddSleep({required User user}) : this.user = user;

  @override
  State<AddSleep> createState() => _AddSleepState(user);
}

class _AddSleepState extends State<AddSleep> {
  final User user;
  TextEditingController startTimeInput = TextEditingController();
  TextEditingController endTimeInput = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  bool _isInAsyncCall = true;
  var dropdown;
  List moodList = [];

  _AddSleepState(this.user);

  @override
  void initState() {
    startTimeInput.text = "";
    endTimeInput.text = "";
    dateInput.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getMoodList();
    super.initState();
  }

  getMoodList() async {
    List res = await HttpService().getMoodList();
    if (res.isNotEmpty) {
      setState(() {
        moodList = res;
        _isInAsyncCall = false;
        print(moodList);
      });
    }
  }

  void addSleep() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    // start the modal progress HUD
    setState(() {
      _isInAsyncCall = true;
    });
    bool res = await HttpService().AddSleep(startTimeInput.text,
        endTimeInput.text, dateInput.text, description.text, user.id, dropdown);
    if (res) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success!"),
            content: Text("Add sleep detail success!"),
            actions: <Widget>[
              new TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
                },
              ),
            ],
          );
        },
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 60.0, bottom: 8.0),
                  child: Text(
                    "Sleep Detail",
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller:
                        startTimeInput, //editing controller of this TextField
                    decoration: InputDecoration(
                        icon: Icon(Icons.timer), //icon of text field
                        labelText: "Sleep time", //label text of field
                        labelStyle: TextStyle(fontSize: 20)),
                    readOnly:
                        true, //set it true, so that user will not able to edit text
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        initialTime: TimeOfDay.now(),
                        context: context,
                      );
                      if (pickedTime != null) {
                        print(pickedTime.format(context)); //output 10:51 PM
                        DateTime parsedTime = DateFormat.jm()
                            .parse(pickedTime.format(context).toString());
                        //converting to DateTime so that we can further format on different pattern.
                        String formattedTime =
                            DateFormat('HH:mm:ss').format(parsedTime);
                        setState(() {
                          startTimeInput.text =
                              formattedTime; //set the value of text field.
                        });
                      }
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller:
                        endTimeInput, //editing controller of this TextField
                    decoration: InputDecoration(
                        icon: Icon(Icons.timer), //icon of text field
                        labelText: "Wakeup time", //label text of field
                        labelStyle: TextStyle(fontSize: 20)),
                    readOnly:
                        true, //set it true, so that user will not able to edit text
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        initialTime: TimeOfDay.now(),
                        context: context,
                      );
                      if (pickedTime != null) {
                        print(pickedTime.format(context)); //output 10:51 PM
                        DateTime parsedTime = DateFormat.jm()
                            .parse(pickedTime.format(context).toString());
                        //converting to DateTime so that we can further format on different pattern.
                        String formattedTime =
                            DateFormat('HH:mm:ss').format(parsedTime);
                        setState(() {
                          endTimeInput.text =
                              formattedTime; //set the value of text field.
                        });
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  height: 150,
                  child: Center(
                    child: TextField(
                      controller:
                          dateInput, //editing controller of this TextField
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Sleep Date",
                          labelStyle:
                              TextStyle(fontSize: 20) //label text of field
                          ),
                      readOnly:
                          true, //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(
                                2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            dateInput.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print(dateInput.text);
                        }
                      },
                    ),
                  ),
                ),
                Text(
                  "What is your mood after waking up ?",
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(10),
                  child: DropdownButton(
                      isExpanded: true,
                      iconSize: 30,
                      icon: Icon(Icons.face),
                      value: dropdown,
                      items: moodList.map((value) {
                        return DropdownMenuItem(
                          value: value.id,
                          child: Text(
                            value.moodName,
                            style: TextStyle(
                                fontSize: 20, fontStyle: FontStyle.italic),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          this.dropdown = value;
                          print(this.dropdown);
                        });
                      },
                      hint: Text("Select item")),
                ),
                Container(
                  margin: EdgeInsets.all(12),
                  height: 6 * 24.0,
                  child: TextField(
                    controller: description,
                    maxLines: 6,
                    decoration: InputDecoration(
                        icon: Icon(Icons.abc),
                        labelText: "What did you dream about",
                        labelStyle: TextStyle(fontSize: 20)),
                  ),
                ),
                Container(
                  height: 50,
                  width: 250,
                  padding: EdgeInsets.only(
                    left: 30.0,
                    right: 20.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color(0xff132137),
                  ),
                  child: InkWell(
                    onTap: addSleep,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
