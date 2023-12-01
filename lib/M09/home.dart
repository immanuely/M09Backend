import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firestore1/M09/event_model.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<EventModel> details = [];
  @override
  void initState() {
    readData();
    super.initState();
  }

  Future readData() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    var data = await db.collection('event_detail').get();
    setState(() {
      details =
          data.docs.map((doc) => EventModel.fromDocSnapshot(doc)).toList();
    });
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (index) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  addRand() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    EventModel InsertData = EventModel(
        judul: getRandString(5),
        keterangan: getRandString(30),
        tanggal: getRandString(10),
        is_like: false,
        pembicara: getRandString(20));
    await db.collection('event_detail').add(InsertData.toMap());
    readData();
    setState(() {
      details.add(InsertData);
    });
  }

  deleteAt(String documentId) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db.collection('event_detail').doc(documentId).delete();
    setState(() {
      details.removeWhere((detail) => detail.id == documentId);
    });
  }

  deleteAll() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    db.collection('event_detail').get().then((snap) {
      for (DocumentSnapshot ds in snap.docs) {
        ds.reference.delete();
      }
    });
    setState(() {
      details.clear();
    });
  }

  updateEvent(int pos) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    try {
      await db
          .collection('event_detail')
          .doc(details[pos].id)
          .update({'is_like': !details[pos].is_like});
      setState(() {
        details[pos].is_like = !details[pos].is_like;
      });
      readData();
    } catch (e) {
      print(e);
    }
  }

  customAdd(judul, keterangan, tanggal, pembicara) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    EventModel InsertData = EventModel(
        judul: judul,
        keterangan: keterangan,
        tanggal: tanggal,
        is_like: false,
        pembicara: pembicara);
    await db.collection('event_detail').add(InsertData.toMap());
    readData();

    setState(() {
      details.add(InsertData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Firestore"),
        actions: [
          IconButton(
            onPressed: () {
              addRand();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              deleteAll();
            },
            icon: const Icon(Icons.delete_forever),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController judul = TextEditingController();
                    TextEditingController keterangan = TextEditingController();
                    TextEditingController tanggal = TextEditingController();
                    TextEditingController pembicara = TextEditingController();
                    return AlertDialog(
                      title: Text("Tambah Data"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: judul,
                            decoration: InputDecoration(
                              labelText: 'Judul',
                              hintText: 'Masukkan Judul',
                            ),
                          ),
                          TextField(
                            controller: keterangan,
                            decoration: InputDecoration(
                              labelText: 'Keterangan',
                              hintText: 'Masukkan Keterangan',
                            ),
                          ),
                          TextField(
                            controller: tanggal,
                            decoration: InputDecoration(
                              labelText: 'Tanggal',
                              hintText: 'Masukkan Tanggal',
                            ),
                          ),
                          TextField(
                            controller: pembicara,
                            decoration: InputDecoration(
                              labelText: 'Pembicara',
                              hintText: 'Masukkan Pembicara',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                            onPressed: () {
                              customAdd(judul.text, keterangan.text,
                                  tanggal.text, pembicara.text);
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.add)),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.fire_truck),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.length,
          itemBuilder: ((context, index) {
            return Card(
              color: Colors.white70,
              child: ListTile(
                title: Text(details[index].judul),
                subtitle: Text(
                    '${details[index].keterangan} \nHari: ${details[index].tanggal}\nPembicara: ${details[index].pembicara}'),
                leading: IconButton(
                  icon: details[index].is_like
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        )
                      : const Icon(Icons.favorite_outline),
                  onPressed: () => updateEvent(index),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    deleteAt(details[index].id!);
                  },
                ),
              ),
            );
          }),
        ),
      ),
      // body: ListView.builder(
      //   itemCount: details.length,
      //   itemBuilder: (context, position) {
      //     return CheckboxListTile(
      //       title: Text(details[position].judul),
      //       subtitle: Text(
      //           '${details[position].keterangan} \nHari: ${details[position].tanggal}\nPembicara: ${details[position].pembicara}'),
      //       value: details[position].is_like,
      //       onChanged: (bool? value) {
      //         updateEvent(position);
      //       },
      //       isThreeLine: false,
      //     );
      //   },
      // ),
    );
  }
}
