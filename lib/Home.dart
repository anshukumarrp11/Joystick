import 'package:flutter/material.dart';
import 'package:teleop/Joystick360.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "JoyStick",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Joystick360(
                topic: 'cmd_vel',
                messageType: 'geometry_msgs/Twist',
                rosBridgeUrl: 'ws://192.168.10.202:9090',
                size: 360,
              ),
              Joystick360(
                topic: 'cmd_vel',
                messageType: 'geometry_msgs/Twist',
                rosBridgeUrl: 'ws://192.168.10.201:9090',
                size: 360,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
