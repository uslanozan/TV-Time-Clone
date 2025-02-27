import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  print("Firestore test başlatıldı...");

  try {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection("User").get();

    if (querySnapshot.docs.isEmpty) {
      print("Firestore 'User' koleksiyonunda hiç veri yok!");
    } else {
      for (var doc in querySnapshot.docs) {
        print("User ID: ${doc.id}");
        print("Email: ${doc["email"]}");
        print("Password: ${doc["password"]}");
        print("-------------------------");
      }
    }
  } catch (e) {
    print("Firestore okuma hatası: $e");
  }
}
