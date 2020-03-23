import 'dart:convert';
import 'package:coronavirus_test/app_language.dart';
import 'package:coronavirus_test/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:coronavirus_test/scene/ques.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'helpline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ques.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/news.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<News> news = new List<News>();
  bool isLoggedIn = false;
  bool isLoading = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var _impLinks = [];
  var _tips = [];
  String langCode;
  var appLanguage;
  bool loadingP1 = true;
  bool loadingP2 = true;
  String feedbackText = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    appLanguage = Provider.of<AppLanguage>(context);
    return (Scaffold(
        appBar: AppBar(
            leading: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Image(
                  image: AssetImage("assets/logo.png"),
                  height: 150.0,
                )),
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context).translate("app_title"),
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            bottomOpacity: 0.0,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.drag_handle,
                    size: 35,
                    color: Color.fromRGBO(82, 151, 93, 1),
                  ),
                  onPressed: () {
                    showMenu(context);
                  }),
            ]),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : new SingleChildScrollView(
                child:
                    Column(children: <Widget>[_tipsAndHelp(), _latestNews()])),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
          height: 50,
          child: RaisedButton(
              splashColor: Colors.white70,
              color: Color.fromRGBO(82, 151, 93, 1),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QuesScreen()));
              },
              elevation: 2.0,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('start_screen_btn_label'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )),
        )));
  }

  _loadData() async {
    var prefs = await SharedPreferences.getInstance();

    Firestore.instance
        .collection('appData')
        .document('impLinks')
        .get()
        .then((value) => this.setState(() {
              print(jsonEncode(value['data']));
              _impLinks = value['data'];
              loadingP2 = false;
            }));

    Firestore.instance
        .collection('appData')
        .document('tips')
        .get()
        .then((value) => this.setState(() {
              _tips = value['data'];
              loadingP1 = false;
            }));

    this.setState(() {
      langCode = prefs.getString('language_code');
    });
  }

  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  _tipsAndHelp() {
    return (Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Column(children: [
          Text(
            AppLocalizations.of(context).translate('protective_measure_key'),
            style: TextStyle(fontSize: 18),
          ),
          Divider()
        ]),
      ),
      loadingP1
          ? CircularProgressIndicator()
          : new Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                  children: _tips.map<Widget>((item) {
                return new Card(
                    elevation: 3,
                    child: Wrap(children: <Widget>[
                      ListTile(
                        title: Text(item['title-$langCode']),
                        subtitle: Text(item['subtitle-$langCode']),
                      )
                    ]));
              }).toList()))
    ])));
  }

  _latestNews() {
    return (Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Column(children: [
          Text(
            AppLocalizations.of(context).translate('important_links_key'),
            style: TextStyle(fontSize: 18),
          ),
          Divider()
        ]),
      ),
      loadingP2
          ? CircularProgressIndicator()
          : new Container(
              height: 300,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                        onTap: () {
                          _launchURL(_impLinks[index]['url']);
                        },
                        child: new Material(
                            child: new Card(
                                elevation: 3,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                        child: Image.network(
                                            _impLinks[index]['image'],
                                            // width: 300,
                                            height: 150,
                                            fit: BoxFit.fitWidth),
                                      ),
                                      ListTile(
                                        title: Text(_impLinks[index]
                                            ['title-$langCode']),
                                        subtitle: Text(_impLinks[index]
                                            ['subtitle-$langCode']),
                                      )
                                    ]))));
                  },
                  itemCount: _impLinks.length,
                  itemHeight: 500,
                  viewportFraction: 0.7,
                  itemWidth: 300.0,
                  scale: 0.9,
                  loop: false),
            )
    ])));
  }

  showMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Container(),
                new ListTile(
                    leading: new Icon(Icons.phone_in_talk),
                    title: new Text(AppLocalizations.of(context)
                        .translate('helpline_numbers_key')),
                    onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HelplineScreen()))
                        }),
                Divider(),
                new ListTile(
                  leading: new Icon(Icons.language),
                  title: new Text(AppLocalizations.of(context)
                          .translate('change_language_key') +
                      ' - $langCode'),
                  onTap: () => {showLangChange()},
                ),
                new ListTile(
                  leading: new Icon(Icons.contact_phone),
                  title: new Text(
                      AppLocalizations.of(context).translate('contact_us_key')),
                  onTap: () => {launchURI("https://covid.kidaura.in/contact")},
                ),
                new ListTile(
                  leading: new Icon(Icons.feedback),
                  title: new Text(
                      AppLocalizations.of(context).translate('feedback_key')),
                  onTap: () => {showFeedbackDialog()},
                ),
                Divider(),
                new ListTile(
                  leading: new Icon(Icons.description),
                  title: new Text(AppLocalizations.of(context)
                      .translate('privacy_policy_key')),
                  onTap: () => {launchURI("https://covid.kidaura.in/privacy")},
                )
              ],
            ),
          );
        });
  }

  showFeedbackDialog() {
    showDialog(
        context: context,
        child: new SimpleDialog(
            title: new Text(
                AppLocalizations.of(context).translate('feedback_key')),
            contentPadding: EdgeInsets.all(10),
            children: [
              new Container(
                child: Container(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              child: TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 8,
                            onChanged: (value) {
                              this.setState(() {
                                feedbackText = value;
                              });
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                enabled: true),
                          )),
                          Container(
                            height: 50.0,
                            width: 80.0,
                            child: FittedBox(
                              child: RaisedButton(
                                color: Colors.green,
                                onPressed: () {
                                  sendFeedback();
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ])),
              )
            ]));
  }

  sendFeedback() async {
    var user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('feedback')
        .document()
        .setData({'uid': user.uid, 'feedback': feedbackText});

    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('thank_you_label'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1);
    Navigator.of(context, rootNavigator: true).pop();
  }

  launchURI(String uri) async {
    if (await canLaunch(uri)) {
      await launch(uri, forceWebView: true, enableJavaScript: true);
    } else {
      throw 'Could not launch $uri';
    }
  }

  showLangChange() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                AppLocalizations.of(context).translate('change_language_key')),
            content: langAlertContainer(),
          );
        });
  }

  Widget langAlertContainer() {
    return Container(
      height: 250,
      width: 200,
      child: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                appLanguage
                    .changeLanguage(Locale(languages.keys.toList()[index]));
                _loadData();
              },
              child: ListTile(
                title: Text(languages.values.toList()[index]),
              ));
        },
      ),
    );
  }
}
