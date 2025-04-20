import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:watchscorefront/screens/seriesRegister_screen.dart';

class SeriesList extends StatefulWidget {
  const SeriesList({super.key});

  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey[100]);
  }
}
