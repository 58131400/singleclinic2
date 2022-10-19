import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/modals/DoctorDetails.dart';
import 'package:singleclinic/screens/BookAppointment.dart';
import 'package:singleclinic/screens/ChatScreen.dart';
import 'package:singleclinic/screens/LoginScreen.dart';
import 'package:singleclinic/screens/ReviewScreen.dart';
import 'package:singleclinic/utils/shared_preferences_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

class DoctorDetails extends StatefulWidget {
  final int id;

  DoctorDetails(this.id);

  @override
  _DoctorDetailsState createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  DoctorDetail? doctorDetail;
  int? day;
  String? from, to;
  int? tappedHour;

  List<String> weekDaysList = [
    SUNDAY,
    MONDAY,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY
  ];
  bool isLoggedIn = false;
  bool? isBookByDate;
  DateTime? selectedDate;
  List<TimeTabledata>? listWorking;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();

    SharedPreferences.getInstance().then((value) {
      isLoggedIn = value.getBool("isLoggedIn") ?? false;
    });
    isBookByDate = CommonSharedPreferences.getIsBookByDate() ?? false;
    if (CommonSharedPreferences.getSelectedDate() != null)
      selectedDate = DateTime.parse(CommonSharedPreferences.getSelectedDate()!);
  }

  @override
  Widget build(BuildContext context) {
    return doctorDetail == null
        ? Container(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            color: WHITE,
          )
        : SafeArea(
            child: Scaffold(
              backgroundColor: LIGHT_GREY_SCREEN_BG,
              appBar: AppBar(
                leading: Container(),
                backgroundColor: WHITE,
                flexibleSpace: header(),
              ),
              body: body(),
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
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: BLACK,
                  ),
                  constraints: BoxConstraints(maxWidth: 30, minWidth: 10),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  doctorDetail!.data!.name!,
                  style: TextStyle(
                      color: BLACK, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          _makeCall(doctorDetail!.data!.phoneNo);
                        },
                        child: Image.asset(
                          "assets/doctordetails/Phone.png",
                          height: 40,
                          width: 40,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          _sendEmail(doctorDetail!.data!.email);
                        },
                        child: Image.asset(
                          "assets/doctordetails/email.png",
                          height: 40,
                          width: 40,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                doctorProfileCard(),
                workingTimeAndServiceCard(),
              ],
            ),
          ),
        ),
        bottomButtons(),
      ],
    );
  }

  doctorProfileCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    height: 90,
                    width: 110,
                    fit: BoxFit.scaleDown,
                    imageUrl: Uri.parse(doctorDetail!.data!.image!).toString(),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Container(
                            height: 75,
                            width: 75,
                            child: Center(child: Icon(Icons.image))),
                    errorWidget: (context, url, error) => Container(
                      height: 75,
                      width: 75,
                      child: Center(
                        child: Icon(Icons.broken_image_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorDetail!.data!.name!,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          doctorDetail!.data!.departmentName!,
                          style: TextStyle(color: NAVY_BLUE, fontSize: 10),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                    doctorDetail!.data!.userId.toString())));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                doctorDetail!.data!.ratting! > 0
                                    ? "assets/doctordetails/star_active.png"
                                    : "assets/doctordetails/star_unactive.png",
                                height: 12,
                                width: 12,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Image.asset(
                                doctorDetail!.data!.ratting! > 1
                                    ? "assets/doctordetails/star_active.png"
                                    : "assets/doctordetails/star_unactive.png",
                                height: 12,
                                width: 12,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Image.asset(
                                doctorDetail!.data!.ratting! > 2
                                    ? "assets/doctordetails/star_active.png"
                                    : "assets/doctordetails/star_unactive.png",
                                height: 12,
                                width: 12,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Image.asset(
                                doctorDetail!.data!.ratting! > 3
                                    ? "assets/doctordetails/star_active.png"
                                    : "assets/doctordetails/star_unactive.png",
                                height: 12,
                                width: 12,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Image.asset(
                                doctorDetail!.data!.ratting! > 4
                                    ? "assets/doctordetails/star_active.png"
                                    : "assets/doctordetails/star_unactive.png",
                                height: 12,
                                width: 12,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            AppLocalizations.of(context)!.see_all_reviews,
                            style:
                                TextStyle(color: LIGHT_GREY_TEXT, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _launchURL(doctorDetail!.data!.facebookId);
                          },
                          child: Image.asset(
                            "assets/doctordetails/facebook.png",
                            height: 15,
                            width: 15,
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchURL(doctorDetail!.data!.twitterId);
                          },
                          child: Image.asset(
                            "assets/doctordetails/twitter.png",
                            height: 15,
                            width: 15,
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchURL(doctorDetail!.data!.googleId);
                          },
                          child: Image.asset(
                            "assets/doctordetails/google+.png",
                            height: 15,
                            width: 15,
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchURL(doctorDetail!.data!.instagramId);
                          },
                          child: Image.asset(
                            "assets/doctordetails/instagram.png",
                            height: 15,
                            width: 15,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            doctorDetail!.data!.aboutUs!,
            style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 11),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  List<TimeTabledata>? getListWorking() {
    var timeTable = doctorDetail!.data!.timeTabledata!;
    if (isBookByDate == true) {
      var dayOfWeek = selectedDate!.weekday + 1;
      List<TimeTabledata> list = [];

      for (var element in timeTable) {
        if (element.day == dayOfWeek) {
          list.add(element);
          break;
        }
      }
      return list;
    } else
      return timeTable;
  }

  workingTimeAndServiceCard() {
    return Container(
      color: WHITE,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.select_working_time,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
          ),
          SizedBox(
            height: 8,
          ),
          listWorking!.length == 0
              ? Text(
                  AppLocalizations.of(context)!.no_working_time,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3,
                      mainAxisSpacing: 5),
                  itemCount: listWorking!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          tappedHour = index;
                          day = listWorking![index].day;
                          from = listWorking![index].from;
                          to = listWorking![index].to;

                          print('is tapped time : $tappedHour');
                        });
                      },
                      child: Container(
                        decoration: tappedHour != index
                            ? null
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: LIME)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Image.asset(
                                      "assets/doctordetails/free-time.png"),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isBookByDate == true
                                      ? SizedBox.shrink()
                                      : Text(
                                          weekDaysList[
                                              listWorking![index].day! - 1],
                                          style: TextStyle(
                                              color: NAVY_BLUE,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    listWorking![index].from! +
                                        " to " +
                                        listWorking![index].to!,
                                    style: TextStyle(
                                      color: LIGHT_GREY_TEXT,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          SizedBox(
            height: 15,
          ),
          Text(
            AppLocalizations.of(context)!.services,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            doctorDetail!.data!.service!,
            style: TextStyle(fontSize: 13, color: LIGHT_GREY_TEXT),
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  bottomButtons() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          isLoggedIn
              ? InkWell(
                  onTap: () {
                    print(doctorDetail!.data!.userId);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                doctorDetail!.data!.name!,
                                doctorDetail!.data!.userId.toString(),
                                userProfile: doctorDetail!.data!.image!,)));
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    margin: EdgeInsets.fromLTRB(0, 5, 6, 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: LIME,
                    ),
                    child: Image.asset("assets/doctordetails/review.png"),
                  ),
                )
              : Container(),
          Expanded(
            child: InkWell(
              onTap: () {
                if (doctorDetail!.data!.timeTabledata!.length == 0)
                  return;
                else {
                  SharedPreferences.getInstance().then((value) {
                    value.setInt('day', day!);
                    value.setString('from', from!);
                    value.setString('to', to!);
                    value.setInt('doctorId', widget.id);
                    value.setString('doctorValue', doctorDetail!.data!.name!);
                    value.setInt(
                        'departmentId', doctorDetail!.data!.departmentId!);
                    value.setString(
                        'departmentValue', doctorDetail!.data!.departmentName!);
                  });
                  isLoggedIn
                      ? Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  BookAppointment()),
                          ModalRoute.withName('/bookAppointment'),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(6, 5, 12, 15),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: doctorDetail!.data!.timeTabledata!.length == 0
                      ? Colors.grey[300]
                      : LIME,
                ),
                child: Center(
                  child: Text(
                    isLoggedIn
                        ? AppLocalizations.of(context)!.book_appointment
                        : AppLocalizations.of(context)!
                            .login_to_book_appointment,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: WHITE),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  fetchDoctorDetails() async {
    final response = await get(
        Uri.parse("$SERVER_ADDRESS/api/doctordetails?id=${widget.id}"));

    print(response.request);

    final jsonResponse = jsonDecode(response.body);

    print(jsonResponse);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorDetail = DoctorDetail.fromJson(jsonResponse);
        listWorking = getListWorking();
      });
    }
  }

  _launchURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _sendEmail(email) {
    launchUrl(Uri(
      scheme: 'mailto',
      path: email,
    ));
  }

  _makeCall(email) {
    launchUrl(Uri(
      scheme: 'tel',
      path: email,
    ));
  }
}
