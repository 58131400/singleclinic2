import 'dart:io';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/screens/ForgetPassword.dart';
import 'package:singleclinic/screens/SignUpScreen.dart';
import 'package:singleclinic/services/AuthService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:singleclinic/utils/firebase_database.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String name = "";
  String email = "";
  String password = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String image = "";

  @override
  Widget build(BuildContext context) {
    print("go to login page");
    return SafeArea(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: WHITE,
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: body(),
      ),
    );
  }

  header() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.5,
      color: NAVY_BLUE,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context)!.login,
              style: Theme.of(context)
                  .textTheme
                  .apply(bodyColor: Colors.white)
                  .titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  body() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(AppLocalizations.of(context)!.email_address,
                  style: Theme.of(context).textTheme.headline6),
              TextFormField(
                validator: (val) {
                  if (!EmailValidator.validate(email)) {
                    return "Enter correct email";
                  }
                  return null;
                },
                onSaved: (val) => email = val!,
                style: TextStyle(
                    color: LIGHT_GREY_TEXT,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.mail_outline,
                  ),
                  prefixIconColor: NAVY_BLUE,
                  hintText: "abc@xyz.com",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .apply(bodyColor: LIGHT_GREY_TEXT)
                      .bodyText1,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  isCollapsed: true,
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                ),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                AppLocalizations.of(context)!.password,
                style: Theme.of(context).textTheme.headline6,
              ),
              TextFormField(
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter your password";
                  }
                  return null;
                },
                onSaved: (val) => password = val!,
                style: TextStyle(
                    color: LIGHT_GREY_TEXT,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                obscureText: true,
                decoration: InputDecoration(
                  isCollapsed: true,
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                  ),
                  prefixIconColor: NAVY_BLUE,
                  hintText: "*********",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .apply(bodyColor: LIGHT_GREY_TEXT)
                      .bodyText1,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                ),
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgetPassword()));
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppLocalizations.of(context)!.forget_password,
                    style: TextStyle(
                        color: NAVY_BLUE,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          loginIntoAccount(1);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: LIME,
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            style: TextStyle(
                                color: WHITE,
                                fontWeight: FontWeight.w700,
                                fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 12),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.register,
                      style: TextStyle(
                          color: NAVY_BLUE,
                          fontSize: 13,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: LIGHT_GREY_TEXT,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.or,
                    style: TextStyle(
                        color: LIGHT_GREY_TEXT,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Divider(
                      color: LIGHT_GREY_TEXT,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        facebookLogin();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: NAVY_BLUE.withOpacity(0.7),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    "assets/loginregister/facebook_btn.png",
                                    fit: BoxFit.cover,
                                  ),
                                )),
                              ],
                            ),
                            Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .continue_with_facebook,
                                style: TextStyle(
                                    color: WHITE,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        googleLogin();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: NAVY_BLUE.withOpacity(0.7),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    "assets/loginregister/google_btn.png",
                                    fit: BoxFit.cover,
                                  ),
                                )),
                              ],
                            ),
                            Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .continue_with_google,
                                style: TextStyle(
                                    color: WHITE,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Platform.isIOS
                  ? Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: NAVY_BLUE.withOpacity(0.7),
                            ),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        "assets/loginregister/appleid.png",
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .continue_with_apple_id,
                                    style: TextStyle(
                                        color: WHITE,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  errorDialog(message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  message.toString(),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }

  processingDialog(message) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.loading),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 14),
                  ),
                )
              ],
            ),
          );
        });
  }

  loginIntoAccount(int type) async {
    processingDialog(
        AppLocalizations.of(context)!.please_wait_while_logging_into_account);
    Response response;
    Dio dio = new Dio();

    FormData formData = type == 1
        ? FormData.fromMap({
            "email": email,
            "password": password,
            "device_token": await firebaseMessaging.getToken(),
            "device_type": "$type",
          })
        : FormData.fromMap({
            "name": name,
            "email": email,
            "image": image,
            "device_token": await firebaseMessaging.getToken(),
            "device_type": "$type",
          });
    response = await dio
        .post(
            SERVER_ADDRESS +
                "/api/userlogin?login_type=$type&device_token=${await firebaseMessaging.getToken()}&device_type=1&email=$email",
            data: formData)
        .catchError((e) {
      print("ERROR : $e");
      if (type == 2) {
        googleLogin();
      } else {
        Navigator.pop(context);
        print("Error" + e.toString());
        errorDialog(e.toString());
      }
    });

    print(response.realUri);
    print(response.data);

    if (response.statusCode == 200 && response.data['status'] == 1) {
      Map<String, dynamic> userData = {
        "id": response.data["data"]["id"],
        "name": response.data["data"]["name"],
        "profile_pic": response.data["data"]["profile_pic"],
        "usertype": response.data["data"]["usertype"]
      };
      CommonFirebaseDatabase.updateUserProfileToDatabase(userData);
      CommonFirebaseDatabase.saveToken(await firebaseMessaging.getToken(),
          response.data['data']['id'].toString());
      await SharedPreferences.getInstance().then((value) {
        value.setBool("isLoggedIn", true);
        value.setString("name", response.data['data']['name'] ?? "");
        value.setString("email", response.data['data']['email'] ?? "");
        value.setString("phone_no", response.data['data']['phone_no'] ?? "");
        value.setString("password", password);
        value.setString(
            "profile_pic", response.data['data']['profile_pic'] ?? "");
        value.setInt("id", response.data['data']['id']);
        value.setString("usertype", response.data['data']['usertype']);
        value.setString("uid", response.data['data']['id'].toString());
      });

      print("\n\nData added in device\n\n");

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabBarScreen(),
          ));
    } else {
      Navigator.pop(context);
      print("Error" + response.toString());
      errorDialog(response.data['msg']);
    }
  }

  facebookLogin() async {
    dynamic result = await AuthService.facebookLogin();

    if (result != null) {
      if (result is String) {
        errorDialog('${result}');
      } else if (result is Map) {
        setState(() {
          name = result['name'];
          email = result['email'] ?? "null";
          image = result['profile'] ?? " ";
        });

        loginIntoAccount(3);
      } else {
        errorDialog('Something went wrong with the login process');
      }
    } else {
      errorDialog('Something went wrong with the login process');
    }
  }

  googleLogin() async {
    await _googleSignIn.signIn().then((value) {
      value!.authentication.then((googleKey) {
        print(googleKey.idToken);
        print(googleKey.accessToken);
        print(value.email);
        print(value.displayName);
        print(value.photoUrl);
        setState(() {
          name = value.displayName!;
          email = value.email;
          image = value.photoUrl!;
        });

        loginIntoAccount(2);
      }).catchError((e) {
        print(e.toString());
        errorDialog(e.toString());
      });
    }).catchError((e) {
      print(e.toString());
      errorDialog(e.toString());
    });
  }
}
