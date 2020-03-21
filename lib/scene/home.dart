import 'dart:convert';

import 'package:coronavirus_test/scene/ques.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login.dart';
import 'ques.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/news.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<News> news = new List<News>();
  bool isLoggedIn = false;
  bool isLoading = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _fetchNews();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    scheduleNotification();
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

  scheduleNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1', 'Wash Hand Notification', 'Frequent nudging for Hand wash habit',
        importance: Importance.High,
        priority: Priority.High,
        enableVibration: true);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Wash your Hands',
        'It\'s time to wash your hands!!',
        RepeatInterval.Hourly,
        platformChannelSpecifics,
        payload: "noti_hand_wash");
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
            leading: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Image(
                  image: AssetImage("assets/logo.png"),
                  height: 150.0,
                )),
            backgroundColor: Colors.white,
            elevation: 1,
            bottomOpacity: 0.0,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.person,
                    size: 35,
                    color: Color.fromRGBO(82, 151, 93, 1),
                  ),
                  onPressed: () {
                    print("User Clicked");
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
                      'Screen for Corona Virus',
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

  _fetchNews() async {
    final response = await http.get(
        'http://newsapi.org/v2/top-headlines?country=in&q=coronavirus&apiKey=b502d4d26d4941f7a19583e1c0d1aff9');

    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });

      jsonDecode(response.body)['articles']
          .forEach((i) => news.add(News.fromJson(i)));
    } else {
      throw Exception('Failed to load latest news');
    }
  }

  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
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
            "Help and Safety Tips",
            style: TextStyle(fontSize: 18),
          ),
          Divider()
        ]),
      ),
      new Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return new InkWell(
                  onTap: () {
                    _launchURL(news[index].url);
                  },
                  child: new Material(
                      child: new Card(
                          elevation: 3,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                  child: Image.network(news[index].urlToImage,
                                      // width: 300,
                                      height: 150,
                                      fit: BoxFit.fitWidth),
                                ),
                                ListTile(
                                  title: Text(news[index].title),
                                )
                              ]))));
            },
            itemCount: news.length,
            itemHeight: 500,
            viewportFraction: 0.7,
            itemWidth: 300.0,
            scale: 0.9,
            loop: false),
      )
    ])));
  }

  _latestNews() {
    return (Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Column(children: [
          Text(
            "Latest News and Updates",
            style: TextStyle(fontSize: 18),
          ),
          Divider()
        ]),
      ),
      new Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return new InkWell(
                  onTap: () {
                    print("hello");
                    _launchURL(news[index].url);
                  },
                  child: new Material(
                      child: new Card(
                          elevation: 3,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                  child: Image.network(news[index].urlToImage,
                                      // width: 300,
                                      height: 150,
                                      fit: BoxFit.fitWidth),
                                ),
                                ListTile(
                                  title: Text(news[index].title),
                                )
                              ]))));
            },
            itemCount: news.length,
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
            child: !isLoggedIn
                ? Container(
                    height: 100,
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Log In to Continue",
                            style: TextStyle(fontSize: 16),
                          ),
                          RaisedButton(
                              elevation: 2,
                              color: Color.fromRGBO(82, 151, 93, 1),
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()))
                                  },
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )
                                  ]))
                        ]))
                : new Wrap(
                    children: <Widget>[
                      Container(),
                      new ListTile(
                          leading: new Icon(Icons.music_note),
                          title: new Text('Music'),
                          onTap: () => {}),
                      new ListTile(
                        leading: new Icon(Icons.videocam),
                        title: new Text('Video'),
                        onTap: () => {},
                      ),
                    ],
                  ),
          );
        });
  }
}
