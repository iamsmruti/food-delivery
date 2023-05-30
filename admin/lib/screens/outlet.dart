import 'package:admin/dimensions.dart';
import 'package:admin/models/food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class outlet extends StatefulWidget {
  const outlet({Key? key}) : super(key: key);

  @override
  State<outlet> createState() => _outletState();
}

class _outletState extends State<outlet> {
  PageController pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Stream<List<Food>> readfoodDetails() => FirebaseFirestore.instance
      .collection("Merchants")
      .doc("FirebaseAuth.instance.currentUser!.uid")
      .collection("Menu")
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Food.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Food>>(
        stream: readfoodDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          } else if (snapshot.hasData) {
            final foods = snapshot.data!;
            return ListView(
              children: foods.map(buildfood).toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildfood(Food food) => ListTile(
        leading: CircleAvatar(
          child: Text("${food.price}"),
        ),
        title: Text("${food.name}"),
        subtitle: Text("${food.description}"),
      );
}
