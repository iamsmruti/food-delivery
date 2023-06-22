
import 'package:admin/constants.dart';
import 'package:admin/handlers/google_maps.dart';
import 'package:admin/models/place_search.dart';
import 'package:admin/screens/outlet_mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'dart:io';
import 'map.dart';

final venueDataProv =
    ChangeNotifierProvider<VenueProvider>((ref) => VenueProvider(ref));

class VenueProvider extends ChangeNotifier {
  VenueProvider(this.ref);
  final Ref ref;
  TextEditingController venueController = TextEditingController();

  String? latitude;
  String? longitude;

  setAddress(TextEditingController controller, String lat, String long) {
    venueController = controller;
    latitude = lat;
    longitude = long;
    notifyListeners();
  }
}

class NewOutlet extends ConsumerStatefulWidget {
  const NewOutlet({super.key});

  @override
  ConsumerState<NewOutlet> createState() => _NewOutletState();
}

class _NewOutletState extends ConsumerState<NewOutlet> {
  bool isLoading = false;
  String imageLink =
      "https://images.everydayhealth.com/images/diet-nutrition/34da4c4e-82c3-47d7-953d-121945eada1e00-giveitup-unhealthyfood.jpg?sfvrsn=a31d8d32_0";
  String? name;
  String? description;
  String? address;
  final _itemImageController = TextEditingController();
  TextEditingController searchQueryController = TextEditingController();
  PlaceSearch? predictions;
  bool predictionWidget = false;
  double? latitude;
  double? longitude;

  submitData() async {
    if (name == '') {
      Fluttertoast.showToast(msg: 'Name can\'t be empty');
    } else if (description == '') {
      Fluttertoast.showToast(msg: 'Description can\'t be empty');
    } else if (address == '') {
      Fluttertoast.showToast(msg: 'Address can\'t be empty');
    } else if (searchQueryController.text == '') {
      Fluttertoast.showToast(msg: 'Location can\'t be empty');
    } else {
      FirebaseFirestore.instance
          .collection("Merchants")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "name": name,
        "description": description,
        "address": address,
        "lat": latitude,
        "image": _itemImageController.text.isEmpty
            ? imageLink
            : _itemImageController.text,
        "lng": longitude,
        "notif_token": await FirebaseMessaging.instance.getToken()
      }).whenComplete(() {
        Fluttertoast.showToast(msg: "Outlet Created Successfully");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OutletMainPage()),
        );
      }).onError((error, _) {
        Fluttertoast.showToast(msg: "$error");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(venueDataProv).venueController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Register New Outlet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                onChanged: (value) {
                  name = value;
                  setState(() {});
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Name',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 182, 182, 182)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  description = value;
                },
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 182, 182, 182)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  address = value;
                },
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter Address Manually',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 182, 182, 182)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: const Maps());
                },
                child: TextField(
                  onChanged: (value) async {},
                  // readOnly: true,
                  controller: ref.watch(venueDataProv).venueController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Select Address From Map',
                    enabled: false,
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 182, 182, 182)),
                    prefixIcon: Icon(
                      Icons.location_searching,
                      color: Color.fromARGB(255, 182, 182, 182),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              predictionWidget
                  ? Container(
                      height: 200,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                          itemCount: predictions?.predictions.length,
                          itemBuilder: (context, index) => InkWell(
                                onTap: () async {
                                  searchQueryController.text = predictions!
                                      .predictions[index].description;
                                  predictionWidget = false;
                                  setState(() {});
                                  dynamic coordinatesResult =
                                      await GoogleMapsHandler()
                                          .getCoordinatesFromPlaceID(
                                              predictions!
                                                  .predictions[index].placeId);
                                  latitude = coordinatesResult['lat'];
                                  longitude = coordinatesResult['lng'];
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Text(
                                    predictions!.predictions[index].description,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              )),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {},
                readOnly: true,
                onTap: () {
                  selectImage();
                },
                controller: _itemImageController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Upload Your Outlet Image',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 182, 182, 182)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 182, 182, 182)),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                color: secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                onPressed: () async {
                  await submitData();
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Submit",
                        style: TextStyle(color: primaryColor),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String imageLink = await uploadImageToFirestore(image.path);
      _itemImageController.text = imageLink;
    }
  }

  Future<String> uploadImageToFirestore(String imagePath) async {
    String fileName = imagePath.split('/').last;
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    firebase_storage.UploadTask uploadTask = ref.putFile(File(imagePath));


    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
