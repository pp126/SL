import 'package:flutter/material.dart';

class Triangle extends CustomClipper<Path> {
  double dir;
  bool isBezier;

  Triangle({this.dir,this.isBezier = false});
  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;
    if(isBezier) {
      if (dir < 0) {
        path.moveTo(0, h);
        path.quadraticBezierTo(0, 0, w * 2 / 3, 0);
        path.quadraticBezierTo(w / 4, h / 2, w, h);
      } else {
        path.quadraticBezierTo(0, h / 2, w * 2 / 3, h);
        path.quadraticBezierTo(w / 3, h / 3, w, 0);
        path.lineTo(0, 0);
      }
    }else{
      if (dir < 0) {
        path.moveTo(0, h);
        path.lineTo(w/2, 0);
        path.lineTo(w, h);
      } else {
        path.moveTo(0, 0);
        path.lineTo(w/2, h);
        path.lineTo(w, 0);
      }
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}