import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/modals/DepartmentsList.dart';
import 'package:singleclinic/modals/DoctorsAndServices.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:singleclinic/modals/FacilitiesClass.dart';
import 'package:singleclinic/screens/DoctorDetail.dart';
import 'package:singleclinic/screens/DoctorList.dart';
import 'package:singleclinic/main.dart';
import 'package:singleclinic/utils/shared_preferences_utils.dart';

class BookAppointment extends StatefulWidget {
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
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

  TextEditingController? nameController;
  TextEditingController? phoneController;

  DateTime now = DateTime.parse(DateTime.now().toString().substring(0, 10));
  DateTime? selectedDate;
  //TimeOfDay selectedTime = TimeOfDay.now();

  String? from, to, formatedTime = "";
  int? fromHour, fromMinute;
  int? pickedDay;
  DoctorsAndServices? doctorsAndServices;
  bool isLoadingDoctorAndServices = false;
  bool isAppointmentMadeSuccessfully = false;
  bool? isBookByDate;
  DepartmentsList? departmentsList;
  FacilitiesClass? facilityClass;

  String? message = "";

  @override
  void initState() {
    super.initState();
    _getDepartmentsList();
    _getFacilityList();

    userId = CommonSharedPreferences.getUserId();
    nameController =
        TextEditingController(text: CommonSharedPreferences.getName());
    phoneController =
        TextEditingController(text: CommonSharedPreferences.getPhoneNumber());
    isBookByDate = (CommonSharedPreferences.getIsBookByDate() ?? false);
    if (CommonSharedPreferences.getSelectedDate() != null)
      selectedDate = DateTime.parse(CommonSharedPreferences.getSelectedDate()!);
    else
      selectedDate = getInitialDate();
    facilityValue = CommonSharedPreferences.getFacilityValue();
    departmentValue = CommonSharedPreferences.getDepartmentValue();
    departmentId = CommonSharedPreferences.getDepartmentId();
    doctorValue = CommonSharedPreferences.getDoctorValue();
    doctorId = CommonSharedPreferences.getDoctorId();
    from = CommonSharedPreferences.getFrom();
    to = CommonSharedPreferences.getTo();
    if (from != null && to != null) {
      formatedTime = from! + ' - ' + to!;
      fromHour = int.parse(from!.substring(0, 2));
      fromMinute = int.parse(from!.substring(3, 5));
    }
    if (CommonSharedPreferences.getDay() != null)
      pickedDay = CommonSharedPreferences.getDay()! - 1;
    serviceId = CommonSharedPreferences.getServiceId();
    serviceValue = CommonSharedPreferences.getServiceValue();
    if (departmentId != null) fetchDoctorsAndServices(departmentId!);
    message = CommonSharedPreferences.getMessage();
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
                    CommonSharedPreferences.clearBookAppointmentInfo();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TabBarScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
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
                    _buildPatientInfo(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildAppointmentInfo(),
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

  Container _buildAppointmentInfo() {
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
            _buildFacilityList(),
            SizedBox(
              height: 16,
            ),
            isBookByDate == true
                ? Column(
                    children: [
                      _buildDate(),
                      _buildDepartmentList(),
                      _buildDoctorList(),
                    ],
                  )
                : Column(
                    children: [
                      _buildDepartmentList(),
                      _buildDoctorList(),
                      _buildDate()
                    ],
                  ),
            _buildTime(),
            _buildServiceList(),
            _buildMessage(),
          ],
        ),
      ),
    );
  }

  _buildMessage() {
    return Row(children: [
      Expanded(
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.message,
            color: doctorValue == null ? Colors.grey[300] : NAVY_BLUE,
          ),
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
                      AppLocalizations.of(context)!.message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              TextField(
                enabled: doctorValue == null ? false : true,
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
                  SharedPreferences.getInstance()
                      .then((value) => value.setString('messages', val));
                  setState(() {
                    message = val;
                  });
                },
              ),
            ],
          ))
    ]);
  }

  _buildTime() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.clock,
                  color: doctorValue == null ? Colors.grey[300] : NAVY_BLUE,
                ),
              ),
              flex: 1,
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  formatedTime == ""
                      ? Container()
                      : Text(
                          AppLocalizations.of(context)!.time,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                  InkWell(
                    onTap: () {
                      doctorValue == null ? null : _selectTime(context);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        formatedTime == ""
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
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _buildDate() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.calendar_month,
                  color: (isBookByDate == false && doctorValue == null)
                      ? Colors.grey[300]
                      : NAVY_BLUE,
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
                    onTap: (isBookByDate == false && doctorValue == null)
                        ? () {}
                        : () => _selectDate(context),
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
                                  Text(
                                      selectedDate == null
                                          ? getInitialDate()
                                              .toString()
                                              .substring(0, 10)
                                          : selectedDate
                                              .toString()
                                              .substring(0, 10),
                                      style: (isBookByDate == false &&
                                              doctorValue == null)
                                          ? Theme.of(context)
                                              .textTheme
                                              .apply(bodyColor: LIGHT_GREY_TEXT)
                                              .bodyText1
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyText1),
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
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _buildPatientInfo() {
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

  _buildServiceList() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Center(
                  child: FaIcon(
                FontAwesomeIcons.briefcaseMedical,
                color: doctorValue == null ? Colors.grey[300] : NAVY_BLUE,
              )),
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
                      isLoadingDoctorAndServices
                          ? AppLocalizations.of(context)!.loading
                          : AppLocalizations.of(context)!.select_services,
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
                    items: doctorsAndServices == null || doctorValue == null
                        ? []
                        : List.generate(
                            doctorsAndServices!.data!.services!.length,
                            (index) {
                            return DropdownMenuItem(
                              value: doctorsAndServices!
                                      .data!.services![index].name! +
                                  index.toString(),
                              child: Text(doctorsAndServices!
                                  .data!.services![index].name!),
                              key: UniqueKey(),
                              onTap: () {
                                setState(() {
                                  serviceId = doctorsAndServices!
                                      .data!.services![index].id;
                                  SharedPreferences.getInstance().then(
                                      (value) => value.setInt(
                                          'serviceId', serviceId!));
                                });
                              },
                            );
                          }),
                    onChanged: (val) {
                      print(val);
                      SharedPreferences.getInstance().then((value) =>
                          value.setString('serviceValue', val.toString()));
                      setState(() {
                        serviceValue = val.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _buildDoctorList() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 1,
                child: Center(
                    child: FaIcon(FontAwesomeIcons.userDoctor,
                        color: departmentValue == null
                            ? Colors.grey[300]
                            : NAVY_BLUE))),
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
                    onTap: departmentValue == null
                        ? () {}
                        : () {
                            _selectDoctorAndTime(context, departmentId!);
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
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _buildDepartmentList() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 1,
                child: Center(
                    child: FaIcon(FontAwesomeIcons.stethoscope,
                        color: NAVY_BLUE))),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                    items:
                        List.generate(departmentsList!.data!.length, (index) {
                      return DropdownMenuItem(
                        value: departmentsList!.data![index].name,
                        child: Text(
                            departmentsList!.data![index].name.toString(),
                            style: Theme.of(context).textTheme.bodyText1),
                        onTap: () async {
                          setState(() {
                            departmentId = departmentsList!.data![index].id;
                            print(departmentId);
                          });
                          SharedPreferences.getInstance().then((value) =>
                              value.setInt("departmentId", departmentId!));
                          await fetchDoctorsAndServices(
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
                    onChanged: (val) async {
                      print(val);
                      setState(() {
                        departmentValue = val.toString();
                        doctorValue = null;
                        doctorId = null;
                        serviceId = null;
                        serviceValue = null;
                        formatedTime = "";
                      });
                      await SharedPreferences.getInstance().then((value) =>
                          value.setString('departmentValue', departmentValue!));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _buildFacilityList() {
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
                CommonSharedPreferences.setFacilityValue(facilityValue!);
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
                _bookAppointment();
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
        initialDate: getInitialDate(),
        initialDatePickerMode: DatePickerMode.day,
        currentDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: getLastDay(),
        selectableDayPredicate: (day) {
          return isBookByDate == true ? true : getDayEnable(day);
        });

    if (picked != null) {
      CommonSharedPreferences.setSelectedDate(selectedDate!);

      setState(() {
        selectedDate = picked;
        doctorValue = null;
        doctorId = null;
        serviceId = null;
        serviceValue = null;
        formatedTime = "";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    await SharedPreferences.getInstance().then((value) {
      value.setString("selectedDate", selectedDate.toString());
    });
    print(selectedDate);
    var picked = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorDetails(doctorId!),
        ));
    print(picked);
  }

  _getDepartmentsList() async {
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

  _getFacilityList() async {
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

  fetchDoctorsAndServices(int departmentId) async {
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/getdoctorandservicebydeptid?department_id=$departmentId"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorsAndServices = DoctorsAndServices.fromJson(jsonResponse);
        isLoadingDoctorAndServices = false;
      });
    }
  }

  _bookAppointment() async {
    print('-------------function book appointment-----------');
    if (departmentId == null ||
        serviceId == null ||
        doctorId == null ||
        facilityValue == null) {
      messageDialog(AppLocalizations.of(context)!.error,
          AppLocalizations.of(context)!.enter_all_fields_to_make_appointment);
    } else {
      if (!isValidTime()) {
        messageDialog(AppLocalizations.of(context)!.error,
            AppLocalizations.of(context)!.valid_time_choose);
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
            from! +
            "\n" +
            "user_id:" +
            userId.toString() +
            "\n" +
            "messages:" +
            message!);
        final response =
            await post(Uri.parse("$SERVER_ADDRESS/api/bookappointment"), body: {
          "department_id": departmentId.toString(),
          "service_id": serviceId.toString(),
          "doctor_id": doctorId.toString(),
          "name": nameController!.text,
          "phone_no": phoneController!.text,
          "date": selectedDate.toString().substring(0, 10),
          "time": from,
          "user_id": userId.toString(),
          "messages": message,
        });

        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (response.statusCode == 200 && jsonResponse['status'] == 1) {
          print("Success");
          CommonSharedPreferences.clearBookAppointmentInfo();
          setState(() {
            Navigator.pop(context);
            messageDialog(AppLocalizations.of(context)!.successful,
                AppLocalizations.of(context)!.book_appointment_successful);
            isAppointmentMadeSuccessfully = true;
          });
        } else {
          Navigator.pop(context);
          messageDialog(AppLocalizations.of(context)!.error,
              AppLocalizations.of(context)!.book_appointment_failled);
        }
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
                    Navigator.pop(context);
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

  _selectDoctorAndTime(BuildContext context, int id) async {
    await SharedPreferences.getInstance().then((value) {
      value.setString("selectedDate", selectedDate.toString());
    });
    print(selectedDate);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorList(id),
        ));
  }

  bool isValidTime() {
    print('---------------------function is valid time---------');
    selectedDate = DateTime.parse(selectedDate.toString().substring(0, 10));
    print('selectedDate: $selectedDate');
    if (selectedDate!.isBefore(now) ||
        (selectedDate!.isAtSameMomentAs(now) &&
            fromHour! < DateTime.now().hour) ||
        (selectedDate!.isAtSameMomentAs(now) &&
            fromHour == DateTime.now().hour &&
            fromMinute! <= DateTime.now().minute))
      return false;
    else
      return true;
  }

  bool getDayEnable(DateTime day) {
    print("----------function getDayEnable");
    // if (pickedDay == null) return true;
    if (day.weekday == pickedDay) {
      print(day);
      return true;
    } else
      return false;
  }

  getInitialDate() {
    print("--------------function getInitialDate");
    if (isBookByDate! || pickedDay == null)
      return DateTime.now();
    else {
      var temp = DateTime.now();
      while (temp.weekday != pickedDay) {
        print(temp.weekday);
        temp = temp.add(Duration(days: 1));
      }
      return temp;
    }
  }

  getLastDay() {
    print("---------fucntion getlastday---------");
    var lastDay;
    if (now.month == DateTime.december)
      lastDay = DateTime(now.year + 1, DateTime.january,
          DateTime(now.year + 1, now.month + 2, 0).day);
    else {
      lastDay = DateTime(
          now.year, now.month + 1, DateTime(now.year, now.month + 2, 0).day);
    }
    print(lastDay);
    return lastDay;
  }
}
