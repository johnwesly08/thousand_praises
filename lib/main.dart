import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ThousandPraiseApp());
}

class ThousandPraiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thousand Praises',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.notoSerifTamilTextTheme(),
      ),
      home: PraiseListScreen(),
    );
  }
}

class PraiseListScreen extends StatefulWidget {
  @override
  _PraiseListScreenState createState() => _PraiseListScreenState();
}

class _PraiseListScreenState extends State<PraiseListScreen> {
  List<dynamic> _praises = [];

  @override
  void initState() {
    super.initState();
    loadPraises();
  }

  Future<void> loadPraises() async {
    final String jsonString = await rootBundle.loadString('assets/praises.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _praises = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thousand Praises'),
      ),
      body: _praises.isEmpty ? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _praises.length,
        itemBuilder: (context, index) {
          final praise = _praises[index];
          return Card(
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    praise['reference'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    praise['praise'],
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}