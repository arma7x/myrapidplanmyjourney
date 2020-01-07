import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myrapidplanmyjourney/api.dart';

class ServiceStatus extends StatefulWidget {
  @override
  _ServiceStatusState createState() => new _ServiceStatusState();
}

class _ServiceStatusState extends State<ServiceStatus> {

  List<dynamic> _list_service_status = [];

  _ServiceStatusState() {
    _getListServiceStatus();
  }

  Future<Null> _getListServiceStatus() async {
    try {
      final response = await await Api.ListServiceStatus();
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          _list_service_status = responseBody['data'];
        });
        print(_list_service_status);
      } else {
        //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
      }
    } on Exception {
      //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
    }
    return null;
  }

  List<Widget> _renderServiceStatus() {
    List<Widget> items = [];
    for (var current in _list_service_status) {
      var item = new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(current['service_name']),
          ),
          new Divider(
            height: 2.0,
          )
        ],
      );

      items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new RefreshIndicator(
        child: new ListView(
          children: _renderServiceStatus(),
        ),
        onRefresh: _getListServiceStatus,
      )
    );
  }
}
