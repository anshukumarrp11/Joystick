import 'package:flutter/material.dart';
import 'dart:math';
import 'package:roslibdart/roslibdart.dart';

class Joystick360 extends StatefulWidget {
  final String topic;
  final String messageType;
  final String rosBridgeUrl;
  final double size;

  Joystick360({
    required this.topic,
    required this.messageType,
    required this.rosBridgeUrl,
    required this.size,
  });

  @override
  _Joystick360State createState() => _Joystick360State();
}

class _Joystick360State extends State<Joystick360> {
  late Ros ros;
  late Topic topic;
  Offset _center = Offset(0, 0);
  Offset _thumbPosition = Offset(0, 0);
  double _maxRadius = 0;
  double _radius = 0;
  double _angle = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    try {
      ros = Ros(url: widget.rosBridgeUrl);
      ros.connect();
      topic = Topic(
        ros: ros,
        name: widget.topic,
        type: widget.messageType,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void _onPanStart(DragStartDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    _center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    _maxRadius = _center.dx - renderBox.localToGlobal(Offset.zero).dx;
    _thumbPosition = _center;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _thumbPosition += details.delta;
        _radius = _calcJoystickDistance();
        _angle = _calcJoystickAngle();
        topic.publish({
          "linear": {"x": _calcX(), "y": 0, "z": 0},
          "angular": {"x": 0, "y": 0, "z": _calc_yaw_vel()},
        });
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDragging) {
      setState(() {
        _thumbPosition = _center;
        _radius = 0;
        _angle = 0;
        _isDragging = false;
        topic.publish({
          "linear": {"x": 0, "y": 0, "z": 0},
          "angular": {"x": 0, "y": 0, "z": 0},
        });
      });
    }
  }

  double _calcJoystickAngle() {
    return atan2(
      _thumbPosition.dy - _center.dy,
      _thumbPosition.dx - _center.dx,
    );
  }

  double _calcJoystickDistance() {
    double dx = _thumbPosition.dx - _center.dx;
    double dy = _thumbPosition.dy - _center.dy;
    return dx * dx + dy * dy <= _maxRadius * _maxRadius
        ? _radius = dx * dx + dy * dy
        : _maxRadius * _maxRadius;
  }

  double _calcX() {
    var J = -1 * (_radius * (0.8 / 18225.0) * sin(_angle));
    print("Linear Velocity is : " + J.toString());
    print("Radius  X  : " + _radius.toString());
    print("Angle X  : " + _angle.toString());
    // if (_angle < 0) {
    //   J = J;
    // } else if (_angle > 0) {
    //   J = -J;
    // }
    // print(J.toString() + " " + _angle.toString());
    return J;
  } // for linear

  double _calcY() {
    var J = -1 * (_radius * (0.8 / 18225.0) * sin(_angle));
    print("Linear Velocity is : " + J.toString());
    print("Radius Y  : " + _radius.toString());
    print("Angle Y  : " + _angle.toString());
    // if (_angle < 0) {
    //   J = J;
    // } else if (_angle > 0) {
    //   J = -J;
    // }
    // print(J.toString() + " " + _angle.toString());
    return J;
  } // for linear

  double _calc_yaw_vel() {
    var J = -1 * (1.6 * cos(_angle));
    print("Angular Velocity is : " + J.toString());
    // if (_angle < 0) {
    //   J = J;
    //   _angle = _angle;
    // } else if (_angle > 0) {
    //   J = -J;
    //   _angle = -_angle;
    // }
    return J;
  } // for angular

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: _thumbPosition.dx - _center.dx + 123,
              top: _thumbPosition.dy - _center.dy + 121,
              child: Container(
                width: widget.size! * 0.30,
                height: widget.size! * 0.30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ros.close();
    super.dispose();
  }
}
