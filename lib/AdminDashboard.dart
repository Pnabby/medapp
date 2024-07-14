import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work/AdminHome.dart';
import 'package:work/AdminProfile.dart';

import 'Marker.dart';
import 'Profile.dart';
class AdminDashboard extends StatefulWidget {
  final int initialIndex; // Add an initialIndex parameter

  const AdminDashboard({super.key, this.initialIndex = 0});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late int _selectedIndex;
  bool _selectedfloat = false;
  late  final List<Widget>_pages;
  var _selectcolor = Colors.green.shade900;
  var _unselectcolor = Colors.green.shade100;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      AdminHome(),
      Marker(),
      //Book(),
      AdminProfile(),
    ];
  }


  void ontap(int index ){
      setState(() {
        _selectedIndex = index;
        //print(index);
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Use the current index to show the corresponding page in the body of the scaffold
      body:IndexedStack(index: _selectedIndex,children: _pages,),
      bottomNavigationBar: BottomNavigationBar(
          iconSize: 30,
          selectedItemColor: _selectcolor,
          //unselectedItemColor: Colors.purple[400],
          selectedFontSize: 16,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, color: (_selectedIndex == 0)? _selectcolor:Colors.grey,),
              label: ' ',
              //backgroundColor: Colors.orange
            ),

            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.wifi, color: (_selectedIndex == 1)? _selectcolor:Colors.grey),
              label: ' ',
              //backgroundColor: Colors.orange
            ),
            /*BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.book,color: (_selectedIndex == 2)? _selectcolor:Colors.grey),
              label: ' ',
              //backgroundColor: Colors.orange
            ),*/
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidUser,color: (_selectedIndex == 2)? _selectcolor:Colors.grey),
              label: ' ',
              //backgroundColor: Colors.orange
            ),
          ],
          // Add an onTap property and pass a function that takes an index as a parameter
          onTap: ontap

      ),
    );
  }
}
