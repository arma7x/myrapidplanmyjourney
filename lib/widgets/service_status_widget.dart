import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServiceStatusList extends StatelessWidget {

  final String service_id;
  final String service_name;
  final String service_logo;
  final String setting_id;
  final String service_desc;
  final String action_By;
  final String action_date;
  final String setting_cssclass;

  ServiceStatusList._(
      {Key key,
      this.service_id,
      this.service_name,
      this.service_logo,
      this.setting_id,
      this.service_desc,
      this.action_By,
      this.action_date,
      this.setting_cssclass});

  factory ServiceStatusList.fromJson(Map<String, dynamic> json) {
    return new ServiceStatusList._(
      service_id: json['service_id'],
      service_name: json['service_name'],
      service_logo: 'https://myrapid.com.my/clients/Myrapid_Prasarana_37CB56E7-2301-4302-9B98-DFC127DD17E9/contentms/img/' + json['service_logo'],
      setting_id: json['setting_id'],
      service_desc: json['service_desc'],
      action_By: json['action_By'],
      action_date: json['action_date'],
      setting_cssclass: json['setting_cssclass'],
    );
  }

  @override
  Widget build(BuildContext context) {

    return new Card(
      margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      color: this.setting_cssclass == 'green' ? Colors.green : Colors.orange,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            width: (MediaQuery.of(context).size.width - 20) * 0.20,
            height: (MediaQuery.of(context).size.width - 20) * 0.20,
            child: new ClipRect(
              child: new OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                minWidth: (MediaQuery.of(context).size.width - 20) * 0.20,
                minHeight: (MediaQuery.of(context).size.width - 20) * 0.20,
                alignment: Alignment.center,
                child: new FittedBox(
                  fit: BoxFit.none,
                  alignment: Alignment.center,
                  child: new Image(
                    width: (MediaQuery.of(context).size.width) * 0.20,
                    height: (MediaQuery.of(context).size.width) * 0.20,
                    fit: BoxFit.fill,
                    image: NetworkImage(this.service_logo),
                  )
                )
              )
            )
          ),
          new Container(
            width: (MediaQuery.of(context).size.width - 20) * 0.80,
            height: (MediaQuery.of(context).size.width - 20) * 0.20,
            padding: EdgeInsets.all(10),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  this.service_name,
                  style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
                ),
                new Text(
                  this.service_desc,
                  style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white,))
                ),
              ]
            ),
          ),
        ]
      )
    );

  }
}
