import 'package:beanalyze/configure/constants.dart';
import 'package:beanalyze/home/about.dart';
import 'package:beanalyze/home/object_detection_album.dart';
import 'package:beanalyze/home/object_detection_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: // isPortrait ?
      AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: header,
        iconTheme: IconThemeData(color: texticon),
        title: Center(
          child: Text(
            "Aplikasi Deteksi Jenis Biji Kopi",
            style: TextStyle(
              fontSize: 20,
              // color: textheader,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          About(),
          ObjectDetectionCamera(),
          ObjectDetectionAlbum(),
        ],
      ),
      bottomNavigationBar: Container(
        color: header,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: texticon,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[400]!,
              backgroundColor: header,
              tabs: [
                GButton(
                  iconColor: texticon,
                  textColor: texticon,
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  iconColor: texticon,
                  textColor: texticon,
                  icon: CupertinoIcons.camera,
                  text: 'Ambil Foto',
                ),
                GButton(
                  iconColor: texticon,
                  textColor: texticon,
                  icon: CupertinoIcons.folder_open,
                  text: 'Album',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
