import 'package:flutter/material.dart';
import 'helpline.dart';
import 'package:coronavirus_test/localization.dart';

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
    final String result = ModalRoute.of(context).settings.arguments;
    return (Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black87,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            AppLocalizations.of(context).translate('result_label'),
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          bottomOpacity: 0.0,
        ),
        body: (SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate('risk_label') +
                    ": " +
                    getRiskLevel(result),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(
                height: 10,
              ),
              resultCard(result),
              SizedBox(height: 50),
              SizedBox(
                child: RaisedButton(
                    splashColor: Colors.white70,
                    color: Color.fromRGBO(82, 151, 93, 1),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelplineScreen()));
                    },
                    elevation: 2.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('view_helpline_label'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
        )))));
  }

  getRiskLevel(String risk) {
    switch (risk) {
      case "RISK0":
        {
          return AppLocalizations.of(context).translate('very_low_label');
        }
        break;
      case "RISK1":
        {
          return AppLocalizations.of(context).translate('low_label');
        }
        break;
      case "RISK2":
        {
          return AppLocalizations.of(context).translate('medium_label');
        }
        break;
      case "RISK3":
        {
          return AppLocalizations.of(context).translate('high_label');
        }
        break;
    }
  }

  resultCard(String risk) {
    switch (risk) {
      case "RISK0":
        {
          return Card(
              elevation: 4,
              color: Colors.lightGreenAccent,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 20.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context).translate('risk_0'),
                        style: TextStyle(fontSize: 15),
                      ))));
        }
        break;
      case "RISK1":
        {
          return Card(
              elevation: 4,
              color: Colors.amber,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 20.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context).translate('risk_1'),
                        style: TextStyle(fontSize: 15),
                      ))));
        }
        break;
      case "RISK2":
        {
          return Card(
              elevation: 4,
              color: Colors.redAccent,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 20.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context).translate('risk_2'),
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ))));
        }
        break;
      case "RISK3":
        {
          return Card(
              elevation: 4,
              color: Colors.red,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 20.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context).translate('risk_3'),
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ))));
        }
        break;
    }
  }
}
