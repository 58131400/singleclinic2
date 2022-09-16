import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/modals/DepartmentsList.dart';
import 'package:singleclinic/modals/DoctorsAndServices.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:singleclinic/modals/FacilitiesClass.dart';
import 'package:singleclinic/screens/DoctorsForAppointment.dart';
import 'package:singleclinic/screens/DoctorList.dart';

import 'package:table_calendar/table_calendar.dart';
import '../main.dart';
import '../modals/DoctorDetails.dart';

class BookAppointment extends StatefulWidget {
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
  final bool? isBookByDate;
  const BookAppointment({super.key, this.isBookByDate});
}

class _BookAppointmentState extends State<BookAppointment> {
  String? departmentValue;
  String? doctorValue;
  String? serviceValue;
  String? facilityValue;

  int? doctorId;
  int? serviceId;
  int? departmentId;
  int? userId;
  int? facilityId;

  String? selectedFormattedDate;
  TextEditingController? nameController;
  TextEditingController? phoneController;
  String? day;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String? _hour, _minute, _time = " ", formatedTime;

  DoctorsAndServices? doctorsAndServices;
  bool isLoadingDoctorAndServices = false;
  bool isAppointmentMadeSuccessfully = false;
  List<String> monthsList = [
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  DepartmentsList? departmentsList;
  FacilitiesClass? facilityClass;

  String message = "";

  @override
  void initState() {
    super.initState();
    selectedFormattedDate = selectedDate.day.toString() +
        " " +
        monthsList[selectedDate.month] +
        ", " +
        selectedDate.year.toString();
    _time = "";

    getDepartmentsList();
    getFacilityList();

    SharedPreferences.getInstance().then((value) {
      userId = value.getInt("id");
      nameController = TextEditingController(text: value.getString("name"));
      phoneController =
          TextEditingController(text: value.getString("phone_no"));

      print('User ID: $userId');
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabBarScreen(),
                        ));
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AppLocalizations.of(context)!.appointment.toUpperCase(),
                  style: TextStyle(
                      color: NAVY_BLUE,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    if (departmentsList == null || facilityClass == null) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPatientInfo(),
                    SizedBox(
                      height: 8,
                    ),
                    buildAppointmentInfo(),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomButtons(),
        ],
      );
    }
  }

  Container buildAppointmentInfo() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(2)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 16, 8, 32),
        child: Column(
          children: [
            Row(
              children: [
                FaIcon(FontAwesomeIcons.calendarCheck),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.appointment_info,
                  style: Theme.of(context).textTheme.titleSmall,
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            buildFacilityList(),
            SizedBox(
              height: 16,
            ),
            widget.isBookByDate == true ? buildDate() : buildDoctorList(),
            SizedBox(
              height: 16,
            ),
            buildDepartmentList(),
            SizedBox(
              height: 16,
            ),
            widget.isBookByDate == true ? buildDoctorList() : buildDate(),
            SizedBox(
              height: 16,
            ),
            buildServiceList(),
            SizedBox(
              height: 16,
            ),
            buildTime(),
            SizedBox(
              height: 16,
            ),
            buildMessage(),
          ],
        ),
      ),
    );
  }

  buildMessage() {
    return Row(children: [
      Expanded(
        child: Center(
          child: FaIcon(FontAwesomeIcons.message),
        ),
        flex: 1,
      ),
      Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message == ""
                  ? Container()
                  : Text(
                      AppLocalizations.of(context)!.write_your_message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              TextField(
                maxLines: 3,
                minLines: 1,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.write_your_message,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: LIGHT_GREY_TEXT, width: 0.5),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: LIGHT_GREY_TEXT, width: 0.5),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: LIGHT_GREY_TEXT, width: 0.5),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    message = val;
                  });
                },
              ),
            ],
          ))
    ]);
  }

  buildTime() {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: FaIcon(FontAwesomeIcons.clock),
          ),
          flex: 1,
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _time == ""
                  ? Container()
                  : Text(
                      AppLocalizations.of(context)!.time,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              InkWell(
                onTap: () {
                  // _selectTime(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    _time == ""
                        ? Text(
                            AppLocalizations.of(context)!.select_time,
                            style: Theme.of(context)
                                .textTheme
                                .apply(bodyColor: LIGHT_GREY_TEXT)
                                .bodyText1,
                          )
                        : Text(
                            formatedTime!,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                    Divider(
                      color: LIGHT_GREY_TEXT,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row buildDate() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.calendar_month,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.date,
                  style: Theme.of(context).textTheme.bodySmall),
              InkWell(
                onTap: () => _selectDate(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selectedFormattedDate.toString(),
                                  style: Theme.of(context).textTheme.bodyText1),
                              Divider(
                                color: LIGHT_GREY_TEXT,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildPatientInfo() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 16, 8, 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white,
      ),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(FontAwesomeIcons.circleUser),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.patient_profile,
                  style: Theme.of(context).textTheme.titleSmall,
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              AppLocalizations.of(context)!.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
                controller: nameController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    isCollapsed: true),
                style: Theme.of(context).textTheme.bodyText1),
            SizedBox(
              height: 16,
            ),
            Text(
              AppLocalizations.of(context)!.phone_number,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    isCollapsed: true),
                style: Theme.of(context).textTheme.bodyText1),
          ],
        ),
      ),
    );
  }

  buildServiceList() {
    return Row(
      children: [
        Expanded(
          child: Center(child: FaIcon(FontAwesomeIcons.briefcaseMedical)),
          flex: 1,
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              serviceValue == null
                  ? Container()
                  : Text(
                      AppLocalizations.of(context)!.services,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  isLoadingDoctorAndServices ? LOADING : SELECT_SERVICES,
                  style: Theme.of(context)
                      .textTheme
                      .apply(bodyColor: LIGHT_GREY_TEXT)
                      .bodyText1,
                ),
                icon: Image.asset(
                  "assets/bookappointment/down-arrow.png",
                  height: 15,
                  width: 15,
                ),
                value: serviceValue,
                items: doctorsAndServices == null
                    ? []
                    : List.generate(doctorsAndServices!.data!.services!.length,
                        (index) {
                        return DropdownMenuItem(
                          value:
                              doctorsAndServices!.data!.services![index].name! +
                                  index.toString(),
                          child: Text(
                              doctorsAndServices!.data!.services![index].name!),
                          key: UniqueKey(),
                          onTap: () {
                            setState(() {
                              serviceId =
                                  doctorsAndServices!.data!.services![index].id;
                            });
                          },
                        );
                      }),
                onChanged: (val) {
                  print(val);
                  setState(() {
                    serviceValue = val.toString();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildDoctorList() {
    return Row(
      children: [
        Expanded(
            flex: 1, child: Center(child: FaIcon(FontAwesomeIcons.userDoctor))),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              doctorValue == null
                  ? Container()
                  : Text(
                      isLoadingDoctorAndServices ? LOADING : DOCTORS,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              InkWell(
                onTap: () {
                  _selectDoctorAndTime(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    doctorValue == null
                        ? Text(
                            AppLocalizations.of(context)!.select_doctor,
                            style: Theme.of(context)
                                .textTheme
                                .apply(bodyColor: LIGHT_GREY_TEXT)
                                .bodyText1,
                          )
                        : Text(
                            doctorValue!,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                    Divider(
                      color: LIGHT_GREY_TEXT,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildDepartmentList() {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Center(child: FaIcon(FontAwesomeIcons.stethoscope))),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              departmentValue == null
                  ? Container()
                  : Text(
                      AppLocalizations.of(context)!.departments,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              DropdownButton(
                hint: Text(
                  AppLocalizations.of(context)!.select_department,
                  style: Theme.of(context)
                      .textTheme
                      .apply(bodyColor: LIGHT_GREY_TEXT)
                      .bodyText1,
                ),
                isExpanded: true,
                value: departmentValue,
                items: List.generate(departmentsList!.data!.length, (index) {
                  return DropdownMenuItem(
                    value: departmentsList!.data![index].name,
                    child: Text(departmentsList!.data![index].name.toString(),
                        style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      setState(() {
                        departmentId = departmentsList!.data![index].id;
                      });
                      fetchDoctorsAndServices(
                          departmentsList!.data![index].id!);
                    },
                    key: UniqueKey(),
                  );
                }),
                icon: Image.asset(
                  "assets/bookappointment/down-arrow.png",
                  height: 15,
                  width: 15,
                ),
                onChanged: (val) {
                  print(val);
                  setState(() {
                    departmentValue = val.toString();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildFacilityList() {
    return Row(children: [
      Expanded(
        flex: 1,
        child: Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.location_on,
          ),
        ),
      ),
      Expanded(
          flex: 5,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            facilityValue == null
                ? Container()
                : Text(
                    AppLocalizations.of(context)!.facilities,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
            DropdownButton(
              hint: Text(
                AppLocalizations.of(context)!.select_facility,
                style: Theme.of(context)
                    .textTheme
                    .apply(bodyColor: LIGHT_GREY_TEXT)
                    .bodyText1,
              ),
              isExpanded: true,
              value: facilityValue,
              items: List.generate(facilityClass!.data!.data!.length, (index) {
                return DropdownMenuItem(
                  value: facilityClass!.data!.data![index].name,
                  child: Text(
                    facilityClass!.data!.data![index].name.toString(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onTap: () {
                    setState(() {
                      facilityId = facilityClass!.data!.data![index].id;
                      print('facilityId: ' + facilityId.toString());
                    });
                  },
                  key: UniqueKey(),
                );
              }),
              icon: Image.asset(
                "assets/bookappointment/down-arrow.png",
                height: 15,
                width: 15,
              ),
              onChanged: (val) {
                print(val);
                setState(() {
                  facilityValue = val.toString();
                  print('facilityValue ' + facilityValue.toString());
                });
              },
            )
          ]))
    ]);
  }

  bottomButtons() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                bookAppointment();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(12, 5, 12, 15),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: LIME,
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.add_appointment.toUpperCase(),
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
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        currentDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));
    if (picked == null)
      return;
    else
      setState(() {
        selectedDate = picked;
        print(selectedDate.toString().substring(0, 10));
        selectedFormattedDate = selectedDate.day.toString() +
            " " +
            monthsList[selectedDate.month] +
            ", " +
            selectedDate.year.toString();

        print(selectedFormattedDate);
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      builder: (BuildContext? context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
      initialTime: selectedTime,
    );
    print(picked);
    if ((DateTime.now().minute >= selectedTime.minute &&
        DateTime.now().hour >= selectedTime.hour &&
        DateTime.now().day == selectedDate.day)) {
      //custom
      setState(() {
        if (picked != null) selectedTime = picked;
        print("-> Condition true");
      });
    } else {
      setState(() {
        print("-> Condition false");
        selectedTime = picked!;

        _hour = selectedTime.hour < 10
            ? "0" + selectedTime.hour.toString()
            : selectedTime.hour.toString();
        _minute = selectedTime.minute < 10
            ? "0" + selectedTime.minute.toString()
            : selectedTime.minute.toString();
        _time = _hour! + ":" + _minute!;

        print(_time);
      });
    }
  }

  getDepartmentsList() async {
    print('Getting departments');

    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getdepartment"));

    print(response.request);

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        departmentsList = DepartmentsList.fromJson(jsonResponse);
      });
    }
  }

  getFacilityList() async {
    print('Getting facility----------------------------');

    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/listoffacilities"));

    final jsonResponse = jsonDecode(response.body);
    print('getFacilityList response:  $jsonResponse');

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        facilityClass = FacilitiesClass.fromJson(jsonResponse);
      });
    }
  }

  fetchDoctorsAndServices(int id) async {
    setState(() {
      doctorValue = null;
      serviceValue = null;
      isLoadingDoctorAndServices = true;
      print(doctorValue.toString());
      doctorsAndServices = null;
    });
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/getdoctorandservicebydeptid?department_id=$id"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorsAndServices = DoctorsAndServices.fromJson(jsonResponse);
        isLoadingDoctorAndServices = false;
      });
    }
  }

  bookAppointment() async {
    if (departmentId == null ||
        serviceId == null ||
        doctorId == null ||
        _time == "") {
      messageDialog("Error", ENTER_ALL_FIELDS_TO_MAKE_APPOINTMENT);
    } else {
      dialog();

      print("department_id:" +
          departmentId.toString() +
          "\n" +
          "service_id:" +
          serviceId.toString() +
          "\n" +
          "doctor_id:" +
          doctorId.toString() +
          "\n" +
          "name:" +
          nameController!.text +
          "\n" +
          "phone_no:" +
          phoneController!.text +
          "\n" +
          "date:" +
          selectedDate.toString().substring(0, 10) +
          "\n" +
          "time:" +
          _time! +
          "\n" +
          "user_id:" +
          userId.toString() +
          "\n" +
          "messages:" +
          message);
      final response =
          await post(Uri.parse("$SERVER_ADDRESS/api/bookappointment"), body: {
        "department_id": departmentId.toString(),
        "service_id": serviceId.toString(),
        "doctor_id": doctorId.toString(),
        "name": nameController!.text,
        "phone_no": phoneController!.text,
        "date": selectedDate.toString().substring(0, 10),
        "time": _time,
        "user_id": userId.toString(),
        "messages": message,
      });

      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        print("Success");
        setState(() {
          Navigator.pop(context);
          messageDialog("Successful", jsonResponse['msg']);
          isAppointmentMadeSuccessfully = true;
        });
      } else {
        Navigator.pop(context);
        messageDialog("Error", jsonResponse['msg']);
      }
    }
  }

  dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.processing,
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!
                          .please_wait_while_making_appointment,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        barrierDismissible: false,
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
                  if (isAppointmentMadeSuccessfully) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabBarScreen(),
                        ));
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(backgroundColor: LIME),
                child: Text(
                  OK,
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

  _selectDoctorAndTime(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorList(),
        ));
    print('result : $result');
    if (!mounted) {
      print('mounted = false');
      return;
    } else {
      fetchDoctorDetails(result['doctorId']);
      setState(() {
        formatedTime = result['from'] + ' - ' + result['to'];
        _time = result['from'];
      });
    }
  }

  fetchDoctorDetails(int id) async {
    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/doctordetails?id=${id}"));

    print(response.request);

    final jsonResponse = jsonDecode(response.body);

    print(jsonResponse);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorValue = DoctorDetail.fromJson(jsonResponse).data!.name;
      });
    }
  }
}
