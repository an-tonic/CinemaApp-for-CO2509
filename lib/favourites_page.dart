import 'package:flutter/material.dart';
import 'no_internet_popup.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  final ScrollController _scrollController = ScrollController();
  Color? startColor;
  Color? endColor;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        _scrollPosition = _scrollController.offset;
        startColor = Color.lerp(Colors.blue.shade900, Colors.red.shade900,
            _scrollPosition / maxScrollExtent);
        endColor = Color.lerp(Colors.red.shade900, Colors.blue.shade900,
            _scrollPosition / maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                startColor ?? Colors.blue.shade900,
                endColor ?? Colors.red.shade900,
              ],
            ),
          ),
          child: Text("s"),
        ));
  }
}
