import 'package:coronavirus_test/scene/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../localization.dart';
import '../app_language.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class StartScreen extends StatefulWidget {
  StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  SwiperController _swipeController = new SwiperController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        body: SafeArea(
            child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(children: [
                  Image(
                    image: AssetImage("assets/logo.png"),
                    height: 150.0,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "COVID19 - India",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 40),
                  Expanded(
                      child: Swiper(
                    controller: _swipeController,
                    itemBuilder: (context, position) {
                      return startPages(position);
                    },
                    itemCount: 5,
                    loop: false,
                    physics: NeverScrollableScrollPhysics(),
                    pagination: new SwiperPagination(),
                  ))
                ])))));
  }

  startPages(int position) {
    switch (position) {
      case 0:
        {
          return languageWidget();
        }
        break;
      case 1:
        {
          return reportSymptomInfo();
        }
        break;
      case 2:
        {
          return hygieneNudges();
        }
        break;
      case 3:
        {
          return contactTracking();
        }
        break;
      case 4:
        {
          return privacy();
        }
        break;
    }
  }

  reportSymptomInfo() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Stack(children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "2",
              mini: true,
              child: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _swipeController.next();
              },
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                Text("Report Symptoms",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "By tracking, and self reporting the symptoms, the spread of infection can be monitored and slowed down",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ))
              ])),
          Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/report.png'),
              )),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "1",
              onPressed: () {
                _swipeController.previous();
              },
              mini: true,
              child: Icon(Icons.arrow_back_ios),
            ),
          )
        ]));
  }

  hygieneNudges() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Stack(children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "1",
              mini: true,
              child: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _swipeController.next();
              },
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                Text("Hygeine Nudges",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "Get frequent Hygiene Notification, when you move from one place to another or at regular intervals",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ))
              ])),
          Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/handwash.png'),
              )),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "2",
              onPressed: () {
                _swipeController.previous();
              },
              mini: true,
              child: Icon(Icons.arrow_back_ios),
            ),
          )
        ]));
  }

  privacy() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Stack(children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "1",
              mini: true,
              child: Icon(Icons.check),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                Text("Privacy",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "The App records data locally, and takes cosent before uploading any information",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ))
              ])),
          Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/privacy.png'),
              )),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "2",
              onPressed: () {
                _swipeController.previous();
              },
              mini: true,
              child: Icon(Icons.arrow_back_ios),
            ),
          )
        ]));
  }

  contactTracking() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Stack(children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "1",
              mini: true,
              child: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _swipeController.next();
              },
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                Text("Contact Tracking",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "App records your location and alerts you if you have crossed paths with possible infected zones",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ))
              ])),
          Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/heart.png'),
              )),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "2",
              onPressed: () {
                _swipeController.previous();
              },
              mini: true,
              child: Icon(Icons.arrow_back_ios),
            ),
          )
        ]));
  }

  languageWidget() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Align(
            alignment: Alignment.center,
            child: Column(children: <Widget>[
              Text(
                "Select Language",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              Column(
                  children: languages.keys
                      .map<Widget>((e) => (RaisedButton(
                          color: Colors.green,
                          onPressed: () {
                            _swipeController.next();
                            AppLanguage().changeLanguage(Locale(e));
                          },
                          child: Text(
                            languages[e],
                            style: TextStyle(color: Colors.white),
                          ))))
                      .toList()),
            ])));
  }
}
