import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/auth/otp.dart';
import 'package:gogetapp/screens/auth/signup.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';


class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  late String phoneNo, verificationId, smsCode;

  String error = '';

  bool codeSent = false;
  bool loading = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: HexColor('#2D7A98'),
      //   automaticallyImplyLeading: false,
      //   title: Text('Sign In', style: GoogleFonts.openSans(fontSize: 30.0) ,),centerTitle: true,),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                // height: 100.0,
                // width: 100.0,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage(
                //         'assets/login_signup_screen_logo.png'),
                //     fit: BoxFit.fill,
                //   ),
                //   shape: BoxShape.rectangle,
                // ),
                child: Text('SignIn', style: GoogleFonts.openSans(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black54 )),
              ),
            SizedBox(height: 50.0,),
            Form(key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.orange,),
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.openSans(color: Colors.black54,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.orange)
                      ),
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.isEmpty ? 'Please provide a valid phone number to login' : null,
                    onChanged: (val) {
                      setState(() => phoneNo = val);
                    }
                  ),
                  // SizedBox(height: 20,),
                  // TextFormField(
                  //   decoration: InputDecoration(
                  //     prefixIcon: Icon(Icons.vpn_key, color: Colors.orange,),
                  //     labelText: 'password',
                  //     labelStyle: GoogleFonts.openSans(color: Colors.green),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(25.0),),
                  //       borderSide: BorderSide(color: Colors.grey)
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(25.0),),
                  //       borderSide: BorderSide(width: 2.0, color: Colors.black45)
                  //     ),
                  //   ),
                  //   keyboardType: TextInputType.text,
                  //   obscureText: true,
                  //   validator: (val) => val!.isEmpty ? 'Please provide a password' : null,
                  //   onChanged: (val) {
                  //     setState(() => password = val);
                  //   }
                  // ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange,),),
                    child: Text('Sign In'),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        var chkphno = await _firestore.collection('users').where('phno', isEqualTo: '+91 '+phoneNo).get();
                        if(chkphno.docs.length == 1){ 
                          setState(() => loading = true);
                          var inPhoneNo = '+91 '+ phoneNo.trim();
                          verifyPhone(inPhoneNo);
                        } else {displaySnackBar('Phone Number not registered. Please use SignUp.');}
                      }
                    },
                  ),
                  TextButton(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New User?', style: TextStyle(color: Colors.black54),),
                        SizedBox(width: 5.0,),
                        Text('Register', style: TextStyle(color: Colors.orange,),),
                      ],
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUp())
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
  Future<void> verifyPhone(phoneNo) async {
    
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      _auth.signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      //print('${authException.message}');
      displaySnackBar('Validation error, please try again later');
    };

    final void Function(String verId, [int? forceResend]) smsSent = (String verId, [int? forceResend]) async {
      this.verificationId = verId;
      //Navigator.pop(context);
      await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => OTP(verId, 'signin', '', '', '', '', '', '', '')));
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        //timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 3),
      ));
  }


}