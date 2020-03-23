import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuesScreen extends StatefulWidget {
  QuesScreen({Key key}) : super(key: key);

  @override
  _QuesScreenState createState() => _QuesScreenState();
}

class _QuesScreenState extends State {
  List<dynamic> questions = new List<dynamic>();
  List<Map<String, dynamic>> answers = [];
  bool isLoggedIn = false;
  bool isLoading = true;
  int pagesCount;
  String langCode;
  PageController controller = PageController(viewportFraction: 1);
  var userLocation;

  @override
  void initState() {
    super.initState();
    _loadQA();
    _getLocation();
  }

  _getLocation() async {
    Location location = new Location();

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        userLocation = "PERMISSION DENIED";
      }
    }

    bool _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled) {
      var l = await location.getLocation();
      userLocation = {
        'alt': l.altitude,
        'lat': l.latitude,
        'long': l.longitude,
        'speed': l.speed,
        'acc': l.accuracy,
        'heading': l.heading
      };
      print(userLocation);
    } else {
      userLocation = "NOT ENABLED";
    }
  }

  _loadQA() async {
    var prefs = await SharedPreferences.getInstance();
    langCode = prefs.getString('language_code');
    String qaJson = await rootBundle.loadString('assets/qa.json');
    questions = jsonDecode(qaJson);
    setState(() {
      pagesCount = questions.length;
      answers = new List(questions.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title:
                    Text(AppLocalizations.of(context).translate('exit_label')),
                content: Text(
                    AppLocalizations.of(context).translate('exit_ques_label')),
                actions: [
                  FlatButton(
                    child: Text(
                        AppLocalizations.of(context).translate('yes_label')),
                    onPressed: () => Navigator.pop(c, true),
                  ),
                  FlatButton(
                    child: Text(
                        AppLocalizations.of(context).translate('no_label')),
                    onPressed: () => Navigator.pop(c, false),
                  ),
                ],
              ),
            ),
        child: (Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context).translate("app_title"),
                style: TextStyle(color: Colors.black87),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              bottomOpacity: 0.0,
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: new PageView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    controller: controller,
                    itemCount: this.pagesCount,
                    itemBuilder: (_, index) => _quesCard(index))),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                      backgroundColor: Color.fromRGBO(82, 151, 93, 1),
                      heroTag: "prevBtn",
                      onPressed: () {
                        controller.previousPage(
                            duration: kTabScrollDuration, curve: Curves.ease);
                      },
                      child: Icon(Icons.arrow_back_ios)),
                  FloatingActionButton(
                    backgroundColor: Color.fromRGBO(82, 151, 93, 1),
                    heroTag: "nextBtn",
                    onPressed: () {
                      if (answers[controller.page.toInt()] == null) {
                        if (questions[controller.page.toInt()]['type'] !=
                            "Checkbox") {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context).translate('answer_que_label'),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIos: 1);
                          return;
                        }
                        setCheckboxEmpty(controller.page.toInt());
                      }
                      if (controller.page.toInt() == this.pagesCount - 1) {
                        calculateResult();
                      }

                      controller.nextPage(
                          duration: kTabScrollDuration, curve: Curves.ease);
                    },
                    child: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ))));
  }

  _quesCard(int index) {
    return (Container(
        child: Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                    elevation: 4,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 20.0),
                        child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              questions[index]["Q-$langCode"],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )))),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: _answers(index))
              ],
            ))));
  }

  _answers(int index) {
    String type = questions[index]['type'];

    switch (type) {
      case "Options":
        {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: questions[index]["A-$langCode"]
                .map<Widget>((item) => GestureDetector(
                    onTap: () {
                      _setAnswer(
                          index, questions[index]['A-$langCode'].indexOf(item));
                      controller.nextPage(
                          duration: kTabScrollDuration, curve: Curves.ease);
                    },
                    child: Card(
                        color: isOptionAnswered(index,
                                questions[index]['A-$langCode'].indexOf(item))
                            ? Colors.white70
                            : Colors.white,
                        elevation: 4,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 15.0, 15.0, 15.0),
                            child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  item.toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ))))))
                .toList(),
          );
        }
        break;
      case "Checkbox":
        {
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: questions[index]["A-$langCode"]
                  .map<Widget>((item) => Card(
                      color: isOptionAnswered(index,
                              questions[index]['A-$langCode'].indexOf(item))
                          ? Color.fromRGBO(82, 151, 93, 0.7)
                          : Colors.white,
                      elevation: 4,
                      child: SizedBox(
                          width: double.infinity,
                          child: CheckboxListTile(
                            title: Text(
                              item.toString(),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            value: getCheckboxValue(index, item),
                            onChanged: (newValue) {
                              setCheckboxAnswer(newValue, index, item);
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ))))
                  .toList());
        }
        break;
      case 'Phone':
        {
          return Material(
              elevation: 2,
              borderRadius: new BorderRadius.circular(3),
              child: TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  onChanged: (value) {
                    setInput(index, value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    prefixText: "+91",
                    fillColor: Colors.white,
                    labelText: 'Enter Phone Number',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  )));
        }
        break;
      case 'Input':
        {
          return Material(
              elevation: 2,
              borderRadius: new BorderRadius.circular(3),
              child: TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [LengthLimitingTextInputFormatter(2)],
                  onChanged: (value) {
                    setInput(index, value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.people),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  )));
        }
        break;
    }
  }

  isOptionAnswered(int index, int i) {
    if (answers[index] == null) {
      return false;
    } else if (answers[index]['answer'] == i.toString()) {
      return true;
    }
    return false;
  }

  _setAnswer(index, item) {
    print(item);
    setState(() {
      this.answers[index] = {
        'id': questions[index]['id'].toString(),
        'question': questions[index]['Q-en'],
        'answer': item.toString()
      };
    });
  }

  getCheckboxValue(int index, String item) {
    if (answers[index] == null) {
      return false;
    } else if (answers[index]['answer'].contains(item)) {
      return true;
    }
    List<int> d = [1, 24];
    return false;
  }

  setCheckboxEmpty(int index) {
    this.setState(() {
      answers[index] = {
        'id': questions[index]['id'].toString(),
        'question': questions[index]['Q-en'],
        'answer': [],
      };
    });
  }

  setCheckboxAnswer(dynamic selected, int index, dynamic item) {
    if (answers[index] == null) {
      this.setState(() {
        answers[index] = {
          'id': questions[index]['id'].toString(),
          'question': questions[index]['Q-en'],
          'answer': [item],
        };
      });
    } else {
      this.setState(() {
        if (selected) {
          answers[index]['answer'].add(item);
        } else if (!selected) {
          answers[index]['answer'].remove(item);
        } else {
          answers[index]['answer'] = [];
        }
      });
    }
  }

  setInput(int index, String item) {
    setState(() {
      this.answers[index] = {
        'id': questions[index]['id'].toString(),
        'question': questions[index]['Q-en'],
        'answer': item.toString()
      };
    });
  }

  calculateResult() async {
    var isTravel = answers[0]['answer'] == "0";
    var isContacted = answers[0]['answer'] == "0";
    var isSymptoms = answers[4]['answer'].length > 0;
    var isChronic = answers[5]['answer'] == "0";
    var isClinical = answers[3]['answer'] == "0";

    String result = "RISK0";

    if (isSymptoms && (isContacted || isTravel)) {
      result = "RISK3"; // contact doctor and help line number
    } else if (isSymptoms || isTravel || isContacted || isChronic) {
      result = "RISK2"; // maintain 14-day quarantine
    } else if (isClinical) {
      result =
          "RISK1"; // use protective measures & maintain respiratory hygiene
    }
    var user = await FirebaseAuth.instance.currentUser();
    print(user.uid);
    Firestore.instance.collection('questions_test').document().setData({
      'data': answers,
      'uid': user.uid,
      'datetime': DateTime.now().toString(),
      'location': userLocation
    });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(),
          settings: RouteSettings(
            arguments: result,
          ),
        ));
  }
}
