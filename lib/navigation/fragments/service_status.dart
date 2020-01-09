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

  bool serviceStatusLoading = false;
  bool serviceMsgLoading = false;
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
          serviceStatusLoading = true;
        });
      } else {
        //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
      }
    } on Exception {
      //Fluttertoast.showToast(msg: "Network Error", toastLength: Toast.LENGTH_SHORT);
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
          serviceMsgLoading = true;
        });
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
    if (serviceStatusLoading) {
      for (var current in listServiceStatus) {
        var item = new Column(
          children: <Widget>[
            new ServiceStatusList.fromJson(current),
            new SizedBox(height: 10.0)
          ],
        );
        items.add(item);
      }
    } else {
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
    }
    return items;
  }

  Widget _renderServiceMsg() {
    return new Card(
      margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      color: serviceStatusLoading ? Theme.of(context).primaryColor : Colors.grey[50],
      child: serviceStatusLoading ? new Container(
        padding: EdgeInsets.all(10),
        width: (MediaQuery.of(context).size.width - 20),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'As at ' + (listServiceMsg['msg_date'] != null ? listServiceMsg['msg_date'] : '-') + ', ' + (listServiceMsg['msg_time'] != null ? listServiceMsg['msg_time'] : '-'),
              style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
            ),
            Text(
              'Rail Service Performance: ' + (listServiceMsg['msg_performance'] != null ? listServiceMsg['msg_performance'] : '-'),
              style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
            ),
            Text(
              'Rail Ridership: ' + (listServiceMsg['msg_ridership'] != null ? listServiceMsg['msg_ridership'] : '-'),
              style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
            ),
          ]
        )
      ) : SizedBox(
        width: (MediaQuery.of(context).size.width - 20),
        height: (MediaQuery.of(context).size.width - 20) * 0.17,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new RefreshIndicator(
        child: new Container(
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 10.0),
              _renderServiceMsg(),
              new SizedBox(height: 10.0),
              new Expanded(
                child: new ListView(
                  children: _renderServiceStatus(),
                )
              )
            ]
          )
        ),
        onRefresh: () async {
          setState(() {
            serviceStatusLoading = false;
            serviceMsgLoading = false;
          });
          await _getListServiceStatus();
          await _getListServiceMsg();
          return null;
        }
      )
    );
  }
}
