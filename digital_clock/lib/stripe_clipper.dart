import 'package:flutter/material.dart';

class StripClipper extends CustomClipper<Path> {
  final double extent;

  StripClipper({this.extent});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, extent);
    path.lineTo(extent, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class StripsWidget extends StatelessWidget {
  final Color color1;
  final Color color2;
  final double gap;
  final noOfStrips;

  const StripsWidget(
      {Key key, this.color1, this.color2, this.gap, this.noOfStrips})
      : super(key: key);

  List<Widget> getListOfStripes() {
    List<Widget> stripes = [];
    for (var i = 0; i < noOfStrips; i++) {
      stripes.add(
        ClipPath(
          child: Container(color: (i % 2 == 0) ? color1 : color2),
          clipper: StripClipper(extent: i * gap),
        ),
      );
    }
    return stripes;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: getListOfStripes());
  }
}
