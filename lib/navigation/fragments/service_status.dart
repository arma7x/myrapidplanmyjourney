import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myrapidplanmyjourney/api.dart';
import 'package:myrapidplanmyjourney/widgets/service_status_widget.dart';

class ServiceStatus extends StatefulWidget {
  @override
  _ServiceStatusState createState() => new _ServiceStatusState();
}

class _ServiceStatusState extends State<ServiceStatus> with AutomaticKeepAliveClientMixin<ServiceStatus> {

  bool serviceStatusLoading = true;
  bool serviceMsgLoading = true;
  Map<String, String> listServiceStatus = {};
  Map<String, dynamic> listServiceMsg = {};

  _ServiceStatusState() {
    _getListServiceStatus();
  }

  @override
  bool get wantKeepAlive => true;

  Future<Null> _getListServiceStatus() async {
    try {
      final response = await Api.ListServiceStatus();
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          listServiceStatus = Map.from(responseBody['data']);
          serviceStatusLoading = false;
        });
      } else {
        final snackBar = SnackBar(content: Text('Server Error'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on Exception {
      final snackBar = SnackBar(content: Text('Network Error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return null;
  }

  List<Widget> _renderServiceStatus() {
    List<Widget> items = [];
    if (serviceStatusLoading) {
      for (var i=0; i<5; i++) {
        items.add(new Card(
          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          color: serviceStatusLoading ? Colors.white : Colors.grey[50],
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 20),
            height: (MediaQuery.of(context).size.width - 20) * 0.20,
          )
        ));
        items.add(new SizedBox(height: 10.0));
      }
    } else {
      listServiceStatus.forEach((k,v) {
        var item = new Column(
          children: <Widget>[
            new ServiceStatusList(k, v),
            new SizedBox(height: 10.0)
          ],
        );
        items.add(item);
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
      color: Colors.white,
      child: new RefreshIndicator(
        child: new Container(
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 5.0),
              new Expanded(
                child: new ListView(
                  children: _renderServiceStatus(),
                )
              )
            ]
          )
        ),
        onRefresh: () async {
          await _getListServiceStatus();
          return null;
        }
      )
    );
  }
}
