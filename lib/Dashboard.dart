import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work/Book.dart';
import 'package:work/Marker.dart';
import 'package:work/Profile.dart';
import 'package:work/Scan.dart';
import 'Home.dart';
import 'package:nfc_manager/nfc_manager.dart';

void _startNFCReading() async {
  try {
    bool isAvailable = await NfcManager.instance.isAvailable();

    //check if NFC is available.
    if (isAvailable) {
      //start an NFC session and listen for NFC tags to be discovered.
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Process NFC tag, When an NFC tag is discovered, print its data to the console.
          debugPrint('NFC Tag Detected: ${tag.data}');
        },
      );
    } else {
      debugPrint('NFC not available.');
    }
  } catch (e) {
    debugPrint('Error reading NFC: $e');
  }
}

void _startNFCWriting() async {
  try {
    // check if NFC is available on the device or not.
    bool isAvailable = await NfcManager.instance.isAvailable();

    //If NFC is available, start a session to listen for NFC tags.
  if (isAvailable) {
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {

  try {
  // When an NFC tag is discovered, we check if it supports NDEF technology.
  NdefMessage message =
  NdefMessage([NdefRecord.createText('Hello, NFC!')]);
  await Ndef.from(tag)?.write(message);//If it supports NDEF, create an NDEF message and write it to the tag.
  debugPrint('Data emitted successfully');
  Uint8List payload = message.records.first.payload;
  String text = String.fromCharCodes(payload);
  debugPrint("Written data: $text");

  //stop the NFC Session
  NfcManager.instance.stopSession();
  } catch (e) {
  debugPrint('Error emitting NFC data: $e');
  }
  });
  } else {
  debugPrint('NFC not available.');
  }
  } catch (e) {
  debugPrint('Error writing to NFC: $e');
  }
}


class Dashboard extends StatefulWidget {
  final int initialIndex; // Add an initialIndex parameter

  const Dashboard({super.key, this.initialIndex = 0});

  //const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String result= "";
  late int _selectedIndex;
  //bool _selectedfloat = false;
  late  final List<Widget>_pages;
  var _selectcolor = Colors.green.shade900;
  var _unselectcolor = Colors.green.shade100;

  void tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      if (tag.data.containsKey('ndef')) {
        // Extract NDEF message from tag data
        Map ndefData = tag.data['ndef'];

        if (ndefData.containsKey('cachedMessage')) {
          // Extract NDEF records from the cached message
          Map cachedMessage = ndefData['cachedMessage'];

          if (cachedMessage.containsKey('records')) {
            // Extract records from cached message
            List records = cachedMessage['records'];

            for (var record in records) {
              // Check if record is of type Text
              if (record['typeNameFormat'] == 1 && record['type'][0] == 84) {
                // Extract text payload and decode it
                List<int> payload = record['payload'];
                String text = String.fromCharCodes(payload.sublist(3));
                print('Text from NFC tag: $text');
              }
            }
          }
        }
      }

      // Stop NFC session
      Future.delayed(Duration(seconds: 2), () {
        // Code to be executed after a delay of 2 seconds
        NfcManager.instance.stopSession();
      });

      //NfcManager.instance.stopSession();
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      Home(),
      Marker(),
      //Book(),
      Profile(),
    ];
  }


  void ontap(int index ){
      setState(() {
        _selectedIndex = index;
        print(index);
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
      /*floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(

          backgroundColor: Colors.white,
          onPressed: () {
            setState(() {
              _selectedfloat = true;
            });
            tagRead();
          },
          child: Image.asset("assets/scan.jpg",height: 40,width: 40,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,*/

    );
  }
}
