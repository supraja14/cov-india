import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({Key key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}


class _ResultScreenState extends State {
  bool isLoggedIn = false;
  bool isLoading = true;
  PageController controller = PageController(viewportFraction: 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(
            "COVID-19 Screening Test",
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          bottomOpacity: 0.0,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Text("Result"),
              Card(
                  elevation: 4,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 20.0),
                      child: SizedBox(
                          width: double.infinity, child: Text("hello world"))))
            ],
          ),
        )));
  }
}
