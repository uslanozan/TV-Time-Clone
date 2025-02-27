import 'package:flutter/material.dart';
import 'package:tvtime/pages/home.dart';
import 'package:tvtime/pages/movies.dart';
import 'package:tvtime/pages/profile.dart';

class LoginOld extends StatefulWidget{
  const LoginOld({Key? key}) : super(key: key);

  _LoginStateOld createState() => _LoginStateOld();
}

class _LoginStateOld extends State<LoginOld>{

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

  void _login() {
    // Başarılı

    if (_formKey.currentState!.validate()) {
      print("Giriş başarılı: ${_emailController.text}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );

      //TODO: Burada Firebase ve session uygulaması yapılacak

    }


    // Başarısız
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş yapılamadı! Lütfen tekrar deneyin.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }

    /*
    //TODO: ÜSTTEKİ KISMI AÇ
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
    );

     */
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
                  else{
                    return "Geçersiz şifre";
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profile()),
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