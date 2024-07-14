import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:work/Details.dart';

import 'AdminDashboard.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/recent_scans.txt');
}
Future<List<Map<String, String>>> readDrugs() async {
  List<Map<String, String>> drugsList = [];
  try {
    final file = await _localFile;
    // Check if the file exists
    bool fileExists = await file.exists();
    if (!fileExists) {
      // If the file doesn't exist, return an empty list
      return drugsList;
    }
    // Read the file
    final contents = await file.readAsString();
    // Split the string by new lines to get each drug entry
    final lines = contents.split('\n');
    // Remove any empty lines that may have been created by extra new line characters
    lines.removeWhere((line) => line.isEmpty);
    // Parse each line into a drug map
    for (var line in lines) {
      var parts = line.split(',');
      if (parts.length >= 2) {
        drugsList.add({'name': parts[0], 'expiry': parts[1]});
      }
    }
  } catch (e) {
    // If there's an error, print it
    print('An error occurred while reading the file: $e');
  }
  // Print the list of drugs
  print(drugsList);
  return drugsList;
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

          Future.delayed(Duration(seconds: 2), () {
            // Code to be executed after a delay of 2 seconds
            NfcManager.instance.stopSession();
          });
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


class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String name1 = '';
  String name2 = '';
  String name3 = '';
  String expiry1 = '';
  String expiry2 = '';
  String expiry3 = '';

  void assignValuesFromList(List<Map<String, String>> drugsList) {
    if (drugsList.isNotEmpty) {
      setState(() {
        name1 = drugsList[0]['name'] ?? 'Unknown';
        expiry1 = drugsList[0]['expiry'] ?? 'Unknown';
      });
    }
    if (drugsList.length > 1) {
      setState(() {
        name2 = drugsList[1]['name'] ?? 'Unknown';
        expiry2 = drugsList[1]['expiry'] ?? 'Unknown';
      });
    }
    if (drugsList.length > 2) {
      setState(() {
        name3 = drugsList[2]['name'] ?? 'Unknown';
        expiry3 = drugsList[2]['expiry'] ?? 'Unknown';
      });
    }
  }

  List<Map<String, String>> myRecentScans = [];
  Future<void> getRecentScans() async {
    myRecentScans = await readDrugs();
    assignValuesFromList(myRecentScans);
  }


  String? userEmail;
  String name = "";
  void getDetails() async{
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    } else {
      setState(() {
        userEmail = 'No user logged in';
      });
    }
    CollectionReference products = FirebaseFirestore.instance
        .collection('admin');

    // Check if the ID exists in Firestore
    DocumentSnapshot snapshot = await products.doc(userEmail).get();

    if (snapshot.exists) {
      setState(() {
        name = snapshot['firstname']+ " " + snapshot['lastname'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching identity'),
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    // Call your function here
    getRecentScans();
    getDetails();

  }
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: getRecentScans,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.fromLTRB(15, 30, 20, 15),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 0),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text(
                            "${name}",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text(
                            "${userEmail}",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        "${name}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        "${userEmail}",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),*/
                    SizedBox(height: 20),
                    Text(
                      "Quick access",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 10),
                            height: 160,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.green.shade400,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade600,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0, 4.0),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      child: Text(
                                        "Scan NFC",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => AdminDashboard(initialIndex: 1,)),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                      child: Text("Scan now", style: TextStyle(fontSize: 15, color: Colors.white)),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 30,),
                                Image.asset("assets/phone.jpg",height: 100, width: 100,)
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 10),
                            height: 160,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.green.shade400,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade600,
                                  blurRadius: 2.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0, 4.0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 1),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text(
                                    "Write NFC",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    //_startNFCWriting();
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Details()));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  child: Text("Write now", style: TextStyle(fontSize: 15, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      " Recent tasks",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
                      constraints: BoxConstraints(minWidth: double.infinity),
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(0, 4.0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Last scanned Tag", style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                          Text("${name1}", style:
                          TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          )
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: Text("Expiry date: ${expiry1}", style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
                      constraints: BoxConstraints(minWidth: double.infinity),
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(0, 4.0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Last scanned Tag", style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                          Text("${name2}", style:
                          TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          )
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: Text("Expiry date: ${expiry2}", style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
                      constraints: BoxConstraints(minWidth: double.infinity),
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(0, 4.0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Last scanned Tag", style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                          Text("${name3}", style:
                          TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          )
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: Text("Expiry date: ${expiry3}", style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
