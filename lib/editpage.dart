import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/debts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class EditPage extends StatefulWidget {
  const EditPage({
    super.key,
    required this.debts,
  });

  final Debts debts;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController namecontroller;
  late TextEditingController debtcontroller;
  late TextEditingController interestcontroller;
  late TextEditingController dueDatecontroller;
  late TextEditingController contactnumcontroller;
  late double interestRate;
  late num totalAmount;
  late num toAddAmount;
  late String url;
  late String error;
  PlatformFile? pickedFile = null;
  UploadTask? uploadTask;

  void totalAmountCalculation() {
    final toAddAmount = (double.parse(debtcontroller.text) *
            double.parse(interestcontroller.text)) /
        100;

    setState(() {
      totalAmount = double.parse(debtcontroller.text) + toAddAmount;
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

      //final curImage = widget.debts.de

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Download Link: $urlDownload');

      updateDebts(widget.debts.id, urlDownload);
    } else {
      updateDebts(widget.debts.id, widget.debts.debt_pic);
    }

    setState(() {
      url = "";
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
    super.initState();
    namecontroller = TextEditingController(
      text: widget.debts.name,
    );
    debtcontroller = TextEditingController(
      text: widget.debts.debt.toString(),
    );
    interestcontroller = TextEditingController(
      text: widget.debts.interest.toString(),
    );
    dueDatecontroller = TextEditingController(
      text: widget.debts.dueDate,
    );
    contactnumcontroller = TextEditingController(
      text: widget.debts.contactnumber,
    );
    error = "";
    toAddAmount = 0;
    totalAmount = widget.debts.totalAmount;
  }

  @override
  void dispose() {
    namecontroller.dispose();
    debtcontroller.dispose();
    interestcontroller.dispose();
    dueDatecontroller.dispose();
    contactnumcontroller.dispose();
    super.dispose();
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
                  /*textfields(Icons.attach_money, 'Borrowed', debtcontroller,
                      TextInputType.number),*/

                  ///textfields(Icons.percent, 'Interest Rate', interestcontroller,
                  //TextInputType.number),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: TextField(
                      onChanged: (content) {
                        interestcontroller.text = "";
                      },
                      keyboardType: TextInputType.number,
                      controller: debtcontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        labelText: "Borrowed",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: TextField(
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
                  updatebtn(),
                  Container(
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

  updateDebts(String id, urlDownload) {
    final docUser = FirebaseFirestore.instance.collection('Persons').doc(id);
    docUser.update({
      'name': namecontroller.text,
      'debt': double.parse(debtcontroller.text),
      'interest': double.parse(interestcontroller.text),
      'totalAmount': totalAmount,
      'dueDate': dueDatecontroller.text,
      'contactnumber': contactnumcontroller.text,
      'debt_pic': urlDownload,
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

  /*Widget builddatepicker() => SizedBox(
        height: 180,
        child: CupertinoDatePicker(
          minimumYear: DateTime.now().year,
          initialDateTime: datetime,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (datetime) {
            setState(() {
              this.datetime = datetime;
              final value = DateFormat('MM/dd/yyyy').format(datetime);
              dueDatecontroller.text = value;
            });
          },
        ),
      );*/

  Widget datefield() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: TextField(
          controller: dueDatecontroller,
          onTap: () async {
            // Below line stops keyboard from appearing
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              setState(() {
                dueDatecontroller.text =
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
        widget.debts.debt_pic,
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
