import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
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

Future<File> writeDrug(String name, String expiry) async {
  final file = await _localFile;
  // Check if the file exists, if not, create it
  bool fileExists = await file.exists();
  if (!fileExists) {
    await file.create(recursive: true);
  }
  // Read the current contents of the file
  String currentContents = fileExists ? await file.readAsString() : '';
  // Split the contents into lines
  List<String> lines = currentContents.split('\n');
  // Add the new drug to the start of the list
  lines.insert(0, '${name},${expiry}');
  // Keep only the last 3 entries
  lines = lines.take(3).toList();
  // Join the lines back into a single string
  currentContents = lines.join('\n');
  // Write the updated contents back to the file
  await file.writeAsString(currentContents);
  // Print a confirmation message
  print('Drug with name: $name and expiry: $expiry has been written to the file.');
  return file;
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




class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
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


  final TextEditingController name = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  List<Map<String, String>> myRecentScans = [];
  void getRecentScans() async {
    myRecentScans = await readDrugs();
    assignValuesFromList(myRecentScans);
    // Now myRecentScans contains the list of drugs
    // You can use this variable in your Flutter widgets to display the data
  }



  @override
  void initState() {
    super.initState();
    getRecentScans();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: name,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.green.shade900,
              decoration: InputDecoration(
                labelText: 'name',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: expiry,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.green.shade900,
              decoration: InputDecoration(
                labelText: 'expiry',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900),
                ),
              ),
            ),
          ),
          ElevatedButton(onPressed: (){writeDrug(name.text, expiry.text);}, child: Text("write")),
          ElevatedButton(onPressed: (){
            getRecentScans();
            }, child: Text("read")),
          Text("${name1} : ${expiry1}"),
          Text("${name2} : ${expiry2}"),
          Text("${name3} : ${expiry3}"),
        ],
      ),
    );
  }
}
