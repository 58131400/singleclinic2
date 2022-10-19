import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'package:singleclinic/utils/shared_preferences_utils.dart';
import 'package:singleclinic/main.dart';
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
    if (CommonSharedPreferences.getNewProfileImg() != null)
      path = CommonSharedPreferences.getNewProfileImg()!;
    if (CommonSharedPreferences.getProfileImg() != null)
      imageUrl = CommonSharedPreferences.getProfileImg()!;
    print("----init setting screen\n");
    print("path: $path");
    print("image url: $imageUrl");
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
    // imageUrl = CommonSharedPreferences.getProfileImg();
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        color: Colors.white,
      ),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  child: Container(
                    height: 110,
                    width: 110,
                    child: imageUrl == null
                        ? InkWell(
                            child: Image.asset(
                            "assets/appicon.png",
                            fit: BoxFit.cover,
                          ))
                        : InkWell(
                            borderRadius: BorderRadius.circular(20),
                            child: path.isEmpty
                                ? CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: imageUrl!,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Container(
                                                child: Center(
                                                    child: Icon(
                                      Icons.account_circle,
                                      size: 110,
                                      color: LIGHT_GREY_TEXT,
                                    ))),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      child: Center(
                                        child: Icon(
                                          Icons.account_circle,
                                          size: 110,
                                          color: LIGHT_GREY_TEXT,
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    File(CommonSharedPreferences
                                        .getNewProfileImg()!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                    // StreamBuilder(
                    //   builder: builder)
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
                            setState(() {
                              imageUrl =
                                  CommonSharedPreferences.getProfileImg();
                              print('new imageUrl: $imageUrl');
                              name = CommonSharedPreferences.getName();
                              if (CommonSharedPreferences.getNewProfileImg() !=
                                  null)
                                path =
                                    CommonSharedPreferences.getNewProfileImg()!;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    child: name != null
                        ? Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(name!.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .apply(bodyColor: LIGHT_GREY_TEXT)
                                      .bodyText1),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.white,
                                    backgroundColor: NAVY_BLUE,
                                    elevation: 10,
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
                                              .apply(bodyColor: Colors.white)
                                              .bodyText2),
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    //fixedSize: Size.fromWidth(115),
                                    primary: LIGHT_GREY,
                                    elevation: 1,
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
                                              .apply(bodyColor: LIGHT_GREY_TEXT)
                                              .bodyText2),
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  )),
                            ],
                          )),
                SizedBox(
                  height: 8,
                ),
                name == null
                    ? Container()
                    : Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: NAVY_BLUE,
                            size: 16,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(email!,
                              style: Theme.of(context)
                                  .textTheme
                                  .apply(bodyColor: LIGHT_GREY_TEXT)
                                  .bodyText1),
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
                              child: name == null
                                  ? Text(AppLocalizations.of(context)!.profile,
                                      style: Theme.of(context)
                                          .textTheme
                                          .apply(
                                              decoration: name == null
                                                  ? TextDecoration.none
                                                  : TextDecoration.underline,
                                              bodyColor: LIGHT_GREY_TEXT)
                                          .bodyText1)
                                  : Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .log_out,
                                            style: Theme.of(context)
                                                .textTheme
                                                .apply(
                                                    bodyColor: LIGHT_GREY_TEXT)
                                                .bodyText1),
                                      ],
                                    )),
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
            IntrinsicHeight(
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                  ),
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
                  Text(AppLocalizations.of(context)!.language,
                      style: Theme.of(context)
                          .textTheme
                          .apply(bodyColor: LIGHT_GREY_TEXT)
                          .bodyText1),
                ],
              ),
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
                  style: Theme.of(context).textTheme.headline6,
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
                                Text(list[index].options[i].toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .apply(bodyColor: LIGHT_GREY_TEXT)
                                        .bodyText1),
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
          CommonSharedPreferences.setNewProfileImg(path);
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
                  await updateUserPresence();

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

  updateUserPresence() async {
    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().toUtc().toString(),
    };

    FirebaseDatabase.instance
        .ref()
        .child(CommonSharedPreferences.getUserId().toString())
        .update(presenceStatusFalse);
  }
}

class OptionsList {
  String title;
  List<String> options;
  List<Widget> screen;
  List<Icon> icons;

  OptionsList(this.title, this.options, this.screen, this.icons);
}
