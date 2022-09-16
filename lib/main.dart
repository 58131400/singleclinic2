import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/screens/AppointmentScreen.dart';
import 'package:singleclinic/screens/BookAppointment.dart';
import 'package:singleclinic/screens/ChatList.dart';
import 'package:singleclinic/screens/HomeScreen.dart';
import 'package:singleclinic/screens/SettingsScreen.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:singleclinic/screens/SplashScreen.dart';

import 'notificationTesting/notificationHelper.dart';

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

//String SERVER_ADDRESS = "http://192.168.1.6:80/PHPScript";
String SERVER_ADDRESS = "http://192.168.101.24:80/PHPScript";
MyNotificationHelper notificationHelper = MyNotificationHelper();
final String serverToken =
    // "AAAAO2Co7iU:APA91bHzp5j7Do_A_LAFUpwLzqNESEYUUC_At6nLZoB6yH1wmWFsfsvKjOplY9cYH-pJzpVfYTZl68oFkip9F-VlXqr4oB-NA9QuJ1ZMBLPLfXh_mn4taaQR7cXEtw1j2Ryqka2kAlqy";
    "AAAAKvbfUn0:APA91bE-yVJ9DCcS2Ne1IDYbYT_BhDKuPl47dFQH2CEO1JvqjrcQi-iEtpyvXrvuUaelw9Lh_xgMk5iCysXTs1PuTViFu672929uQASlHpqssO_HFbs79-7mU8aKVIXjJeHgWLMbrLOY";
const String TOKENIZATION_KEY = 'sandbox_v2fzhc6d_qpj7hhj994nbzy5q';
const String CURRENCY_CODE = 'USD';
const String DISPLAY_NAME = 'Lybia Company';

Color LIME = Color(0xFF094D55);
//Color LIME = Color.fromRGBO(231, 208, 69, 1);
Color WHITE = Colors.white;
Color BLACK = Colors.black;
Color NAVY_BLUE = Color(0xFF094D55); //Color.fromRGBO(53, 99, 128, 1);
Color LIGHT_GREY = Color.fromRGBO(230, 230, 230, 1);
Color LIGHT_GREY_SCREEN_BG = Color.fromRGBO(240, 240, 240, 1);
Color LIGHT_GREY_TEXT = Colors.grey.shade700;
String CURRENCY = "\$";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.length == 0) {
    await Firebase.initializeApp();
  }
  notificationHelper.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const SingleClinic());
}

class SingleClinic extends StatefulWidget {
  const SingleClinic({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    print('new locale: $newLocale');
    _SingleClinicState? state =
        context.findAncestorStateOfType<_SingleClinicState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _SingleClinicState createState() => _SingleClinicState();
}

class _SingleClinicState extends State<SingleClinic> {
  Locale? _locale;
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      if (value.getString("language_code") != null) {
        print('main : ' + value.getString("language_code").toString());
        setState(() {
          _locale = Locale(value.getString("language_code")!);
        });
      } else
        _locale = Locale("en");
    });
  }

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          iconTheme: IconThemeData(color: NAVY_BLUE),
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
          primaryColor: NAVY_BLUE,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: LIME, primary: NAVY_BLUE)),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {'/bookAppointment': (context) => BookAppointment()},
      locale: _locale,
      supportedLocales: [
        const Locale('vi', ''),
        const Locale('en', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen>
    with TickerProviderStateMixin {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            HomeScreen(),
            currentTab > 0 ? ChatList() : Container(),
            currentTab > 1 ? AppointmentScreen() : Container(),
            currentTab > 2 ? SettingsScreen() : Container(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentTab,
          backgroundColor: WHITE,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                currentTab == 0
                    ? "assets/tabBar/home_active.png"
                    : "assets/tabBar/home.png",
                color: currentTab == 0 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                height: 23,
                width: 23,
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  currentTab == 1
                      ? "assets/tabBar/chat_active.png"
                      : "assets/tabBar/chat.png",
                  color: currentTab == 1 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                  height: 23,
                  width: 23,
                ),
                label: AppLocalizations.of(context)!.chat),
            BottomNavigationBarItem(
                icon: Image.asset(
                  currentTab == 2
                      ? "assets/tabBar/appointment_active.png"
                      : "assets/tabBar/appointment.png",
                  color: currentTab == 2 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                  height: 23,
                  width: 23,
                ),
                label: AppLocalizations.of(context)!.appointment),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentTab == 3
                    ? "assets/tabBar/setting_active.png"
                    : "assets/tabBar/setting.png",
                color: currentTab == 3 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                height: 23,
                width: 23,
              ),
              label: AppLocalizations.of(context)!.setting,
            ),
          ],
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          showSelectedLabels: true,
          unselectedFontSize: 10,
          selectedLabelStyle: TextStyle(
            color: LIGHT_GREY_TEXT,
          ),
          onTap: (val) {
            setState(() {
              currentTab = val;
            });
          },
        ),
      ),
    );
  }
}

class SignInDemo extends StatefulWidget {
  @override
  _SignInDemoState createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _googleSignIn.signIn().then((value) {
              value!.authentication.then((googleKey) {
                print(googleKey.idToken);
                print(googleKey.accessToken);
                print(value.email);
                print(value.displayName);
                print(value.photoUrl);
              }).catchError((e) {
                print(e.toString());
              });
            }).catchError((e) {
              print(e.toString());
            });
          },
          child: Container(),
        ),
      ),
    );
  }
}

class AppleLogin extends StatefulWidget {
  @override
  _AppleLoginState createState() => _AppleLoginState();
}

class _AppleLoginState extends State<AppleLogin> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example app: Sign in with Apple'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Center(),
        ),
      ),
    );
  }
}

Future myBackgroundMessageHandler(RemoteMessage event) async {
  await Firebase.initializeApp();
  HomeScreen().createState();
  print("\n\nbackground:  ${event.data}");

  notificationHelper.showMessagingNotification(data: event.data);
}

doesSendNotification(String userUid, bool doesSend) async {
  await SharedPreferences.getInstance().then((value) {
    value.setBool(userUid, doesSend);
    print("\n\n ------------------> " +
        value.getBool(userUid).toString() +
        "\n\n");
  });
}
