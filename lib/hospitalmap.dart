import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapNew extends StatefulWidget {
  @override
  _MapNewState createState() => _MapNewState();
}

class _MapNewState extends State<MapNew> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  double mapBottomPadding = 0;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;

  Position currentPosition;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  static final CameraPosition _myHome = CameraPosition(
    target: LatLng(-6.196690, 106.888430),
    zoom: 14.4746,
  );

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

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
              });
              //function to get current location
              setupPositionLocator();
            }),
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
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Search Hospitals'),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text('Alamat RS 1'),
                      ),
                      ListTile(
                        title: Text('Alamat RS 2'),
                      ),
                      ListTile(
                        title: Text('Alamat RS 3'),
                      ),
                    ]),
                  ),
                );
              }),
        ),
      ]),
    );
    return scaffold;
  }
}
