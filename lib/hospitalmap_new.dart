import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

const kGoogleApiKey = "AIzaSyCjIuKrCUTzpz0MemaFFibaP-be9HnkZMQ";

class HospitalMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HospitalMapState();
}

class _HospitalMapState extends State<HospitalMap> {
  //final states
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final _firestore = FirebaseFirestore.instance;

  //map padding
  double mapBottomPadding = 0;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;

  //marker attributes
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  //maps attributes
  Position currentPosition;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  Location location = new Location();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  // Stateful Data
  BehaviorSubject<double> radius = BehaviorSubject();
  Stream<dynamic> query;

  // Subscription
  StreamSubscription subscription;

  static final CameraPosition _myHome = CameraPosition(
    target: LatLng(-6.196690, 106.888430),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text('Get Medicine'),
        backgroundColor: Color.fromRGBO(99, 219, 167, 1),
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _myHome,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 250 : 270;
                _startQuery();
                _addMarker();
              });
            }),
        // Positioned(
        //     top: 25,
        //     left: 10,
        //     child: FlatButton(
        //       child: Icon(Icons.pin_drop, color: Colors.white),
        //       color: Colors.green,
        //       onPressed: _addGeoPoint,
        //     )),
        SizedBox.expand(
          child: DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.25,
              maxChildSize: 0.8,
              builder: (BuildContext c, s) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10.0,
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: ListView(controller: s, children: <Widget>[
                      Center(
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      // Panel Title
                      Text(
                        'Where do you want to buy?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ]),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                color: Color.fromRGBO(99, 219, 167, 1),
                                // onPressed: () {
                                //   _handlePressButton();
                                // },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Search Hospitals'),
                            ],
                          ),
                        ),
                      ),

                      // ListTile(
                      //   title: Text('Alamat RS 1'),
                      // ),
                      // ListTile(
                      //   title: Text('Alamat RS 2'),
                      // ),
                      // ListTile(
                      //   title: Text('Alamat RS 3'),
                      // ),

                      Container(
                        child: StreamBuilder<QuerySnapshot>(
                            stream:
                                _firestore.collection("locations").snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> querySnapshot) {
                              if (querySnapshot.hasError)
                                return Text("Error fetching snapshot");

                              if (querySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                final list = querySnapshot.data.docs;

                                return ListView.builder(
                                    itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(list[index]["name"]),
                                    subtitle: Text(list[index]["alamat"]),
                                  );
                                });
                              }
                            }),
                      )
                    ]),
                  ),
                );
              }),
        ),
      ]),
    );
    return scaffold;
  }

  _addMarker() {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    var marker = Marker(
      markerId: markerId,
      position: LatLng(currentPosition.latitude, currentPosition.longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: 'Magic Marker', snippet: '🍄🍄🍄'),
    );
    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  _animateToUser() async {
    var pos = await location.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 17.0,
    )));
  }

  // Set GeoLocation Data
  Future<DocumentReference> _addGeoPoint() async {
    var pos = await location.getLocation();
    GeoFirePoint point =
        geo.point(latitude: pos.latitude, longitude: pos.longitude);
    return firestore
        .collection('locations')
        .add({'position': point.data, 'name': 'Yay I can be queried!'});
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint pos = document.data()['position']['geopoint'];
      String name = document.data()['name'];
      String phone = document.data()['phone'];
      var marker = Marker(
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: '$name', snippet: '$phone'),
      );
      _addMarker();
    });
  }

  _startQuery() async {
    // Make a referece to firestore
    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(
        latitude: currentPosition.latitude,
        longitude: currentPosition.latitude);

    // subscribe to query
    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
    final zoomMap = {
      100.0: 12.0,
      200.0: 10.0,
      300.0: 7.0,
      400.0: 6.0,
      500.0: 5.0
    };
    final zoom = zoomMap[value];
    mapController.moveCamera(CameraUpdate.zoomTo(zoom));

    setState(() {
      radius.add(value);
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  // void getNearbyPlaces(LatLng currentPosition) async {

  //   final location = Location(currentPosition.latitude, currentPosition.longitude);
  //   final result = await _places.searchNearbyWithRadius(location, 2500);
  //   setState(() {
  //       this.places = result.results;
  //       result.results.forEach((f) {
  //         final Marker marker = Marker(
  //             position:LatLng(f.geometry.location.lat, f.geometry.location.lng),
  //             infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
  //             onTap: () {
  //             markers[markerId] = marker;
  //       });
  //     });
  //   });
  // }
  // void onError(PlacesAutocompleteResponse response) {
  //   scaffoldKey.currentState.showSnackBar(
  //     SnackBar(content: Text(response.errorMessage)),
  //   );
  // }
  // Future<Null> showDetailPlace(String placeId) async {
  //   PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
  //   if (placeId != null) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => MapNewWidget(placeId)),
  //     );
  //   }
  // }

  // Future<void> _handlePressButton() async {
  //   try {
  //     Prediction p = await PlacesAutocomplete.show(
  //         context: context,
  //         strictbounds: currentPosition == null ? false : true,
  //         apiKey: kGoogleApiKey,
  //         onError: onError,
  //         mode: Mode.fullscreen,
  //         language: "en",
  //         location: currentPosition == null
  //             ? null
  //             : Location(currentPosition.latitude, currentPosition.longitude),
  //         radius: currentPosition == null ? null : 10000);

  //     showDetailPlace(p.placeId);
  //   } catch (e) {
  //     return;
  //   }
  // }
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  //   final placeDetail = place.result;
  //   final location = place.result.geometry.location;
  //   final lat = location.lat;
  //   final lng = location.lng;
  //   final center = LatLng(lat, lng);
  //   var markerOptions = Marker(
  //       position: center,
  //       infoWindow: InfoWindow(
  //           "${placeDetail.name}", "${placeDetail.formattedAddress}"));
  //   mapController.addMarker(markerOptions);
  //   mapController.animateCamera(CameraUpdate.newCameraPosition(
  //       CameraPosition(target: center, zoom: 15.0)));
  // }

}
