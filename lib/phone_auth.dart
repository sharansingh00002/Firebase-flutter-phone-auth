import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  String phoneNumber;
  String verificationCode;

  TextEditingController otpController;
  TextEditingController phoneController;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String verificationId;

  @override
  void initState() {
    otpController = TextEditingController();
    phoneController = TextEditingController();
    super.initState();
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      verificationId = verId;
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {
      firebaseAuth.signInWithCredential(auth).then((AuthResult value) {
        if (value.user != null) {
          FirebaseUser user = value.user;
          userAuthorized();
        } else {
          debugPrint('user not authorized');
        }
      }).catchError((error) {
        debugPrint('error : $error');
      });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  void verifyOTP(String smsCode) async {
    var _authCredential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
    firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult result) {
      FirebaseUser user = result.user;

      if (user != null) {
        userAuthorized();
      }

      ///go To Next Page
    }).catchError((error) {
      Navigator.pop(context);
    });
  }

  userAuthorized() {
    print('can go to next page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: phoneController,
              decoration: InputDecoration(hintText: 'Enter phone Number'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Enter OTP'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      verifyPhone(phoneController.text.trim());
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Send OTP'),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      verifyOTP(otpController.text.trim());
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Verify OTP'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
