import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/barber.dart';
import '../models/env.dart';
import '../models/http_exception.dart';

class BarberProvider with ChangeNotifier {
  List<Barber> _barbers = [];

  List<Map<String, dynamic>> _workingTime = [];

  String workingHours = "";

  List<DateTime> _offdays = [];

  // List<int> get freeWeekdays {
  //   return [..._freeWeekdays];
  // }

  List<Barber> get barbers {
    return [..._barbers];
  }

  Future<void> fetchBarbers() async {
    _barbers = [];
    try {
      final response =
          await http.get(Uri.parse(EnviromentVariables.baseUrl + "barbers"));
      final responseData = json.decode(response.body) as List<dynamic>;

      for (var data in responseData) {
        var barber = data as Map<String, dynamic>;

        _barbers.add(
          Barber(
            id: barber["id"].toString(),
            email: barber["email"],
            firstName: barber["firstName"],
            lastName: barber["lastName"],
            phoneNum: barber["phone"] ?? "",
            pictureUrl: barber["pictureFullPath"] ?? "",
            daysoff: [],
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  Future<void> fetchDaysoff() async {
    try {
      final response =
          await http.get(Uri.parse(EnviromentVariables.baseUrl + "daysoff/"));
      final responseData = json.decode(response.body) as List<dynamic>;

      for (var data in responseData) {
        var freeData = data as Map<String, dynamic>;

        var startDate = DateTime.parse(freeData["startDate"] as String);
        var endDate = DateTime.parse(freeData["endDate"] as String);
        var barberId = freeData["userId"] as String;
        List<DateTime> dates = [];

        dates.add(startDate);

        while (startDate != endDate) {
          startDate = startDate.add(const Duration(days: 1));
          dates.add(startDate);
        }
        _barbers.firstWhere((element) => element.id == barberId).daysoff = [];
        for (var date in dates) {
          _barbers
              .firstWhere((element) => element.id == barberId)
              .daysoff
              .add(date);
        }
      }
      notifyListeners();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  Future<void> fetchWorkingTime() async {
    _workingTime = [];
    try {
      final response = await http
          .get(Uri.parse(EnviromentVariables.baseUrl + "workingtime/"));

      final resposeData = json.decode(response.body) as List<dynamic>;

      for (var elementData in resposeData) {
        _workingTime.add(elementData);
      }
      notifyListeners();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  List<Map<String, dynamic>> findWorkingTime(String barberId, String weekDay) {
    return _workingTime
        .where((element) =>
            element["userId"] == barberId && element["weekDay"] == weekDay)
        .toList();
  }

  List<Map<String, dynamic>> findWorkingDays(String barberId) {
    return _workingTime
        .where((element) => element["userId"] == barberId)
        .toList();
  }

  Future<void> fetchWorkingHours() async {
    try {
      final response = await http
          .get(Uri.parse(EnviromentVariables.baseUrl + "workinghours/"));
      final responseData = json.decode(response.body) as List<dynamic>;

      String startTime =
          responseData[0]["startTime"].toString().substring(0, 5);
      String endTime = responseData[0]["endTime"].toString().substring(0, 5);

      workingHours = startTime + " - " + endTime;
      notifyListeners();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }
}
