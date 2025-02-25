
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme_manager.dart';

class User{
  final int followers;
  final int following;
  final int comment;
  final String username;
  final String backgroundURL;

  User(this.followers, this.following, this.username, this.backgroundURL, this.comment);
}

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>{
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    _editProfile(){}
    _showFavoriteSeries(){}
    _showFavoriteMovies(){}

    String mod = "Mod Ayarı";

    return Column(

      children: [

        Stack(
          alignment: Alignment.center, // Elemanları ortalamak için
          children: [
            // Arka Plan (Kapak Fotoğrafı)
            Container(
              height: 200, // Kapak fotoğrafının yüksekliği
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/scarface_background.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), // %50 şeffaflık ekler
                    BlendMode.darken, // Karanlık bir efekt verir
                  ),
                ),
              ),
            ),

            // Profil Fotoğrafı ve Kullanıcı Bilgileri (Row içinde)
            Positioned(
              bottom: 4, // Profil fotoğrafını biraz aşağı kaydırdık
              left: 20, // Soldan boşluk ekledik
              right: 20, // Sağdan boşluk ekledik
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Elemanları sola hizaladık
                children: [
                  // Profil Fotoğrafı
                  CircleAvatar(
                    radius: 33, // Profil fotoğrafının boyutu
                    backgroundColor: Colors.white, // Çerçeve efekti için
                    child: CircleAvatar(
                      radius: 30, // Gerçek profil fotoğrafı
                      backgroundImage: AssetImage("assets/images/homelander_profile_picture.png"),
                    ),
                  ),
                  const SizedBox(width: 10), // Profil ile Column arasında boşluk

                  // Kullanıcı Bilgileri (Username + Buton)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Sola hizalama
                    children: [
                      Text(
                        "USERNAME",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Profili düzenleme işlemi burada olacak
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20), // Buton iç padding azaltıldı
                          textStyle: TextStyle(fontSize: 14), // Buton metni küçültüldü
                        ),
                        child: const Text("Düzenle"),

                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
          children: [
            Column(
              children: [
                Text("1"),
                Text("Takip Edilenler")
              ],
            ),
            //SizedBox(width: 10,),
            Column(
              children: [
                Text("2"),
                Text("Takipçiler")
              ],

            ),
            //SizedBox(width: 10,),
            Column(
              children: [
                Text("3"),
                Text("Yorum")
              ],

            ),
            Column(
              children: [
                Text(mod),
                Switch(
                  value: themeManager.themeMode == ThemeMode.dark,
                  onChanged: (value){
                    themeManager.toggleTheme();
                    //TODO: Stateful widget yapıp text'i değiştir.
                    mod = "Karanlık Mod";
                  },
                ),
              ],
            ),
          ],
        ),
        Container(
          alignment: Alignment.centerLeft, // Butonu sola hizalar
          child: ElevatedButton(
            onPressed: _showFavoriteMovies,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Buton boyutunu metin ve ikon kadar yapar
              children: [
                Text("Favori Filmler"), // Metin
                SizedBox(width: 5), // Metin ile ikon arasında boşluk
                Icon(Icons.arrow_forward_ios), // İkon
              ],
            ),
          ),
        ),
        SizedBox(height: 10,),
        Container(
          alignment: Alignment.centerLeft, // Butonu sola hizalar
          child: ElevatedButton(
            onPressed: _showFavoriteSeries,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Buton boyutunu metin ve ikon kadar yapar
              children: [
                Text("Favori Diziler"), // Metin
                SizedBox(width: 5), // Metin ile ikon arasında boşluk
                Icon(Icons.arrow_forward_ios), // İkon
              ],
            ),
          ),
        )




      ],
    );




    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(mod),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (value){
                themeManager.toggleTheme();
                //TODO: Stateful widget yapıp text'i değiştir.
                mod = "Karanlık Mod";
              },
            ),
          ],
        ),
      ],
    );


  }
}
