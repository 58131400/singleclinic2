import 'package:shared_preferences/shared_preferences.dart';

class CommonSharedPreferences {
  static SharedPreferences? _preferences;

  static const _keySelectedDate = "selectedDate";
  static const _keyFacilityValue = "facilityValue";
  static const _keyDepartmentId = "departmentId";
  static const _keyDepartmentValue = "departmentValue";
  static const _keyDoctorId = "doctorId";
  static const _keyFrom = "from";
  static const _keyTo = "to";
  static const _keyDoctorValue = "doctorValue";
  static const _keyServiceId = "serviceId";
  static const _keyServiceValue = "serviceValue";
  static const _keyMessage = "message";
  static const _keyDay = "day";
  static const _keyIsBookByDate = "isBookByDate";

  static const _keyName = "name";
  static const _keyUserId = "id";
  static const _keyPhoneNo = "phone_no";
  static const _keyProfileImg = "profile_pic";
  static const _keyNewProfileImg = "new_Path";
  static const _keyUserType = "usertype";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();
  static Future clear() async => await _preferences!.clear();

  static Future reload() async => await _preferences!.reload();

  static String? getSelectedDate() => _preferences!.getString(_keySelectedDate);
  static int? getUserId() => _preferences!.getInt(_keyUserId);
  static String? getPhoneNumber() => _preferences!.getString(_keyPhoneNo);
  static String? getName() => _preferences!.getString(_keyName);
  static String? getFacilityValue() =>
      _preferences!.getString(_keyFacilityValue);
  static int? getDepartmentId() => _preferences!.getInt(_keyDepartmentId);
  static String? getDepartmentValue() =>
      _preferences!.getString(_keyDepartmentValue);
  static int? getDoctorId() => _preferences!.getInt(_keyDoctorId);
  static String? getDoctorValue() => _preferences!.getString(_keyDoctorValue);
  static String? getFrom() => _preferences!.getString(_keyFrom);
  static String? getTo() => _preferences!.getString(_keyTo);
  static int? getServiceId() => _preferences!.getInt(_keyServiceId);
  static String? getServiceValue() => _preferences!.getString(_keyServiceValue);
  static String? getMessage() => _preferences!.getString(_keyMessage);
  static bool? getIsBookByDate() => _preferences!.getBool(_keyIsBookByDate);
  static int? getDay() => _preferences!.getInt(_keyDay);
  static String? getProfileImg() => _preferences!.getString(_keyProfileImg);
  static String? getNewProfileImg() =>
      _preferences!.getString(_keyNewProfileImg);
  static String? getUserType() => _preferences!.getString(_keyUserType);

  static Future setSelectedDate(DateTime dateTime) async => await _preferences!
      .setString(_keySelectedDate, dateTime.toString().substring(0, 10));
  static Future setUserId(int userId) async =>
      await _preferences!.setInt(_keyUserId, userId);
  static Future setName(String name) async =>
      await _preferences!.setString(_keyName, name);
  static Future setFacilityValue(String value) async =>
      await _preferences!.setString(_keyFacilityValue, value);
  static Future setDepartmentId(int value) async =>
      await _preferences!.setInt(_keyDepartmentId, value);
  static Future setDepartmentValue(String value) async =>
      await _preferences!.setString(_keyDepartmentValue, value);
  static Future setDoctorId(int value) async =>
      await _preferences!.setInt(_keyDoctorId, value);
  static Future setDoctorValue(String value) async =>
      await _preferences!.setString(_keyDoctorValue, value);
  static Future setFrom(String value) async =>
      await _preferences!.setString(_keyFrom, value);
  static Future setTo(String value) async =>
      await _preferences!.setString(_keyTo, value);
  static Future setServiceId(int value) async =>
      await _preferences!.setInt(_keyServiceId, value);
  static Future setServiceValue(String value) async =>
      await _preferences!.setString(_keyServiceValue, value);
  static Future setMessage(String value) async =>
      await _preferences!.setString(_keyMessage, value);
  static Future setIsBookByDate(bool value) async =>
      await _preferences!.setBool(_keyIsBookByDate, value);
  static Future setPhoneNumber(String value) async =>
      await _preferences!.setString(_keyPhoneNo, value);
  static Future setDay(int value) async =>
      await _preferences!.setInt(_keyDay, value);
  static Future setProfileImg(String path) async =>
      await _preferences!.setString(_keyProfileImg, path);
  static Future setNewProfileImg(String path) async =>
      await _preferences!.setString(_keyNewProfileImg, path);
  static Future setUserType(String usertype) async =>
      await _preferences!.setString(_keyUserType, usertype);

  static Future clearBookAppointmentInfo() async =>
      await SharedPreferences.getInstance().then((value) {
        value.remove("selectedDate");
        value.remove("facilityValue");
        value.remove('departmentValue');
        value.remove('departmentId');
        value.remove('doctorValue');
        value.remove('doctorId');
        value.remove('from');
        value.remove('to');
        value.remove('day');
        value.remove('serviceId');
        value.remove('serviceValue');
        value.remove('message');
        value.remove('isBookByDate');
      });

  static Future clearUserImage() async => await _preferences!.remove("_keyNewProfileImg");
}
