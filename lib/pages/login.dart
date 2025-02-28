import 'dart:convert';
import 'dart:ffi';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvtime/pages/home.dart';
import 'package:tvtime/pages/movies.dart';
import 'package:tvtime/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget{
  const Login({Key? key}) : super(key: key);

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{

   var db = FirebaseFirestore.instance;


  // Form durum kontrolü için
  final _formKey = GlobalKey<FormState>();

  // Input almak için
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dispose bellek kullanımı içi yapılan ve
  // widget kullanılmadığı zaman bellek kullanmaması için
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

   Future<void> saveUserId(String userId) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.setString("userId", userId);
     print(userId);
   }

   Future<bool> checkUserCredentials(String email, String password) async {
     String hashedPassword = hashPassword(password); // Şifreyi hashle
      print(db);
     try {
       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
           .collection("User")
           .where("email", isEqualTo: email.trim()) // Email eşleşen kayıtları getir
           .where("password", isEqualTo: hashedPassword) // Hashlenmiş şifreyi karşılaştır
           .get();

       if (querySnapshot.docs.isNotEmpty) {
         print("Giriş başarılı!"); // Kullanıcı bulundu
         saveUserId(querySnapshot.docs.first.id);
         return true;
       } else {
         print(email);
         print(hashedPassword);
         print("Hatalı email veya şifre!");
         return false;
       }
     } catch (error) {
       print("Hata: $error");
       return false;
     }
   }

  // SHA-256 Hash Fonksiyonu
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // String'i byte array'e çevir
    var digest = sha256.convert(bytes); // SHA-256 ile hashle
    return digest.toString();
  }


   void _login() async {
     if (_formKey.currentState!.validate()) {
       bool isValidUser = await checkUserCredentials(
         _emailController.text,
         _passwordController.text,
       );

       if (isValidUser) {
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => HomePage()),
         );
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Hatalı email veya şifre!'),
             duration: Duration(seconds: 2),
             backgroundColor: Colors.red,
           ),
         );
       }
     }
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş yap"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Form widget'ı içinde doğrulama
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email girişi için form
              TextFormField(
                controller: _emailController, // Controller input tutar
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Lütfen email adresinizi girin";
                  }
                  // Email kontrolü için regex
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "Geçerli bir email adresi girin";
                  }
                  return null; // Hata yoksa null
                },
              ),

              // Widget'lar arası boşluk
              const SizedBox(height: 16),

              // Şifre girişi için form
              TextFormField(
                controller: _passwordController, // Şifre input'u tutar
                decoration: const InputDecoration(
                  labelText: "Şifre",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Lütfen şifrenizi girin";
                  }
                },
              ),

              const SizedBox(height: 24,),

              // Giriş yap butonu
              ElevatedButton(
                onPressed: _login,
                child: const Text("Giriş Yap"),
              ),

              // Üye ol butonu
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } ,
                  child: const Text("Üye Ol")
              ),
            ],
          ),
        ),
      ),
    );
  }
}