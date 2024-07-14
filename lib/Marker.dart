
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Add the new drug to the current contents
  currentContents += '${name},${expiry}\n';
  // Write the updated contents back to the file
  return file.writeAsString(currentContents);
}


class Marker extends StatefulWidget {
  const Marker({super.key});

  @override
  State<Marker> createState() => _MarkerState();
}

class _MarkerState extends State<Marker> {
  bool checked = false;
  bool verified = false;
  String name = "";
  String expiry = "";

  void stop(){
    NfcManager.instance.stopSession();
    setState(() {
      checked = false;
    });
    tagRead();

  }

  void tagRead() {
    NfcManager.instance.stopSession();
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
            if (records.isEmpty) {
              // No records found
              setState(() {
                verified = false;
                checked = true;
              });
              return;
            }

            for (var record in records) {
              // Check if record is of type Text
              if (record['typeNameFormat'] == 1 && record['type'][0] == 84) {
                // Extract text payload and decode it
                List<int> payload = record['payload'];
                String id = String.fromCharCodes(payload.sublist(3));
                //print('Text from NFC tag: $id');
                try {
                  CollectionReference products = FirebaseFirestore.instance
                      .collection('drugs');

                  // Check if the ID exists in Firestore
                  DocumentSnapshot snapshot = await products.doc(id).get();

                  if (snapshot.exists) {
                    setState(() {
                      name = snapshot['name'];
                      expiry = snapshot['expiry'];
                      verified = true;
                    });
                    //print("Drug is verified");
                  } else {
                    setState(() {
                      verified = false;
                    });
                    //print("Drug is not verified");
                  }
                  setState(() {
                    checked = true;
                  });
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to fetch product details: $e')),
                  );
                }
              }
            }
          }
        }
      }

      // Stop NFC session
     /* Future.delayed(Duration(seconds: 2), () {
        // Code to be executed after a delay of 2 seconds
        NfcManager.instance.stopSession();
        setState(() {
          checked = false;
        });
        tagRead();
      });*/

      //NfcManager.instance.stopSession();
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tagRead();
    });
    //tagRead();
    // Call your function here

  }
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body:Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
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
                Text("Scan Tag", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                ),
                ),
                SizedBox(height: 120,),
                Center(
                    child: Column(
                      children: [
                        Image.asset("assets/nfc.png",height:250,width: 250,),
                        SizedBox(height: 40,),
                        Text("Place device on tag to scan",style: TextStyle(color: Colors.grey,fontSize: 20),),
                        SizedBox(height: 20,),
                        OutlinedButton(onPressed: (){tagRead();}, child:
                        Text(
                          "Refresh",
                          style: TextStyle(color: Colors.green.shade900),
                        ))


                      ],
                    )
                )
              ],
            ),
      ),
        if (checked)
          Scaffold(
            body: Container(
              color: Colors.black.withOpacity(0.7), // Overlay color
              child: Center(
                child: Container(
                  //padding: EdgeInsets.all(10),
                  height: 420,
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
                  child: verified? Column(
                    children: [
                      SizedBox(height: 25,),
                      Image.asset("assets/check.png",height: 200, width: 200,),
                      SizedBox(height: 10,),
                      Text("Drug verified!!",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 17
                        ),
                      ),
                      SizedBox(height: 20,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Drug name: ${name}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Expiry date: ${expiry}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      OutlinedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade800)),
                          onPressed: (){stop();},
                          child: Text("OK",style: TextStyle(color: Colors.white,fontSize: 17))
                      ),
                    ],
                  ):
                  Column(
                    children: [
                      SizedBox(height: 60,),
                      Image.asset("assets/xmark.png",height: 180, width: 180,),
                      Text("Drug not verified!!",
                        style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 20
                        ),
                      ),
                      SizedBox(height: 20,),
                      OutlinedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                          onPressed: (){stop();},
                          child: Text("OK",style: TextStyle(color: Colors.white,fontSize: 17))
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    ]
    );
  }
}
