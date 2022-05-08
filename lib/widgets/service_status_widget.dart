import 'package:flutter/material.dart';

class ServiceStatusList extends StatelessWidget {

  final String name;
  final String status;

  ServiceStatusList(this.name, this.status);

  @override
  Widget build(BuildContext context) {

    return new Card(
      margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      color: this.status == 'Normal Service' ? Colors.green : Colors.orange[900],
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              this.name,
              style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
            ),
            new Text(
              this.status,
              style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: Colors.white,))
            ),
          ]
        )
      )
    );

  }
}
