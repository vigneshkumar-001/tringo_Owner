import 'package:flutter/material.dart';

class SurpriseOfferList extends StatefulWidget {
  const SurpriseOfferList({super.key});

  @override
  State<SurpriseOfferList> createState() => _SurpriseOfferListState();
}

class _SurpriseOfferListState extends State<SurpriseOfferList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
