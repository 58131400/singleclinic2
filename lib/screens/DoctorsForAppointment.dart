import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../modals/DoctorDetails.dart';
import '../modals/DoctorsList.dart';

class DoctorsForAppointment extends StatefulWidget {
  const DoctorsForAppointment({Key? key, this.departmentID, this.bookDate})
      : super(key: key);

  final String? departmentID;
  final DateTime? bookDate;

  @override
  State<DoctorsForAppointment> createState() => _DoctorsForAppointmentState();
}

class _DoctorsForAppointmentState extends State<DoctorsForAppointment> {
  DoctorsList? doctorsList;
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  List<InnerData> myList = [];
  String nextUrl = "";
  bool isLoggedIn = false;
  String working_day = "";
  GlobalKey listLength = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDoctorsList();

    SharedPreferences.getInstance().then((value) {
      setState(() {
        isLoggedIn = value.getBool("isLoggedIn") ?? false;
      });
    });
    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        print("Loadmore");
        _loadMoreFunc();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("go to BookAppointment");
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          leading: Container(),
          flexibleSpace: header(),
          elevation: 0,
          backgroundColor: WHITE,
        ),
        body: body(),
      ),
    );
  }

  header() {
    return SafeArea(
        child: Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 18,
          ),
          constraints: BoxConstraints(maxWidth: 30, minWidth: 10),
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => TabBarScreen(),
            //     ));
          },
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          AppLocalizations.of(context)!.appointment.toUpperCase(),
          style: TextStyle(
              color: NAVY_BLUE, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ],
    ));
  }

  body() {
    return doctorsList == null
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : SingleChildScrollView(
            controller: scrollController,
            key: listLength,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: myList.length,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return doctorDetailTile(
                        imageUrl: myList[index].image!,
                        name: myList[index].name!,
                        department: myList[index].departmentName!,
                        aboutUs: myList[index].aboutUs!,
                        id: myList[index].id!,
                      );
                    },
                  )
                ],
              ),
            ),
          );
  }

  doctorDetailTile(
      {String? imageUrl,
      String? name,
      String? department,
      String? aboutUs,
      int? id}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [FaIcon(FontAwesomeIcons.userDoctor), Text(name!)],
            ),
            FutureBuilder(
                future: fetchDoctorTime(id!),
                builder: ((context, snapshot) {
                  return Text('');
                }))
          ],
        ),
      ),
    );
  }

  fetchDoctorsList() async {
    final response = await get(
      Uri.parse("$SERVER_ADDRESS/api/listofdoctorbydepartment?department_id=0"),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(response.body);

      setState(() {
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        myList.addAll(doctorsList!.data!.data!);
        nextUrl = doctorsList!.data!.nextPageUrl!;
        _loadMoreFunc();
      });
    }
  }

  void _loadMoreFunc() async {
    print(nextUrl);
    if (nextUrl != "null" && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final response = await get(
        Uri.parse("$nextUrl&department_id=0"),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        print(response.body);
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        setState(() {
          myList.addAll(doctorsList!.data!.data!);
          nextUrl = doctorsList!.data!.nextPageUrl!;
          isLoadingMore = false;
        });
      }
    }
  }

  fetchDoctorTime(int id) async {
    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/doctordetails?id=${id}"));

    print(response.request);

    final jsonResponse = jsonDecode(response.body);

    print(jsonResponse);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        var doctorDetail = DoctorDetail.fromJson(jsonResponse);
        // if(doctorDetail.data.timeTabledata)

        // working_day =
      });
    }
  }
}
