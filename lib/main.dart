import 'dart:convert';
import 'dart:io';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'animation.dart';
import 'bordingScreen.dart';
import 'contactDetail.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Contact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: Color(0xff413e49)
          ),
          elevation: 0
        )
      ),
      initialRoute: "/",
      routes: {
        '/': (context) => const OnBordingScreen(),
        '/contactList': (context) => const MyApp(),
        '/contactDetail': (context) => const ContactDetail(),
      },
      builder: EasyLoading.init(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController contact = TextEditingController();
  TextEditingController newcontact = TextEditingController();
  TextEditingController phone = TextEditingController();
  DateTime checkin = DateTime.now();
  List contactlist = [];
  final contactForm = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    loadContact();
  }

  Future<void> loadContact() async {
    final directory = await getApplicationDocumentsDirectory();
    if(await File('${directory.path}/dataset.json').exists()){
      final File file = File('${directory.path}/dataset.json');
      String response = await file.readAsString();
      setState(() {
        contactlist = jsonDecode(response);
        contactlist.sort((a, b) {
          return a['user'].toLowerCase().compareTo(b['user'].toLowerCase());
        });
      });
    }else{
      String response = await rootBundle.loadString('assets/dataset.json');
      setState(() {
        contactlist = jsonDecode(response);
        contactlist.sort((a, b) {
          return a['user'].toLowerCase().compareTo(b['user'].toLowerCase());
        });
      });
    }


  }

  void searchContact(){
     if(contact.text.isNotEmpty){
       setState(() {
         contactlist = contactlist.where((e) => e["user"].toLowerCase().contains(contact.text.toLowerCase()) || e["phone"].toLowerCase().contains(contact.text)).toList();
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Container(
          child: TextFormField(
            onChanged: (value){
              loadContact().then((value) => searchContact());
            },
            controller: contact,
            decoration: InputDecoration(
              hintText: "Search contacts",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              fillColor: const Color(0xffedeaf5),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top:10,left: 20,right: 20),
        children: [
          // SizedBox(
          //   height: 300,
          //   width: 100,
          //   child: GameWidget(
          //     game: MyGame(),
          //   )
          // ),
          ListTile(
            onTap: (){
              showDialog(
                context: context,
                builder: (ctx) => StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      title: const Text('Create Contact'),
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
                                    controller: newcontact,
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
                                      DatePicker.showDateTimePicker(
                                        context,
                                        currentTime: checkin,
                                        showTitleActions: true,
                                        minTime: DateTime.now().subtract(const Duration(days: 5000)),
                                        maxTime: DateTime.now().add(const Duration(days: 5000)),
                                        onConfirm: (date) {
                                          setState(() {
                                            checkin = date;
                                          });
                                        },

                                      );

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
                                          EasyLoading.show(
                                              status: "Saving..."
                                          );
                                          contactlist.add({"user":newcontact.text,"phone":phone.text,"check-in":checkin.toString()});
                                          final directory = await getApplicationDocumentsDirectory();
                                          final File file = File('${directory.path}/dataset.json');
                                          await file.writeAsString(jsonEncode(contactlist)).then((value){
                                            loadContact();
                                            EasyLoading.dismiss();
                                            setState(() {
                                              newcontact.clear();
                                              phone.clear();
                                              checkin = DateTime.now();
                                            });
                                            Navigator.pop(context);
                                            EasyLoading.showSuccess("Save successfully",dismissOnTap: true);
                                          });

                                        }
                                        setState(() {

                                        });
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
              );
            },
            leading: const Icon(Icons.person_add),
            title: const Text(
                "Create new contact"
            ),
          ),
          for(var i = 0;i < contactlist.length;i++)
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, '/contactDetail',arguments: {"contactContent": contactlist[i],"contactIndex":i});
              },
              leading: CircleAvatar(
                backgroundColor: Colors.primaries[i],
                child: Text(
                  contactlist[i]["user"][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                )
              ),
              title: Text(
                contactlist[i]["user"],
              ),
              subtitle: Text(
                DateFormat('d MMM yyyy hh:mm a').format(DateTime.parse(contactlist[i]["check-in"])).toString()
              ),
            ),
        ],
      ),
    );
  }
}
