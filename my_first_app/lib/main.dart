import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  GoogleMapController mapController;

  LatLng _center = LatLng(45.521563, -122.677433);
  LatLng _dragLocation = LatLng(45.521563, -122.677433);
  List<Placemark> _placemarks = [];
  String address = "default address";

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var androidInitSettting;
  var iosInitSetting;
  var initSetting;

  Future<Null> _onSelectionNotification(payload) async {
    print('payload is $payload');
  }

  // Method 2
  Future _showNotificationWithDefaultSound() async {
    print('begin _showNotificationWithDefaultSound');
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      111,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics
    );
    print('end _showNotificationWithDefaultSound');
  }

  // Method 3
  Future _showNotificationWithoutSound(String title, String message, String additionalData) async {
    print('begin _showNotificationWithoutSound');
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: false, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      123,
      title,
      message,
      platformChannelSpecifics,
      payload: additionalData,
    );
    print('end _showNotificationWithoutSound');
  }


  @override
  void initState() {
    print('---initState---');
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    androidInitSettting = AndroidInitializationSettings('@mipmap/ic_launcher');
    iosInitSetting = IOSInitializationSettings();
    initSetting =  InitializationSettings(androidInitSettting,iosInitSetting);
    flutterLocalNotificationsPlugin.initialize(initSetting,
      onSelectNotification: _onSelectionNotification
    );
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final body = message["notification"]["body"];
        final title = message["notification"]["title"];
        final payload = jsonEncode(message["data"]);
        print('body: $body >> title: $title >> payload: $payload');
        _showNotificationWithoutSound(title, body, payload);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
//    _firebaseMessaging.requestNotificationPermissions(
//        const IosNotificationSettings(
//            sound: true, badge: true, alert: true, provisional: true));
//    _firebaseMessaging.onIosSettingsRegistered
//        .listen((IosNotificationSettings settings) {
//      print("Settings registered: $settings");
//    });
    _firebaseMessaging.getToken().then((String token) {
      print("Push Messaging token: $token");
    });
//    _firebaseMessaging.subscribeToTopic("matchscore");
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget _buildMap() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Container(
              width: 500,
              height: 500,
              child: GoogleMap(
                  onCameraIdle: () async => {
                    setState(() {
                      print('onCameraIdle');
                      _center = _dragLocation;
                    }),
                    _placemarks = await Geolocator()
                        .placemarkFromCoordinates(
                        _center.latitude, _center.longitude),
                    setState(() {
                      address = '${_placemarks[0].country}, '
//                        '${_placemarks[0].position}, '
                          '${_placemarks[0].locality}, '
                          '${_placemarks[0].administrativeArea}, '
                          '${_placemarks[0].postalCode}, '
                          '${_placemarks[0].name}, '
                          '${_placemarks[0].subAdministrativeArea}, '
                          '${_placemarks[0].isoCountryCode}, '
//                        '${_placemarks[0].subLocality}, '
//                        '${_placemarks[0].subThoroughfare}, '
                          '${_placemarks[0].thoroughfare}';
                      print(_placemarks[0].country);
                      print(_placemarks[0].position);
                      print(_placemarks[0].locality);
                      print(_placemarks[0].administrativeArea);
                      print(_placemarks[0].postalCode);
                      print(_placemarks[0].name);
                      print(_placemarks[0].subAdministrativeArea);
                      print(_placemarks[0].isoCountryCode);
                      print(_placemarks[0].subLocality);
                      print(_placemarks[0].subThoroughfare);
                      print(_placemarks[0].thoroughfare);
                    })
                  },
                  onCameraMove: (cameraPos) => {
                    _dragLocation = cameraPos.target,
                    print('camera position = '
                        '${cameraPos.target.latitude}, '
                        '${cameraPos.target.longitude}')
                  },
                  onCameraMoveStarted: () => {print('onCameraMoveStarted')},
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 17.0,
                  ),
                  markers: Set<Marker>.of(
                    <Marker>[
                      Marker(
                          onTap: () {
                            print('Tapped');
                          },
                          draggable: true,
                          markerId: MarkerId('Marker'),
                          position: _dragLocation ?? _center,
                          onDragEnd: ((value) {
                            print(
                                'values is ${value.latitude}, ${value.longitude}');
                            setState(() {
                              print(
                                  'setState inDragEnd is ${value.latitude}, ${value.longitude}');
                              _dragLocation = value;
                            });
                          }))
                    ],
                  )),
            )),
        Text(
          address,
          style: TextStyle(fontSize: 18),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text('Hello world...'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{

        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
      print('myBackgroundMessageHandler data = $data');
    }

    if (message.containsKey('notification')) {
      final dynamic notification = message['notification'];
      print('myBackgroundMessageHandler notification = $notification');
    }

  }
}
