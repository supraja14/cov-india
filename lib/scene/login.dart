import 'package:flutter/material.dart';
import '../sign_in.dart';
import 'home.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _smsVerificationCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: new Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Center(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Column(children: <Widget>[
                    Image(image: AssetImage("assets/logo.png"), height: 150.0),
                    new Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: Text("Corona virus - Test",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            )))
                  ]),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[_signInButton(), _phoneInput(context)],
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Widget _otpOverlay() {
    return (Container(
        width: 30,
        alignment: Alignment.center,
        child: Column(children: <Widget>[
          Text("Enter the OTP sent on " + phoneNumber),
          Material(
              elevation: 2,
              borderRadius: new BorderRadius.circular(3),
              child: TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelText: '------',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  onSubmitted: (String otp) {}))
        ])));
  }

  Widget _phoneInput(BuildContext context) {
    return Container(
        height: 50,
        margin: const EdgeInsets.fromLTRB(60, 10, 60, 10),
        child: Material(
            elevation: 2,
            borderRadius: new BorderRadius.circular(3),
            child: TextField(
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  prefixText: "+91",
                  fillColor: Colors.white,
                  labelText: 'Enter Phone Number',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
                onSubmitted: (String phoneNum) {
                  _verifyPhoneNumber(context, "+91" + phoneNum);
                  print(phoneNum);
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),
                          child: Container(
                            height: 200,
                            child: Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                          "Enter the OTP sent on \n +91-" +
                                              phoneNum,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      Container(
                                          width: 100,
                                          height: 50,
                                          child: Material(
                                              elevation: 2,
                                              borderRadius:
                                                  new BorderRadius.circular(3),
                                              child: TextField(
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        6)
                                                  ],
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    labelText: '',
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                  onChanged: (String otp) {
                                                    if (otp.length == 6) {
                                                      print("Submitted: ");
                                                    }
                                                  })))
                                    ])),
                          ),
                        );
                      });
                })));
  }

  Widget _signInButton() {
    return Container(
        height: 50,
        margin: const EdgeInsets.fromLTRB(60, 10, 60, 10),
        child: RaisedButton(
          splashColor: Colors.grey,
          color: Colors.white,
          onPressed: () {
            signInWithGoogle().whenComplete(() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return HomeScreen();
                  },
                ),
              );
            });
          },
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/google_logo.png"),
                  height: 25.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _verificationComplete(AuthCredential authCredential, BuildContext context) {
    FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((authResult) {
      print(authResult.user.uid);
    });
  }

  _smsCodeSent(String verificationId, List<int> code) {
    // set the verification code so that we can use it to log the user in
    print(verificationId);
    _smsVerificationCode = verificationId;
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    print(authException.message.toString());
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
  }

  /// method to verify phone number and handle phone auth
  _verifyPhoneNumber(BuildContext context, String phoneNumber) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 5),
        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential, context),
        verificationFailed: (authException) =>
            _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) =>
            _smsCodeSent(verificationId, [code]));
  }
}
