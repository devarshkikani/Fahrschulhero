import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:drive/src/modules/school_list/school_detail/school_detail_screen.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SchoolDetailController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? mapController;
  final GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  late LatLng initialcameraposition;
  Set<Marker> markers = {};
  RxBool showPadding = false.obs;
  PolylinePoints polylinePoints = PolylinePoints();
  RxMap<PolylineId, Polyline> polylines = <PolylineId, Polyline>{}.obs;
  List<LatLng> polylineCoordinates = [];
  PanelController panelController = new PanelController();
  ScrollController scrollController =
      new ScrollController(keepScrollOffset: true);
  double? panelHeightOpen;
  double panelHeightClosed = 90.0;

  @override
  void onInit() {
    initialcameraposition =
        LatLng(_globalSingleton.latitude!, _globalSingleton.longitude!);
    makeLines();

    super.onInit();
  }

  @override
  void onReady() {
    panelController.animatePanelToPosition(0.5);
    super.onReady();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    mapController = controller;
  }

  void onMapTap() {
    panelController.animatePanelToPosition(0.0);
  }

  void createMarker(dynamic data, double mkColor) async {
    markers = {
      Marker(
        markerId: MarkerId('source'),
        position:
            LatLng(_globalSingleton.latitude!, _globalSingleton.longitude!),
        infoWindow: InfoWindow(title: data['name']),
        visible: true,
        icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset("assets/icons/start_map.png", 50)),
        onTap: () {},
      ),
      Marker(
        markerId: MarkerId('destination'),
        position: LatLng(data['latitude'], data['longitude']),
        infoWindow: InfoWindow(title: data['name']),
        visible: true,
        icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset("assets/icons/end_map.png", 50)),
        onTap: () {},
      ),
    };
  }

  void makeLines() async {
    await polylinePoints
        .getRouteBetweenCoordinates(
      'AIzaSyDZZeGlIGUIPs4o8ahJE_yq6pJv3GhbKQ8',
      PointLatLng(_globalSingleton.latitude!,
          _globalSingleton.longitude!), //Starting LATLANG
      PointLatLng(
          schoolData['latitude'], schoolData['longitude']), //End LATLANG
      travelMode: TravelMode.driving,
    )
        .then((value) {
      value.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }).then((value) {
      addPolyLine();
    });
  }

  addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: appColor,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
