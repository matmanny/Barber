import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  static const String route = '/editProfilePage';
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User? user;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool showPassword = false;
  final Map<String, dynamic> _userData = {
    'firstName': '',
    'lastName': '',
    'phoneNo': '',
    'password': '',
    'email': ''
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false).updateProfile(
          _userData['firstName'],
          _userData['lastName'],
          _userData['phoneNo'],
          user!.email,
          _userData['password']);
      setState(() {
        _isLoading = false;
      });
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          translation(context).errorOccured,
          // 'An Error Occurred!',
          style: TextStyle(color: Colors.red),
        ),
        content: Flexible(child: Text(message)),
        actions: <Widget>[
          TextButton(
            child: Text(
              translation(context).okay,
              //'Okay',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translation(context).successful),
        content: Text(translation(context).profileUpdated),
        actions: <Widget>[
          TextButton(
            child: Text(
              translation(context).okay,
              // 'Okay',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            onPressed: () {
              Navigator.of(ctx).popUntil(ModalRoute.withName('home'));
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          translation(context).editProfile,
          //"Edit Profile",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _isLoading
              ? CircularProgressIndicator(
                  strokeWidth: 3.0,
                  color: Theme.of(context).colorScheme.secondary,
                )
              : IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 30,
                  ),
                  onPressed: _submit,
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ListView(
              children: [
                buildTextField(translation(context).firstName, user!.firstName,
                    "First Name"),
                buildTextField(
                    translation(context).lastName, user!.lastName, "Last Name"),
                buildPhoneTextField(
                    translation(context).phoneNo, user!.phoneNum),
                buildPasswordTextField(
                    translation(context).newPassword, '********', false, true),
                buildPasswordTextField(translation(context).confirmPassword,
                    '********', true, false),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        enabled: value == "Email" ? false : true,
        style: TextStyle(
            fontSize: 20,
            decorationColor: Colors.black,
            color: Theme.of(context).colorScheme.secondary),
        onSaved: (newValue) {
          if (value == "First Name") {
            _userData['firstName'] = newValue;
          } else if (value == "Last Name") {
            _userData['lastName'] = newValue;
          } else if (value == "Email") {
            _userData['email'] = newValue;
          }
        },
        validator: (value) {
          if (value != "Email") {
            return nameValidator(value);
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.secondary,
          ),
          labelStyle: const TextStyle(fontSize: 20, color: Colors.black),
          counterStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget buildPasswordTextField(String labelText, String placeholder,
      bool isConfirmPassword, bool isNewPassword) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        style: TextStyle(
            fontSize: 20,
            decorationColor: Colors.black,
            color: Theme.of(context).colorScheme.secondary),
        onSaved: (newValue) {
          if (isNewPassword) {
            _userData['newPassword'] = newValue;
          } else if (!isConfirmPassword) {
            _userData['password'] = newValue;
          }
        },
        controller: isNewPassword ? _passwordController : null,
        validator: (value) {
          if (!isConfirmPassword) {
            return passwordValidator(value);
          } else {
            return confirmPasswordValidator(value);
          }
        },
        obscureText: !showPassword,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.grey,
              ),
            ),
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            labelStyle: const TextStyle(fontSize: 20, color: Colors.black54),
            counterStyle: const TextStyle(color: Colors.black54),
            hintStyle: TextStyle(
              fontSize: 20,
              decorationColor: Colors.black,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.secondary,
            )),
      ),
    );
  }

  Widget buildPhoneTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        style: TextStyle(
            fontSize: 20,
            decorationColor: Colors.red,
            color: Theme.of(context).colorScheme.secondary),
        keyboardType: TextInputType.phone,
        onSaved: (newValue) {
          _userData['phoneNo'] = newValue;
        },
        validator: (value) {
          if (value == null ||
              value.length < 10 ||
              value.isEmpty ||
              value.substring(0, 2).compareTo('41') != 0) {
            return translation(context).checkPhoneNumber;
          }
          return null;
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: const TextStyle(fontSize: 20, color: Colors.black),
            counterStyle: const TextStyle(color: Colors.black),
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.secondary,
            )),
      ),
    );
  }

  String? nameValidator(String? value) {
    if (value == null || value.length < 3) {
      return translation(context).valDigits;
      // 'Value must be at least 3 digits';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.length < 8 || value.isEmpty) {
      return translation(context).passwordShort;
      // 'Password is too short!';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value != _passwordController.text) {
      return translation(context).passwordMustMatch;
      // 'Password must match!';
    }
    return null;
  }
}
