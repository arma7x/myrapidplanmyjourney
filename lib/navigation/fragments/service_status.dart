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
  List<dynamic> listServiceStatus = [];
  Map<String, dynamic> listServiceMsg = {};

  _ServiceStatusState() {
    _getListServiceStatus();
    _getListServiceMsg();
  }

  @override
  bool get wantKeepAlive => true;

  Future<Null> _getListServiceStatus() async {
    try {
      final response = await Api.ListServiceStatus();
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          listServiceStatus = responseBody['data'];
          serviceStatusLoading = false;
        });
      } else {
        final snackBar = SnackBar(content: Text('Server Error'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on Exception {
      final snackBar = SnackBar(content: Text('Network Error'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
    return null;
  }

  Future<Null> _getListServiceMsg() async {
    try {
      Map<String, dynamic> tempListServiceMsg = {};
      final response = await Api.ListServiceMsg();
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        responseBody['data'][0].forEach((k, v) {
          tempListServiceMsg[k] = v;
        });
        setState(() {
          listServiceMsg = tempListServiceMsg;
          serviceMsgLoading = false;
        });
      } else {
        final snackBar = SnackBar(content: Text('Server Error'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on Exception {
      final snackBar = SnackBar(content: Text('Network Error'));
      Scaffold.of(context).showSnackBar(snackBar);
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
      for (var current in listServiceStatus) {
        var item = new Column(
          children: <Widget>[
            new ServiceStatusList.fromJson(current),
            new SizedBox(height: 10.0)
          ],
        );
        items.add(item);
      }
    }
    return items;
  }

  Widget _renderServiceMsg() {
    if (serviceStatusLoading) {
      return new Container(
        color: Colors.grey[50],
        width: (MediaQuery.of(context).size.width),
        height: (MediaQuery.of(context).size.width - 20) * 0.17,
        child: new Text(''),
      );
    } else {
      return new Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        width: (MediaQuery.of(context).size.width),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '* As at ' + (listServiceMsg['msg_date'] != null ? listServiceMsg['msg_date'] : '-') + ', ' + (listServiceMsg['msg_time'] != null ? listServiceMsg['msg_time'] : '-'),
              style: Theme.of(context).textTheme.body2.merge(TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                )
              )
            ),
            Text(
              '* Rail Service Performance: ' + (listServiceMsg['msg_performance'] != null ? listServiceMsg['msg_performance'] : '-'),
              style: Theme.of(context).textTheme.body2.merge(TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                )
              )
            ),
            Text(
              '* Rail Ridership: ' + (listServiceMsg['msg_ridership'] != null ? listServiceMsg['msg_ridership'] : '-'),
              style: Theme.of(context).textTheme.body2.merge(TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                )
              )
            ),
          ]
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new RefreshIndicator(
        child: new Container(
          child: new Column(
            children: <Widget>[
              _renderServiceMsg(),
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
          //setState(() {
          //  serviceStatusLoading = true;
          //  serviceMsgLoading = true;
          //});
          await _getListServiceStatus();
          await _getListServiceMsg();
          return null;
        }
      )
    );
  }
}
