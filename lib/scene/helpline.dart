import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:coronavirus_test/localization.dart';

class HelplineScreen extends StatefulWidget {
  HelplineScreen({Key key}) : super(key: key);

  @override
  _HelplineScreenState createState() => _HelplineScreenState();
}

class _HelplineScreenState extends State {
  bool isLoggedIn = false;
  bool isLoading = true;
  PageController controller = PageController(viewportFraction: 1);

  var stateHelpline = [];
  var utHelpline = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    var st = await rootBundle.loadString('assets/helpline_state.json');
    var ut = await rootBundle.loadString('assets/helpline_ut.json');

    this.setState(() {
      stateHelpline = jsonDecode(st);
      utHelpline = jsonDecode(ut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black87,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(
            AppLocalizations.of(context).translate('helpline_numbers_key'),
            style: TextStyle(color: Colors.black87),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          bottomOpacity: 0.0,
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Expanded(
                    child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "States",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Divider(),
            DataTable(
              columns: [
                DataColumn(
                    label: Text(
                  'No.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text('State / UT',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Helpline',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: stateHelpline.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['state'])),
                  DataCell(InkWell(
                    child: Text(item['no'].toString(),
                        style: TextStyle(color: Colors.blueAccent)),
                    onTap: () {
                      var phone = item['no'].toString();
                      _makePhoneCall("tel:$phone");
                    },
                  )),
                ]);
              }).toList(),
            ),
            SizedBox(
              height: 30,
            ),
            Text("Union Territories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Divider(),
            DataTable(
              columns: [
                DataColumn(
                    label: Text('No.',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Union Territory',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Helpline',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ))),
              ],
              rows: utHelpline.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['ut'])),
                  DataCell(InkWell(
                    child: Text(item['no'].toString(),
                        style: TextStyle(color: Colors.blueAccent)),
                    onTap: () {
                      var phone = item['no'].toString();
                      _makePhoneCall("tel:$phone");
                    },
                  )),
                ]);
              }).toList(),
            )
          ],
        ))))));
  }

  _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
