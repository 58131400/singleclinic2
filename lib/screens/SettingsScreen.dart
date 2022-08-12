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
  String selectedLanguage = "en";

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        imageUrl = value.getString("profile_pic");
        name = value.getString("name");
        email = value.getString("email");
        selectedLanguage = value.getString("language_code") ?? 'en';

        if (selectedLanguage == 'en') {
          list.add(OptionsList(
            MY_SUBCRIPTIONS,
            [MY_SUBCRIPTIONS, APPOINTMENT_HISTORY, SUBSCRIPTION_PLANS],
            [SubcriptionList(), AppointmentScreen(), SubscriptionPlansScreen()],
          ));
          list.add(OptionsList(MORE, [DEPARTMENTS, FACILITIES, GALLERY],
              [DepartmentScreen(), FacilitiesScreen(), GalleryScreen()]));
          list.add(OptionsList(
            CONTACT_DETAILS,
            [TERM_AND_CONDITION, ABOUT_US, CONTACT_US],
            [TermAndConditions(), AboutUs(), ContactUsScreen()],
          ));
        }
        if (selectedLanguage == 'vi') {
          list.add(OptionsList(
            "Đăng kí của tôi",
            ["Đăng kí", "Lịch hẹn", "Kế hoạch"],
            [SubcriptionList(), AppointmentScreen(), SubscriptionPlansScreen()],
          ));
          list.add(OptionsList("Khác", ["Khoa", "Cơ sở", "Trưng bày"],
              [DepartmentScreen(), FacilitiesScreen(), GalleryScreen()]));
          list.add(OptionsList(
            "Chi tiết liên lạc",
            ["Điều khoản & quy định", "Về chúng tôi", "Liên hệ"],
            [TermAndConditions(), AboutUs(), ContactUsScreen()],
          ));
        }
      });
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.setting,
                  style: TextStyle(
                      color: BLACK, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [profileCard(), chooseLanguage(context), optionsList()],
        ),
      ),
    );
  }

  profileCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (name == null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Container(
                  height: 110,
                  width: 110,
                  child: imageUrl == null
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.account_circle,
                            size: 110,
                            color: LIGHT_GREY_TEXT,
                          ),
                        )
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name != null ? name!.toUpperCase() : "Sign In",
                style: TextStyle(
                    color: NAVY_BLUE,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
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
                          style: TextStyle(
                              color: LIGHT_GREY_TEXT,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
              name == null
                  ? Container()
                  : SizedBox(
                      height: 8,
                    ),
              InkWell(
                onTap: () {
                  messageDialog(ALERT,
                      AppLocalizations.of(context)!.are_you_sure_to_log_out);
                },
                child: Text(
                  name == null
                      ? AppLocalizations.of(context)!.profile
                      : AppLocalizations.of(context)!.log_out,
                  style: TextStyle(
                      color: name == null ? LIGHT_GREY_TEXT : BLACK,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: name == null
                          ? TextDecoration.none
                          : TextDecoration.underline),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<dynamic> getUsedLanguage() async {}
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
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            PopupMenuButton(
              child: Row(
                children: [
                  Text(selectedLanguage == "en"
                      ? AppLocalizations.of(context)!.language_en
                      : AppLocalizations.of(context)!.language_vi),
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
                        Locale.fromSubtags(languageCode: selectedLanguage));
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
        Divider(
          color: LIGHT_GREY_TEXT,
        ),
      ],
    );
  }

  optionsList() {
    setState(() {
      list.clear();
      if (selectedLanguage == 'en') {
          list.add(OptionsList(
            MY_SUBCRIPTIONS,
            [MY_SUBCRIPTIONS, APPOINTMENT_HISTORY, SUBSCRIPTION_PLANS],
            [SubcriptionList(), AppointmentScreen(), SubscriptionPlansScreen()],
          ));
          list.add(OptionsList(MORE, [DEPARTMENTS, FACILITIES, GALLERY],
              [DepartmentScreen(), FacilitiesScreen(), GalleryScreen()]));
          list.add(OptionsList(
            CONTACT_DETAILS,
            [TERM_AND_CONDITION, ABOUT_US, CONTACT_US],
            [TermAndConditions(), AboutUs(), ContactUsScreen()],
          ));
        }
        if (selectedLanguage == 'vi') {
          list.add(OptionsList(
            "Đăng kí của tôi",
            ["Đăng kí", "Lịch hẹn", "Kế hoạch"],
            [SubcriptionList(), AppointmentScreen(), SubscriptionPlansScreen()],
          ));
          list.add(OptionsList("Khác", ["Khoa", "Cơ sở", "Trưng bày"],
              [DepartmentScreen(), FacilitiesScreen(), GalleryScreen()]));
          list.add(OptionsList(
            "Chi tiết liên lạc",
            ["Điều khoản & quy định", "Về chúng tôi", "Liên hệ"],
            [TermAndConditions(), AboutUs(), ContactUsScreen()],
          ));
        }
    });
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
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Divider(
              color: LIGHT_GREY_TEXT,
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
                          Text(
                            list[index].options[i].toString(),
                            style: TextStyle(
                                fontSize: 17,
                                color: LIGHT_GREY_TEXT,
                                fontWeight: FontWeight.w500),
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

  OptionsList(this.title, this.options, this.screen);
}
