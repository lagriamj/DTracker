import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class ProfilUpdate extends StatefulWidget {
  const ProfilUpdate({
    super.key,
    required this.users,
  });

  final Users users;

  @override
  State<ProfilUpdate> createState() => _ProfilUpdateState();
}

class _ProfilUpdateState extends State<ProfilUpdate> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController namecontroller;
  late TextEditingController contactnumcontroller;
  late String error;
  PlatformFile? pickedFile = null;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  Future uploadFile() async {
    if (pickedFile != null) {
      final path = 'debts/${generateRandomString(5)}';
      final file = File(pickedFile!.path!);

      //final curImage = widget.debts.de

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Download Link: $urlDownload');

      updateProfile(widget.users.id, urlDownload);
    } else {
      updateProfile(widget.users.id, widget.users.image);
    }

    setState(() {
      uploadTask = null;
    });
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Updated Successfully!',
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    namecontroller = TextEditingController(
      text: widget.users.name,
    );
    contactnumcontroller = TextEditingController(
      text: widget.users.contactnumber,
    );
    error = "";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    namecontroller.dispose();
    contactnumcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: Center(
                            child: (pickedFile == null)
                                ? imgNotExist()
                                : imgExist(),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            selectFile();
                          },
                          icon: Icon(
                            Icons.upload,
                            color: color,
                          ),
                          label: Text(
                            "Add Photo",
                            style: TextStyle(color: color),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colortitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: textfields(Icons.person, 'Name', namecontroller,
                        TextInputType.multiline),
                  ),
                  textfields(Icons.phone, "Contact Number",
                      contactnumcontroller, TextInputType.number),
                  updatebtn(),
                  Container(
                    child: Text(error, style: TextStyle(color: Colors.red)),
                  ),
                  buildProgress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateProfile(String id, urlDownload) {
    final docUser = FirebaseFirestore.instance.collection('Users').doc(id);
    docUser.update({
      'name': namecontroller.text,
      'contactnumber': contactnumcontroller.text,
      'image': urlDownload,
    });

    Navigator.pop(context);
  }

  Widget textfields(icon, String labelText, controller, textinputtype) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: TextFormField(
          keyboardType: textinputtype,
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter Data';
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon),
            labelText: labelText,
          ),
        ),
      );

  Widget updatebtn() => Container(
        width: 300,
        margin: const EdgeInsets.only(top: 15, bottom: 10),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onPressed: () {
            setState(() {
              error;
            });
            //updateDebts(widget.debts.id);
            if (formKey.currentState!.validate()) {
              uploadFile();
            } else {}
          },
          icon: Icon(
            Icons.edit,
            color: colortitle,
          ),
          label: Text(
            'UPDATE',
            style: TextStyle(
              //fontWeight: FontWeight.w900,
              color: colortitle,
              fontSize: 18,
            ),
          ),
        ),
      );
  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);

  Widget imgNotExist() => Image.network(
        widget.users.image,
        fit: BoxFit.cover,
        width: 250,
        height: 250,
      );
  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colortitle,
                  color: color,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });
}
