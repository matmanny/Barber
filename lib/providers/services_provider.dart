import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/services.dart';
import '../models/http_exception.dart';
import '../models/env.dart';

class ServicesProvider with ChangeNotifier {
  List<Service> _services = [];

  List<Service> get services {
    return [..._services];
  }

  Future<void> fetchServices() async {
    _services = [];
    try {
      final response =
          await http.get(Uri.parse(EnviromentVariables.baseUrl + "services"));
      final responseData = jsonDecode(response.body) as List<dynamic>;
      for (var data in responseData) {
        var service = data as Map<String, dynamic>;
        _services.add(
          Service(
            id: service["id"].toString(),
            name: service["name"],
            normalPrice: double.parse(service["price"]),
            studentPrice: double.parse(service["studentPrice"] ?? "0.0"),
            durationSeconds: double.parse(service["duration"]),
            pictureUrl: service["pictureFullPath"] ?? "",
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }
}
