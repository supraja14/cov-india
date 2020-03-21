import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../localization.dart';

class Questions {
  final String ques;
  var options;
  String answer;

  Questions({this.ques, this.options});

  factory Questions.fromJson(Map<String, dynamic> parsedJson) {
    return Questions(
        ques: parsedJson['ques'],
        options: new List<String>.from(parsedJson['options']));
  }
}

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

  @override
  void initState() {
    super.initState();
    _loadQA();
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
                "COVID-19 Screening Test",
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
                              msg: 'Please answer the question to continue.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white);
                          return;
                        }
                      }
                      if (controller.page.toInt() == this.pagesCount - 1) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResultScreen()));
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
                    onTap: () => _setAnswer(
                        index, questions[index]['A-$langCode'].indexOf(item)),
                    child: Card(
                        color: isOptionAnswered(index,
                                questions[index]['A-$langCode'].indexOf(item))
                            ? Color.fromRGBO(82, 151, 93, 0.7)
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

  setCheckboxAnswer(bool selected, int index, String item) {
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
        } else {
          answers[index]['answer'].remove(item);
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
}
