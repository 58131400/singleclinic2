import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/screens/AboutUs.dart';
import 'package:singleclinic/screens/AppointmentScreen.dart';
import 'package:singleclinic/screens/ContactUsScreen.dart';
import 'package:singleclinic/screens/DepartmentScreen.dart';
import 'package:singleclinic/screens/FacilitiesScreen.dart';
import 'package:singleclinic/screens/GalleryScreen.dart';
import 'package:singleclinic/screens/LoginScreen.dart';
import 'package:singleclinic/screens/SignUpScreen.dart';
import 'package:singleclinic/screens/SubcriptionList.dart';
import 'package:singleclinic/screens/SubscriptionPlansScreen.dart';
import 'package:singleclinic/screens/TermAndConditions.dart';
import 'package:singleclinic/screens/UpdateProfileScreen.dart';
import '../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

enum Menu { en, vi }

class _SettingsScreenState extends State<SettingsScreen> {
  String path = "";
  final picker = ImagePicker();
  String? imageUrl;
  String? name, email;
  List<OptionsList> list = [];
  String? selectedLanguage = "en";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("go to setting screen");
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          flexibleSpace: header(),
          backgroundColor: WHITE,
        ),
        body: body(context),
      ),
    );
  }

  header() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.settings_applications,
                  size: 25,
                  color: NAVY_BLUE,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.setting.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body(BuildContext context) {
    return SingleChildScrollView(
        child: FutureBuilder(
            future: loadInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print(snapshot.connectionState);
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.connectionState);
                return Column(
                  children: [
                    profileCard(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: Column(
                        children: [
                          chooseLanguage(context),
                          optionsList(context)
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                print(snapshot.connectionState);
              }
              return Container();
            }));
  }

  Future loadInfo() async {
    if (list.isNotEmpty) list.clear();
    var value = await SharedPreferences.getInstance();

    print('load info');
    imageUrl = value.getString("profile_pic");
    print('imageUrl : $imageUrl');
    name = value.getString("name");
    email = value.getString("email");
    print('email : $email');
    selectedLanguage = value.getString("language_code") ?? 'en';

    list.add(OptionsList(MY_SUBCRIPTIONS, [
      AppLocalizations.of(context)!.my_subcriptions,
      AppLocalizations.of(context)!.appointment_history,
      AppLocalizations.of(context)!.subscription_plans
    ], [
      SubcriptionList(),
      AppointmentScreen(),
      SubscriptionPlansScreen()
    ], [
      Icon(Icons.shopping_cart),
      Icon(Icons.edit_calendar_rounded),
      Icon(
        Icons.add_shopping_cart,
      ),
    ]));
    list.add(OptionsList(MORE, [
      AppLocalizations.of(context)!.departments,
      AppLocalizations.of(context)!.facilities,
      AppLocalizations.of(context)!.gallery
    ], [
      DepartmentScreen(),
      FacilitiesScreen(),
      GalleryScreen()
    ], [
      Icon(
        Icons.medical_services,
      ),
      Icon(
        Icons.apartment,
      ),
      Icon(
        Icons.collections,
      ),
    ]));
    list.add(OptionsList(CONTACT_DETAILS, [
      AppLocalizations.of(context)!.term_and_condition,
      AppLocalizations.of(context)!.about_us,
      AppLocalizations.of(context)!.contact_us
    ], [
      TermAndConditions(),
      AboutUs(),
      ContactUsScreen()
    ], [
      Icon(
        Icons.privacy_tip,
      ),
      Icon(
        Icons.info,
      ),
      Icon(
        Icons.help,
      ),
    ]));
  }

  profileCard(BuildContext context) {
    return Container(
      color: NAVY_BLUE,
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 110,
                    width: 110,
                    child: imageUrl == null
                        ? Container(
                            child: Image.asset(
                            "assets/appicon.png",
                            fit: BoxFit.scaleDown,
                          ))
                        : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: imageUrl!,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Container(
                                    child: Center(
                                        child: Icon(
                              Icons.account_circle,
                              size: 110,
                              color: LIGHT_GREY_TEXT,
                            ))),
                            errorWidget: (context, url, error) => Container(
                              child: Center(
                                child: Icon(
                                  Icons.account_circle,
                                  size: 110,
                                  color: LIGHT_GREY_TEXT,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  height: 110,
                  width: 110,
                  child: InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () async {
                          bool check = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateProfileScreen()));
                          if (check) {
                            await SharedPreferences.getInstance().then((value) {
                              setState(() {
                                imageUrl = value.getString("profile_pic");
                                name = value.getString("name");
                              });
                            });
                          }
                        },
                        child: name != null
                            ? Image.asset(
                                "assets/loginregister/edit.png",
                                height: 35,
                                width: 35,
                                fit: BoxFit.fill,
                              )
                            : Container(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    child: name != null
                        ? Text(name!.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .apply(bodyColor: Colors.white)
                                .bodyText1)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  style: TextButton.styleFrom(
                                    fixedSize: Size.fromWidth(100),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
                                  },
                                  child: Row(
                                    children: [
                                      Text(AppLocalizations.of(context)!.signIn,
                                          style: Theme.of(context)
                                              .textTheme
                                              .apply(bodyColor: NAVY_BLUE)
                                              .bodyText1),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.login,
                                        color: NAVY_BLUE,
                                      )
                                    ],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    fixedSize: Size.fromWidth(100),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignUpScreen()));
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!
                                              .register,
                                          style: Theme.of(context)
                                              .textTheme
                                              .apply(bodyColor: NAVY_BLUE)
                                              .bodyText1),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.person_add,
                                        color: NAVY_BLUE,
                                      ),
                                    ],
                                  )),
                            ],
                          )),
                SizedBox(
                  height: 2,
                ),
                name == null
                    ? Container()
                    : Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: LIGHT_GREY_TEXT,
                            size: 12,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            email!,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                name == null
                    ? Container()
                    : Column(
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              messageDialog(
                                  ALERT,
                                  AppLocalizations.of(context)!
                                      .are_you_sure_to_log_out);
                            },
                            child: Text(
                                name == null
                                    ? AppLocalizations.of(context)!.profile
                                    : AppLocalizations.of(context)!.log_out,
                                style: Theme.of(context)
                                    .textTheme
                                    .apply(
                                        decoration: name == null
                                            ? TextDecoration.none
                                            : TextDecoration.underline)
                                    .bodyText1),
                          ),
                        ],
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  chooseLanguage(BuildContext context) {
    print('selected language2: $selectedLanguage');
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.language,
              style: Theme.of(context).textTheme.headline5,
            ),
            PopupMenuButton(
              child: Row(
                children: [
                  Text(
                    selectedLanguage == "en"
                        ? AppLocalizations.of(context)!.language_en
                        : AppLocalizations.of(context)!.language_vi,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: LIGHT_GREY_TEXT,
                    size: 15,
                  )
                ],
              ),
              onSelected: (Menu item) {
                setState(() {
                  SharedPreferences.getInstance().then((value) {
                    value.setString("language_code", item.name);
                    selectedLanguage = item.name;
                    SingleClinic.setLocale(context,
                        Locale.fromSubtags(languageCode: selectedLanguage!));
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabBarScreen(),
                        ));
                    print(
                        " Setting screen set language code : ->${value.getString("language_code")}");
                  });
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                PopupMenuItem<Menu>(
                  value: Menu.en,
                  child: Text(AppLocalizations.of(context)!.language_en),
                ),
                PopupMenuItem<Menu>(
                  value: Menu.vi,
                  child: Text(AppLocalizations.of(context)!.language_vi),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  optionsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  list[index].title,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: list[index].options.length,
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => list[index].screen[i]));
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                list[index].icons[i],
                                SizedBox(
                                  width: 5,
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  width: 20,
                                  thickness: 1,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  list[index].options[i].toString(),
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: LIGHT_GREY_TEXT,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: LIGHT_GREY_TEXT,
                            size: 15,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        setState(() {
          path = File(pickedFile.path).path;
        });
      } else {
        print('No image selected.');
      }
    });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await SharedPreferences.getInstance().then((value) {
                    value.clear();
                  });
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                style: TextButton.styleFrom(backgroundColor: LIME),
                child: Text(
                  YES,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: WHITE,
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class OptionsList {
  String title;
  List<String> options;
  List<Widget> screen;
  List<Icon> icons;

  OptionsList(this.title, this.options, this.screen, this.icons);
}
