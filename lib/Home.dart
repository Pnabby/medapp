import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work/Dashboard.dart';
import 'package:work/Scan.dart';
import 'package:work/Write.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  @override
  void initState() {
    super.initState();
    getRecentScans();
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Quick access",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 10,right: 15),
                            constraints: BoxConstraints(minWidth: double.infinity),
                            height: 160,
                            //width: 280,
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                          MaterialPageRoute(builder: (context) => Dashboard(initialIndex: 1,)),
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
