import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cupertino_date_textbox/cupertino_date_textbox.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
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


class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _manufacturer = TextEditingController();
  //final TextEditingController _expiry = TextEditingController();
  bool _isLoading = false;
  bool scanned = false;
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _startNFCWriting(String data) async {
    Completer<void> completer = Completer();
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (isAvailable) {
        setState(() {
          _isLoading = true;
        });
        print("waiting for tag");
        await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          try {
            print("writing message");
            NdefMessage message = NdefMessage([NdefRecord.createText(data)]);
            await Ndef.from(tag)?.write(message);
            debugPrint('Data emitted successfully');
            Uint8List payload = message.records.first.payload;
            String text = String.fromCharCodes(payload);
            debugPrint("Written data: $text");
            setState(() {
              scanned = true;
            });
            completer.complete(); // Complete the completer when writing is successful
          } catch (e) {
            debugPrint('Error emitting NFC data: $e');
            completer.completeError(e); // Complete with error if there's an issue
          } finally {
            Future.delayed(Duration(seconds: 2), () {
              NfcManager.instance.stopSession();
              setState(() {
                _isLoading = false;
              });
            });
          }
        });
        return completer.future; // Wait for the completer to complete
      } else {
        debugPrint('NFC not available.');
        NfcManager.instance.stopSession();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error writing to NFC: $e');
      NfcManager.instance.stopSession();
      setState(() {
        _isLoading = false;
      });
      completer.completeError(e); // Complete with error if there's an exception
    }
    return completer.future; // Ensure the function waits for the completer
  }

  Future<void> _checkAndAddToFirestore() async {
    final String id = _id.text;
    // Reference to the Firestore collection
    CollectionReference products = FirebaseFirestore.instance.collection('drugs');
    // Check if the ID exists in Firestore
    DocumentSnapshot snapshot = await products.doc(id).get();
    if (snapshot.exists) {
      // ID already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID already exists in the database.')),
      );
    } else {
      print("begining");
      await _startNFCWriting(id);
      print("ending");
      // scan tag before adding details
      if (scanned) {
        await products.doc(id).set({
          'name': _name.text,
          'id': _id.text,
          'manufacturer': _manufacturer.text,
          'expiry': _selectedDateTime.toString().split(' ')[0],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added to the database.')),
        );
        //write to file
        writeDrug(_name.text, _selectedDateTime.toString().split(' ')[0]);
        // Clear the text fields
        _name.clear();
        _id.clear();
        _manufacturer.clear();
        //_expiry.clear();

        setState(() {
          scanned = false;
        });
      }
    }
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _name.dispose();
    _id.dispose();
    _manufacturer.dispose();
    //_expiry.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                Text("Write to Tag", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    cursorColor: Colors.green.shade900,
                    decoration: InputDecoration(
                      labelText: 'Name of Drug',
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
                    controller: _id,
                    textInputAction: TextInputAction.next,
                    cursorColor: Colors.green.shade900,
                    decoration: InputDecoration(
                      labelText: 'Drug ID',
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
                    controller: _manufacturer,
                    textInputAction: TextInputAction.next,
                    cursorColor: Colors.green.shade900,
                    decoration: InputDecoration(
                      labelText: 'Manufacturer\'s name',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green.shade900),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Row(
                    children: [
                      Text("Expiry Date:",style: TextStyle(fontSize:16),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CupertinoDateTextBox(
                      initialValue: DateTime.now(),
                      onDateChange: DateChange,
                      hintText: 'Expiry date'),
                ),
                SizedBox(height: 40,),
                Container(
                  height: 40,
                  width: double.infinity, // Stretch the button horizontally
                  margin: EdgeInsets.symmetric(horizontal: 15), // Add some margin for spacing
                  child: OutlinedButton(
                    onPressed: () {
                      //print(_selectedDateTime.toString().split(' ')[0]);
                      if(
                        _name.text.isNotEmpty&&
                        _id.text.isNotEmpty&&
                        _manufacturer.text.isNotEmpty&&
                        _selectedDateTime.toString().isNotEmpty) {
                        _checkAndAddToFirestore();
                        // Simulate network request or long-running task
                        // Replace this with your actual submission logic
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill out all fields'),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green.shade500),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Set rounded edges
                        ),
                      ),
                    ),
                    child: Text("Submit", style: TextStyle(fontSize: 15,color: Colors.white),),
                  ),
                )
              ],
            ),
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Scaffold(
            body: Container(
              color: Colors.black.withOpacity(0.7), // Overlay color
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: 300,
                  width: MediaQuery.of(context).size.width*0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade600,
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                        offset: Offset(0, 4.0),
                      ),
                    ],
                  ),
                  child: scanned? Column(
                    children: [
                      Image.asset("assets/check.png",height: 220, width: 220,),
                      Text("Successful!! ",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20
                        ),
                      )
                    ],
                  ):
                  Column(
                    children: [
                      Image.asset("assets/nfc.png",height: 220, width: 220,),
                      Text("Place Device on Tag",
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 20
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  void DateChange(DateTime edate) {
    setState(() {
      _selectedDateTime = edate;
    });
  }
}
