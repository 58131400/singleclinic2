import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class CommonFirebaseDatabase {
  static updateUserProfileToDatabase(Map<String, dynamic> info) async {
    if (info["id"] != null) {
      await FirebaseDatabase.instance
          .ref()
          .child(info["id"].toString())
          .update({
        "name": info["name"],
        "usertype": info["usertype"],
        "profile": info["usertype"].toString() == "1"
            ? "profile/" + info["profile_pic"].toString().split("/").last
            : "doctor/" + info["profile_pic"].toString().split("/").last
      }).catchError((e) => print(e.toString()));
      print("doctor/" + info["profile_pic"].toString().split("/").last);
    }
  }

  static saveToken(String? tokenDevice, String id) async {
    await FirebaseDatabase.instance
        .ref()
        .child(id)
        .child("TokenList")
        .set({"device": tokenDevice}).catchError((e) => print(e.toString()));
    ;
  }
}
