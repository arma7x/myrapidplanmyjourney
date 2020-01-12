import 'dart:convert';
import 'package:flutter/material.dart';

class RouteDetail extends StatefulWidget {
  final String t_id;
  final String t_no;
  final String t_depart;
  final String t_depart_hour;
  final String t_depart_min;
  final String t_depart_tt;
  final String t_route;
  final String t_distance;
  final String t_duration;
  final String t_duration_hour;
  final String t_duration_min;
  final String t_fare;
  final Map<String, dynamic> t_fare_price;
  final List<dynamic> t_transport;
  final String t_steps;
  final List<dynamic> t_detail;
  final List<dynamic> t_geometry;
  final List<dynamic> t_geometry_point;
  final String t_stop_name;
  final String t_leg;
  final String t_arrival_time;

  RouteDetail._(
      {Key key,
      this.t_id,
      this.t_no,
      this.t_depart,
      this.t_depart_hour,
      this.t_depart_min,
      this.t_depart_tt,
      this.t_route,
      this.t_distance,
      this.t_duration,
      this.t_duration_hour,
      this.t_duration_min,
      this.t_fare,
      this.t_fare_price,
      this.t_transport,
      this.t_steps,
      this.t_detail,
      this.t_geometry,
      this.t_geometry_point,
      this.t_stop_name,
      this.t_leg,
      this.t_arrival_time});

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return new RouteDetail._(
      t_id: json['t_id'],
      t_no: json['t_no'],
      t_depart: json['t_depart'],
      t_depart_hour: json['t_depart_hour'],
      t_depart_min: json['t_depart_min'],
      t_depart_tt: json['t_depart_tt'],
      t_route: json['t_route'],
      t_distance: json['t_distance'],
      t_duration: json['t_duration'],
      t_duration_hour: json['t_duration_hour'],
      t_duration_min: json['t_duration_min'],
      t_fare: json['t_fare'],
      t_fare_price: json['t_fare_price'],
      t_transport: json['t_transport'],
      t_steps: json['t_steps'],
      t_detail: json['t_detail'],
      t_geometry: json['t_geometry'],
      t_geometry_point: json['t_geometry_point'],
      t_stop_name: json['t_stop_name'],
      t_leg: json['t_leg'],
      t_arrival_time: json['t_arrival_time'],
    );
  }

  @override
  _RouteDetailState createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {

  _RouteDetailState();

  Widget _renderPrice(Widget name, Widget price, Color bg_color) {
    return new Container(
      color: bg_color,
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      width: (MediaQuery.of(context).size.width) / 2,
      height: (MediaQuery.of(context).size.width - 20) * 0.20,
      child: new Row(
        children: <Widget>[name, price]
      )
    );
  }

  List<Widget> _renderFarePrices() {
    List<Widget> prices = [];
    List<Widget> prices_row = [];
    prices_row.add(_renderPrice(
      new Icon(Icons.local_atm, color: Colors.white, size: 38),
      Text(
        ' FARE PRICES',
        style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))
      ),
      Theme.of(context).primaryColor
    ));
    widget.t_fare_price.forEach((k, v) {
      Color bg_color = Theme.of(context).primaryColor;
      switch (k) {
        case 'Cash':
          bg_color = Colors.grey;
          break;
        case 'Cashless':
          bg_color = Colors.red;
          break;
        case 'Concession':
          bg_color = Colors.purple;
          break;
        case 'Monthly':
          bg_color = Colors.green;
          break;
        case 'Weekly':
          bg_color = Colors.teal;
          break;
      }
      prices_row.add(_renderPrice(
        Text(
          k.toUpperCase() + ': ',
          style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
        ),
        Text(
          v.toUpperCase(),
          style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
        ),
        bg_color
      ));
      if (prices_row.length == 2) {
        prices.add(new Row(children: <Widget>[...prices_row]));
        prices_row = [];
      }
    });
    return prices;
  }

  Widget _renderDetail() {
    List<Widget> details = [];
    details.add(new Center(
      child: new Text(
        'Transport Detail',
        style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))
      )
    ));
    details.add(new SizedBox(height: 10));
    for (var i in widget.t_detail) {
      details.add(new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            width: (MediaQuery.of(context).size.width - 20) * 0.20,
            child: new Text(
              i['time'],
              style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
            ),
          ),
          i['time'].contains(':') 
          ? new Icon(Icons.lens, color: Colors.white, size: 22)
          : new Container(
            width: (MediaQuery.of(context).size.width - 20) * 0.02,
            height: (MediaQuery.of(context).size.width - 20) * 0.25,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(3.0),
                topRight: const Radius.circular(3.0),
                bottomLeft: const Radius.circular(3.0),
                bottomRight: const Radius.circular(3.0),
              )
            )
          ),
          new Container(
            width: (MediaQuery.of(context).size.width - 20) * 0.70,
            child: new Text(
              i['place'],
              style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
            )
          ),
        ]
      ));
    }
    return new Container(
      color: Colors.red,
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      width: (MediaQuery.of(context).size.width),
      child: new Column(
        children: <Widget>[...details],
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.t_route),
          elevation: 0.0,
        ),
        body: new Container(
          child: new ListView(
            children: <Widget>[
              ..._renderFarePrices(),
              _renderDetail(),
              new Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.fromLTRB(10.0, 10, 10.0, 10),
                child: new Column(
                  children: <Widget>[
                    Text(
                      '**Interchange Station : Passengers are NOT REQUIRED to exit station and may proceed to interchange station.',
                      style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
                    ),
                    new SizedBox(height: 5),
                    Text(
                      '**Connecting Station : Passengers are REQUIRED to exit and purchase new token at the connecting station.',
                      style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
                    ),
                    new SizedBox(height: 5),
                    Text(
                      '**Rapid KL Bus and MRT Feeder Bus only accept cashless mode.',
                      style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
                    ),
                    new SizedBox(height: 5),
                    Text(
                      '**Disclaimer: These directions are for planning purposes only. You may find that construction projects, traffic, weather, or other events may cause conditions to differ from the map results, and you should plan your route accordingly. You must obey all signs or notices regarding your route.',
                      style: Theme.of(context).textTheme.body2.merge(TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
                    ),
                  ]
                )
              ),
            ]
          )
        )
    );
  }
}
