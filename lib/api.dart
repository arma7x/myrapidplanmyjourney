import 'dart:core';
import 'package:http/http.dart' as http;

class Api {

  static const String BASE_URL = 'malaysiaapi.herokuapp.com';
  static const String LIST_SERVICE_MSG = 'rapidkl/api/v1/list_service_msg';
  static const String LIST_SERVICE_STATUS = 'rapidkl/api/v1/list_service_status';
  static const String LIST_STREET_AUTOCOMPLETE = 'rapidkl/api/v1/list_street_autocomplete';
  static const String LIST_PLANNER = 'rapidkl/api/v1/list_planner';

  static Future ListServiceMsg() async {
    final url = Uri.https(BASE_URL, LIST_SERVICE_MSG);
    return await http.get(url);
  }

  static Future ListServiceStatus() async {
    final url = Uri.https(BASE_URL, LIST_SERVICE_STATUS);
    return await http.get(url);
  }

  // &term
  static Future ListStreetAutocomplete(Map<String, String> query) async {
    final url = Uri.https(BASE_URL, LIST_STREET_AUTOCOMPLETE, query);
    return await http.get(url);
  }

  // &flng
  // &flat
  // &tlng
  // &tlat
  // &time(HH:mm:ss)
  // &mode(bus || rail || ""[mixed])
  // &type(leasttransit[Least Transfer]) || ""[Shortes Time])
  static Future ListPlanner(Map<String, String> query) async {
    final url = Uri.https(BASE_URL, LIST_PLANNER, query);
    return await http.get(url);
  }
}
