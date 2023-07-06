import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/debts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController namecontroller;
  late TextEditingController debtcontroller;
  late TextEditingController interestcontroller;
  late TextEditingController duedatecontroller;
  late TextEditingController contactnumcontroller;
  late double interestRate;
  late num totalAmount;
  late num toAddAmount;
  late String error;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  //late DateTime pickedDate;

  final currentUser = FirebaseAuth.instance;

  void totalAmountCalculation() {
    final toAddAmount = (double.parse(debtcontroller.text) *
            double.parse(interestcontroller.text)) /
        100;

    setState(() {
      if (toAddAmount == 0) {
        totalAmount = double.parse(debtcontroller.text);
      } else {
        totalAmount = double.parse(debtcontroller.text) + toAddAmount;
      }
    });
  }

  DateTime datetime = DateTime.now();

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

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Download Link: $urlDownload');

      createDebts(urlDownload);
      Navigator.pop(context);
    } else {
      createDebts(
          "https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png");
      Navigator.pop(context);
    }

    setState(() {
      uploadTask = null;
    });

    Navigator.pop(context);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Added Successfully!',
    );
  }

  @override
  void initState() {
    super.initState();
    namecontroller = TextEditingController();
    debtcontroller = TextEditingController();
    interestcontroller = TextEditingController();
    duedatecontroller = TextEditingController();
    contactnumcontroller = TextEditingController();
    toAddAmount = 0;
    totalAmount = 0;
    error = "";
  }

  @override
  void dispose() {
    super.dispose();
    namecontroller.dispose();
    debtcontroller.dispose();
    interestcontroller.dispose();
    duedatecontroller.dispose();
    contactnumcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
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
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: textfields(Icons.person, 'Name', namecontroller,
                        TextInputType.multiline),
                  ),
                  textfields(Icons.phone, "Contact Number",
                      contactnumcontroller, TextInputType.number),
                  datefield(),
                  textfields(Icons.attach_money, 'Borrowed', debtcontroller,
                      TextInputType.number),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Data';
                        }
                        return null;
                      },
                      onChanged: (content) {
                        setState(() {
                          totalAmountCalculation();
                        });
                      },
                      keyboardType: TextInputType.number,
                      controller: interestcontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        labelText: "Interest Rate",
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Text(
                      'Total Amount To Pay: ${totalAmount}',
                      style: GoogleFonts.robotoMono(fontSize: 16),
                    ),
                  ),
                  createbtn(),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(error, style: TextStyle(color: Colors.red)),
                  ),
                  buildProgress(),
                ],
              ),
            ),
          ],

          // diri
        ),
      ),
    );
  }

  /*Widget showSuccess() => Center(
        child: QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Added Successfully!',
        ),
      );*/

  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);

  Widget imgNotExist() => Image.asset(
        'assets/images/no-image.png',
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

  Widget createbtn() => Container(
        width: 300,
        margin: EdgeInsets.only(bottom: 10),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onPressed: () async {
            setState(() {
              error;
            });
            if (formKey.currentState!.validate()) {
              uploadFile();
            } else {}
          },
          icon: Icon(
            Icons.create,
            color: colortitle,
          ),
          label: Text(
            'CREATE',
            style: GoogleFonts.robotoMono(fontSize: 16, color: colortitle),
          ),
        ),
      );

  Widget textfields(icon, String labelText, controller, keyBoardType) =>
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
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon),
            labelText: labelText,
          ),
        ),
      );

  Widget datefield() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: TextFormField(
          controller: duedatecontroller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter Data';
            }
            return null;
          },
          onTap: () async {
            // Below line stops keyboard from appearing
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              setState(() {
                duedatecontroller.text =
                    DateFormat("MM/dd/yyyy").format(pickedDate);
              });
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.date_range),
            labelText: 'Due Date',
          ),
        ),
      );

  Widget builddatepicker() => SizedBox(
        height: 180,
        child: CupertinoDatePicker(
          minimumYear: DateTime.now().year,
          initialDateTime: datetime,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (datetime) {
            setState(() {
              this.datetime = datetime;
              final value = DateFormat('MM/dd/yyyy').format(datetime);
              duedatecontroller.text = value;
            });
          },
        ),
      );

  Future createDebts(urlDownload) async {
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
    final docDebts = FirebaseFirestore.instance.collection('Persons').doc();

    final newDebts = Debts(
      id: docDebts.id,
      user_id: currentUser.currentUser!.uid,
      name: namecontroller.text,
      debt: double.parse(debtcontroller.text),
      interest: double.parse(interestcontroller.text),
      totalAmount: totalAmount,
      dueDate: duedatecontroller.text,
      contactnumber: contactnumcontroller.text,
      debt_pic: urlDownload,
    );

    final json = newDebts.toJson();
    await docDebts.set(json);
    setState(() {
      namecontroller.text = "";
      debtcontroller.text = "";
      interestcontroller.text = "";
      totalAmount = double.parse("");
      duedatecontroller.text = "";
      contactnumcontroller.text = "";
    });
    //Navigator.pop(context);
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
