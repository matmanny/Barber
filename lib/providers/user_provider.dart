import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../localization/language_constraints.dart';
import '../models/env.dart';
import '../models/user.dart';
import '../models/http_exception.dart';
import '../pages/auth_page.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User get user {
    return _user!;
  }

  Future<void> login(String email, String password) async {
    logout();
    final Map<String, dynamic> user = {'email': email, 'password': password};
    try {
      final response = await http.post(
        Uri.parse(EnviromentVariables.baseUrl + 'login'),
        body: json.encode(user),
      );
      final responseMap = json.decode(response.body) as Map<String, dynamic>;
      if (responseMap['Success'] == null) {
        throw HttpException(responseMap['Failure']);
      } else {
        await fetchUserInfo(email);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchUserInfo(String email) async {
    final requestData = {"email": email};
    try {
      final response = await http.post(
        Uri.parse(EnviromentVariables.baseUrl + "user"),
        body: json.encode(requestData),
      );
      final responseList = json.decode(response.body) as List<dynamic>;
      final responseMap = responseList[0] as Map<String, dynamic>;

      _user = User(
          id: responseMap["id"].toString(),
          email: responseMap["email"],
          firstName: responseMap["firstName"],
          lastName: responseMap["lastName"],
          phoneNum: responseMap["phone"]);
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'id': _user!.id,
        'firstName': _user!.firstName,
        'lastName': _user!.lastName,
        'phoneNum': _user!.phoneNum,
        'email': _user!.email,
      });
      prefs.setString('userData', userData);
      notifyListeners();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _user = User(
        id: userData['id'].toString(),
        email: userData['email'].toString(),
        firstName: userData['firstName'].toString(),
        lastName: userData['lastName'].toString(),
        phoneNum: userData['phoneNum'].toString());

    notifyListeners();

    return true;
  }

  Future<void> signup(String firstName, String lastName, String phoneNo,
      String email, String password) async {
    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNo': phoneNo,
      'email': email,
      'password': password,
    };
    try {
      final response = await http.post(
        Uri.parse(EnviromentVariables.baseUrl + 'signup'),
        body: json.encode(userData),
      );
      final responseBody = (json.decode(response.body) as Map<String, dynamic>);
      if (responseBody['Success'] == null) {
        String error = responseBody['Failure'];
        throw HttpException(error);
      } else {
        await fetchUserInfo(email);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(String firstName, String lastName, String phoneNo,
      String email, String password) async {
    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNo': phoneNo,
      'email': email,
      'password': password
    };

    try {
      final response = await http.post(
          Uri.parse(EnviromentVariables.baseUrl + 'updateUser'),
          body: jsonEncode(userData));

      final responseBody = (json.decode(response.body) as Map<String, dynamic>);

      if (responseBody['Success'] == null) {
        String error = responseBody['Failure'];
        throw HttpException(error);
      }
      _user!.firstName = firstName;
      _user!.lastName = lastName;
      _user!.phoneNum = phoneNo;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgetPassword(String email, BuildContext context) async {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 20),
      content: Text(translation(context).checkEmail),
      action: SnackBarAction(
          label: translation(context).okay,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => AuthPage(false)),
                (route) => false);
          }),
    );
    final requestData = {"email": email};
    try {
      final response = await http.post(
        Uri.parse(EnviromentVariables.baseUrl + "user"),
        body: json.encode(requestData),
      );
      final responseList = json.decode(response.body) as List<dynamic>;
      if (responseList.isNotEmpty) {
        final responseForget = await http.post(
          Uri.parse(EnviromentVariables.baseUrl + "forget"),
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        notifyListeners();
      } else {
        Fluttertoast.showToast(
            msg: translation(context).emailDoesntExist,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Theme.of(context).colorScheme.secondary);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => AuthPage(false)),
            (route) => false);
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final emailData = {'email': _user!.email};
    try {
      final response = await http.post(
          Uri.parse(EnviromentVariables.baseUrl + "delete"),
          body: jsonEncode(emailData));
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    _user = null;
    prefs.clear();
    notifyListeners();
  }

  bool isAuth() {
    return _user == null ? false : true;
  }
}
