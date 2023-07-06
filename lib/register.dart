import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/login.dart';
import 'package:dtracket_project/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController emailcontroller;
  late TextEditingController namecontroller;
  late TextEditingController passwordcontroller;
  late TextEditingController contactnumcontroller;
  bool _obscureText = true;
  late String error;
  late String error1;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  late String url;

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
      final path = 'files/${generateRandomString(5)}';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      url = urlDownload;
      print('Download Link: $urlDownload');

      createUser(urlDownload);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Registered Successfully!',
      );
    } else {
      createUser(
          "https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Registered Successfully!',
      );
    }

    setState(() {
      uploadTask = null;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    emailcontroller = TextEditingController();
    namecontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    contactnumcontroller = TextEditingController();
    error = "";
    error1 = "";
  }

  @override
  void dispose() {
    super.dispose();
    emailcontroller.dispose();
    namecontroller.dispose();
    passwordcontroller.dispose();
    contactnumcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: color,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Icon(
              Icons.arrow_back,
              color: colortitle,
            ),
          ),
        ),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          children: [
            Container(
              color: Colors.grey[100],
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
                  SizedBox(
                    height: 30,
                  ),
                  textfields(Icons.email, "Email", false, emailcontroller),
                  textfields(Icons.person_sharp, "Name", false, namecontroller),
                  //textfields(Icons.lock, "Password", true, passwordcontroller),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Data';
                        }
                        return null;
                      },
                      controller: passwordcontroller,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        labelText: "Password",
                      ),
                    ),
                  ),
                  textfields(Icons.numbers, "Contact Number", false,
                      contactnumcontroller),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 300,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: () async {
                        setState(() {
                          error1 = "";
                        });
                        if (formKey.currentState!.validate()) {
                          registerUser();
                        } else {}
                      },
                      icon: Icon(
                        Icons.login,
                        color: colortitle,
                      ),
                      label: Text(
                        'Register',
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: colortitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    //margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Login Here!',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Text(
                      (error1 == "") ? error : error1,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
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

  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);

  Widget imgNotExist() => Image.asset(
        'assets/images/no-image.png',
        fit: BoxFit.cover,
      );
  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
  Widget textfields(icon, String labelText, bool obscure, controller) =>
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter Data';
            }
            return null;
          },
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon),
            labelText: labelText,
          ),
        ),
      );

  Future registerUser() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Center(
          child: SpinKitPouringHourGlassRefined(
            size: 60,
            color: colortitle,
          ),
        ),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      uploadFile();
      Navigator.pop(context);

      setState(() {
        error = "";
      });
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Registered Successfully!',
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        error = e.message.toString();
      });
    }
  }

  Future createUser(urlDownload) async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc();

    final newUser = Users(
      id: docUser.id,
      password: passwordcontroller.text,
      email: emailcontroller.text,
      name: namecontroller.text,
      image: urlDownload,
      contactnumber: contactnumcontroller.text,
    );

    final json = newUser.toJson();
    await docUser.set(json);

    setState(() {
      passwordcontroller.text = "";
      namecontroller.text = "";
      emailcontroller.text = "";
      contactnumcontroller.text = "";
      pickedFile = null;
    });
    Navigator.pop(context);
  }

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
                  backgroundColor: Colors.grey,
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
            height: 10,
          );
        }
      });
}
