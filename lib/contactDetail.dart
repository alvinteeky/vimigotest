import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


class ContactDetail extends StatefulWidget {
  const ContactDetail({Key? key}) : super(key: key);
  @override
  State<ContactDetail> createState() => _ContactDetailState();
}

class _ContactDetailState extends State<ContactDetail> {
  TextEditingController contact = TextEditingController();
  TextEditingController phone = TextEditingController();
  DateTime checkin = DateTime.now();
  final contactForm = GlobalKey<FormState>();

  int? contactIndex;
  late var obj;


  @override
  Widget build(BuildContext context) {
    Map argument = ModalRoute.of(context)?.settings.arguments as Map;
    obj = argument["contactContent"];
    contactIndex = argument["contactIndex"];
    contact.text = obj["user"];
    phone.text = obj["phone"];
    checkin = DateTime.parse(obj["check-in"]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.of(context).pushNamedAndRemoveUntil('/contactList', (Route<dynamic> route) => false);
          },
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.primaries[contactIndex!],
              child: Text(
                obj["user"][0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 80
                ),
              )
            ),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Center(
            child: Text(
              obj["user"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xff595699).withOpacity(0.3)
                ),
                bottom: BorderSide(
                    color: const Color(0xff595699).withOpacity(0.3)
                )
              )
            ),
            padding: const EdgeInsets.only(top: 10,bottom: 10),
            margin: const EdgeInsets.only(top: 20,bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (ctx) => StatefulBuilder(
                          builder: (context, setState){
                            return AlertDialog(
                              title: const Text('Edit Contact'),
                              content: Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 400,
                                      maxHeight: 450
                                  ),
                                  child: Form(
                                    key: contactForm,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your name';
                                              }
                                              return null;
                                            },
                                            controller: contact,
                                            decoration: const InputDecoration(
                                              labelText: "Name",
                                              prefixIcon: Icon(Icons.person),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.black
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Padding(padding: EdgeInsets.all(10)),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your phone number';
                                              }
                                              return null;
                                            },
                                            controller: phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly
                                            ],
                                            keyboardType: TextInputType.phone,
                                            decoration: const InputDecoration(
                                              labelText: "Phone",
                                              prefixIcon: Icon(Icons.phone),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.black
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Padding(padding: EdgeInsets.all(10)),
                                          InkWell(
                                            onTap: () async {
                                              DateTime? selecteDate = await DatePicker.showDateTimePicker(
                                                context,
                                                showTitleActions: true,
                                                minTime: DateTime.now().subtract(const Duration(days: 5000)),
                                                maxTime: DateTime.now().add(const Duration(days: 5000)),
                                                onConfirm: (date) {
                                                  setState(() {
                                                    checkin = date;
                                                  });
                                                },
                                                currentTime: checkin,
                                              );
                                              setState(() {
                                                checkin = selecteDate!;
                                              });
                                            },
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                labelText: "Check in",
                                                prefixIcon: Icon(Icons.calendar_month),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.black
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                  DateFormat('d MMM yyyy hh:mm a').format(checkin).toString()
                                              ),
                                            ),
                                          ),
                                          const Padding(padding: EdgeInsets.all(20)),
                                          TextButton(
                                              onPressed: () async {
                                                if (contactForm.currentState!.validate()) {
                                                  EasyLoading.show(status: "Removing");
                                                  final directory = await getApplicationDocumentsDirectory();
                                                  final File file = File('${directory.path}/dataset.json');
                                                  String response = await file.readAsString();
                                                  List obj2 = jsonDecode(response);
                                                  obj2.sort((a, b) {
                                                    return a['user'].toLowerCase().compareTo(b['user'].toLowerCase());
                                                  });
                                                  obj2[contactIndex!] = {"user":contact.text,"phone":phone.text,"check-in":checkin.toString()};
                                                  await file.writeAsString(jsonEncode(obj2)).then((value){
                                                    EasyLoading.dismiss();
                                                    EasyLoading.showSuccess("Save successfully",dismissOnTap: true);
                                                    Navigator.pop(context);
                                                    Navigator.of(context).pushNamedAndRemoveUntil('/contactDetail',arguments: {"contactContent": {"user":contact.text,"phone":phone.text,"check-in":checkin.toString()},"contactIndex":contactIndex}, (Route<dynamic> route) => false);
                                                  });
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                  backgroundColor: const Color(0xff5a579a),
                                                  padding: const EdgeInsets.all(20),
                                                  primary: Colors.white
                                              ),
                                              child: const Text("Save")
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ),
                            );
                          }
                        )
                    ).then((value){

                    });
                  },
                  child: Column(
                    children: const [
                      Icon(
                        Icons.edit,
                        size: 30,
                        color: Color(0xff595699),
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff595699)
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you want to remove this contact?"),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xff5a579a),
                              primary: Colors.white
                            ),
                            onPressed: () async {
                              EasyLoading.show(status: "Removing");
                              final directory = await getApplicationDocumentsDirectory();
                              final File file = File('${directory.path}/dataset.json');
                              String response = await file.readAsString();
                              List obj2 = jsonDecode(response);
                              obj2.sort((a, b) {
                                return a['user'].toLowerCase().compareTo(b['user'].toLowerCase());
                              });
                              obj2.removeAt(contactIndex!);
                              await file.writeAsString(jsonEncode(obj2)).then((value){
                                EasyLoading.dismiss();
                                EasyLoading.showSuccess("Remove successfully",dismissOnTap: true);
                                Navigator.of(context).pushNamedAndRemoveUntil('/contactList', (Route<dynamic> route) => false);
                              });

                            },
                            child: const Text("Yes")
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: const Text("No")
                          )
                        ],
                      )
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(
                        Icons.delete_forever_outlined,
                        size: 30,
                        color: Colors.redAccent,
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        "Remove",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xfff0edf6),
              borderRadius: BorderRadius.circular(10)
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contact Info",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20)),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(obj["phone"]),
                  subtitle: const Text("Mobile"),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                    DateFormat('d MMM yyyy hh:mm a').format(DateTime.parse(obj["check-in"])).toString()
                  ),
                  subtitle: const Text("Check in date"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
