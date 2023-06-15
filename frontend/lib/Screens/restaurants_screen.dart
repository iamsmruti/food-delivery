import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/Screens/home_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Custom UI/big_font.dart';
import '../Custom UI/small_font.dart';
import '../Models/merchart.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

final searchController = TextEditingController();
String search = "";
String searchQuery = '';

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  String currentAddress = 'My Address';
  late Position currentposition;

  Future determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentposition = position;
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool changebutton = false;
  final List<bool> selectedItems = List.generate(5, (_) => false);
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 237, 228, 202),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey.withOpacity(0.5),
                Colors.white,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10 / 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.black),
                  SmallFont(
                    text: currentAddress,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 20 * 2.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(
                          0, 3), // changes the shadow direction vertically
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(fontSize: 17),
                    hintText: 'Search Food Items',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SmallFont(
                text: "Nearby Restaurant",
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: FutureBuilder<List<Merchant>>(
                  future: fetchMerchantData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      List<Merchant> shops = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          Merchant shop = shops[index];
                          return shopCard(shop);
                        },
                      );
                    } else {
                      return const Text('No data available');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shopCard(Merchant shop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuScreen(
              shop: shop,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          GestureDetector(
            child: Container(
              height: 20 * 9,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 189, 217, 231),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: const Image(
                  image: AssetImage("assets/images/cafe.png"),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.7),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(
                        0, 3), // changes the shadow direction vertically
                  ),
                ],
                color: Colors.blueGrey,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10 / 3,
                    ),
                    BigFont(
                      text: shop.name!,
                      color: Colors.white,
                    ),
                    SmallFont(
                      text: shop.description!,
                      size: 10 / 1.1,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100 / 1.65,
            left: 110 * 2.6,
            right: 10 * 1.5,
            child: Container(
              height: 28,
              width: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF4CBB17),
                borderRadius: BorderRadius.all(
                  Radius.circular(10 / 3),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10 / 2,
                    ),
                    SmallFont(
                      text: "4.5",
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10 / 3,
                    ),
                    const Icon(
                      Icons.star,
                      size: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoriesItem(int index) {
    return Stack(
      children: [
        GestureDetector(
          child: Container(
            height: 30 * 3.5,
            width: 30 * 2.6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 189, 217, 231),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/images/cafe.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMenuItem(int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedItems[index] = !selectedItems[index];
              selectedIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 20 * 1.7,
            width: selectedIndex == index ? 20 * 3.5 : 20 * 2.5,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selectedIndex == index ? Colors.red[600] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(
                      0, 3), // changes the shadow direction vertically
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const Icon(Icons.food_bank_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Merchant>> fetchMerchantData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Merchants').get();

    List<Merchant> shops = snapshot.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return Merchant(
        id: doc.id,
        name: data['name'],
        description: data['description'],
      );
    }).toList();

    return shops;
  }
}
