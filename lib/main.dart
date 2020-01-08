import 'package:flutter/material.dart';
import 'package:myrapidplanmyjourney/navigation/fragments.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan My Journey - RapidKL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Plan My Journey - RapidKL'),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0.0,
        ),
        body: TabBarView(
          children: [
            new PlanMyJourney(),
            new ServiceStatus(),
          ],
        ),
        bottomNavigationBar: new TabBar(
          tabs: [
            Tab(
              icon: new Icon(Icons.transfer_within_a_station),
              text: 'Trip',
            ),
            Tab(
              icon: new Icon(Icons.traffic),
              text: 'Traffic',
            ),
          ],
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: EdgeInsets.all(5.0),
          indicatorColor: Colors.red,
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
