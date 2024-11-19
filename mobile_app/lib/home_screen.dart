import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:socket_io_client/socket_io_client.dart' as socketIo;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late socketIo.Socket socket;
  final player = AudioPlayer();
  int lpg = 0;
  @override
  void initState() {
    super.initState();

    // Connect to the Socket.IO server
    socket = socketIo.io(socketUrl(), <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on("data", (data) {
      setState(() {
        lpg = data;
      });
      playSound();
    });
  }

  Future<void> playSound() async {
    if (lpg > 12000) {
      player.setReleaseMode(ReleaseMode.loop);
      await player.play(
        AssetSource('sound/alarm.mp3'),
      );
    }
    if (lpg < 12000) {
      await player.stop();
    }
  }

  String socketUrl() {
    if (Platform.isAndroid) {
      return "http://192.168.1.45:4000";
    } else {
      return "http://localhost:4000";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: SfRadialGauge(
            backgroundColor: Colors.white,
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                showAxisLine: false,
                showTicks: false,
                maximum: 12000,
                showLabels: false,
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 4000,
                    color: Colors.green,
                    startWidth: 100,
                    endWidth: 100,
                    label: 'Low',
                    labelStyle: GaugeTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  GaugeRange(
                    startValue: 4000,
                    endValue: 9000,
                    color: Colors.orange,
                    startWidth: 100,
                    endWidth: 100,
                    label: 'Warning',
                    labelStyle: GaugeTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  GaugeRange(
                    startValue: 9000,
                    endValue: 12000,
                    color: Colors.red,
                    startWidth: 100,
                    endWidth: 100,
                    label: 'Danger',
                    labelStyle: GaugeTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: lpg.toDouble(),
                    enableAnimation: true,
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Container(
                      child: Text(
                        '$lpg',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
