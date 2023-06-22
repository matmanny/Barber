import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../widgets/fonts/palatte.dart';
import '../providers/appointment_provider.dart';
import '../size_config.dart';

enum AuthMode { logIn, signUp, forget }

class AuthPage extends StatefulWidget {
  bool _redirected;
  AuthPage(this._redirected, {Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'firstName': null,
    'lastName': null,
    'phoneNum': null,
    'email': null,
    'password': null,
  };

  bool _isLoading = false;
  AuthMode _authMode = AuthMode.logIn;
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // @override
  // void setState(VoidCallback cb) {
  //   if (mounted) {
  //     super.setState(cb);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Object? queryParams = ModalRoute.of(context)!.settings.arguments;
    if (queryParams != null) {
      widget._redirected = true;
    }
    return Stack(
      children: [
        _buildBackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackBtn(),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: getProportionateScreenWidth(300),
                        height: getProportionateScreenHeight(300),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/Capture-removebg-preview.png')),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(40)),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _authMode == AuthMode.signUp
                                    ? _buildFirstNameTextField()
                                    : Container(),
                                _authMode == AuthMode.signUp
                                    ? _buildLastNameTextField()
                                    : Container(),
                                _authMode == AuthMode.signUp
                                    ? _buildPhoneNoTextField()
                                    : Container(),
                                _buildEmailTextField(),
                                _authMode != AuthMode.forget
                                    ? _buildPasswordTextField()
                                    : Container(),
                                _authMode == AuthMode.signUp
                                    ? _buildConfirmPasswordTextField()
                                    : Container(),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: _authMode == AuthMode.signUp
                                      ? getProportionateScreenHeight(15)
                                      : getProportionateScreenHeight(30),
                                ),
                                _authBtn(),
                                SizedBox(
                                  height: _authMode == AuthMode.signUp
                                      ? getProportionateScreenHeight(20)
                                      : getProportionateScreenHeight(30),
                                ),
                                _authMode != AuthMode.forget
                                    ? Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_authMode ==
                                                    AuthMode.logIn) {
                                                  _authMode = AuthMode.signUp;
                                                } else {
                                                  _authMode = AuthMode.logIn;
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.white,
                                                    width: 1),
                                              )),
                                              child: Text(
                                                _authMode == AuthMode.logIn
                                                    ? translation(context)
                                                        .creatAccount
                                                    : translation(context)
                                                        .haveAccount,
                                                style: kBodyText3,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          _authMode == AuthMode.logIn
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _authMode =
                                                          AuthMode.forget;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.white,
                                                          width: 1),
                                                    )),
                                                    child: Text(
                                                      translation(context)
                                                          .forgetPassword,
                                                      style: kBodyText3,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Container(),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.black, Colors.black26],
        begin: Alignment.bottomCenter,
        end: Alignment.center,
      ).createShader(bounds),
      blendMode: BlendMode.darken,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hair_clipper_scissor.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: translation(context).password,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                FontAwesomeIcons.lock,
                color: Colors.white,
                size: getProportionateScreenHeight(30),
              ),
            ),
            hintStyle: kBodyText,
          ),
          obscureText: true,
          style: kBodyText,
          textInputAction: TextInputAction.done,
          validator: (String? value) {
            if (value!.isEmpty || value.length < 6) {
              return translation(context).invalidPassword;
            }
            return null;
          },
          onSaved: (String? value) {
            _formData["password"] = value;
          },
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: translation(context).confirmPassword,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                FontAwesomeIcons.lock,
                color: Colors.white,
                size: 30,
              ),
            ),
            hintStyle: kBodyText,
          ),
          obscureText: true,
          style: kBodyText,
          textInputAction: TextInputAction.done,
          validator: (String? value) {
            if (_passwordController.text != value) {
              return translation(context).passwordDoesnotMatch;
              // 'Password does not match!';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: translation(context).email,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                FontAwesomeIcons.solidEnvelope,
                color: Colors.white,
                size: 30,
              ),
            ),
            hintStyle: kBodyText,
          ),
          style: kBodyText,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null ||
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value) ||
                value.isEmpty) {
              return translation(context).invalidEmail;
            }
            return null;
          },
          onSaved: (value) {
            _formData['email'] = value!;
          },
        ),
      ),
    );
  }

  Widget _buildFirstNameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: translation(context).firstName,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                FontAwesomeIcons.user,
                color: Colors.white,
                size: 30,
              ),
            ),
            hintStyle: kBodyText,
          ),
          style: kBodyText,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value!.isEmpty || value.length < 3) {
              return translation(context).invalidName;
            }
            return null;
          },
          onSaved: (String? value) {
            _formData["firstName"] = value;
          },
        ),
      ),
    );
  }

  Widget _buildLastNameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: translation(context).lastName,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                FontAwesomeIcons.user,
                color: Colors.white,
                size: 30,
              ),
            ),
            hintStyle: kBodyText,
          ),
          style: kBodyText,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value!.isEmpty || value.length < 3) {
              return translation(context).invalidName;
            }
            return null;
          },
          onSaved: (String? value) {
            _formData["lastName"] = value;
          },
        ),
      ),
    );
  }

  Widget _buildPhoneNoTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: translation(context).phoneNo,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                FontAwesomeIcons.phone,
                color: Colors.white,
                size: 30,
              ),
            ),
            hintStyle: kBodyText,
          ),
          style: kBodyText,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value == null || value.length <= 9 || value.isEmpty) {
              return translation(context).invalidPhoneNo;
            }
            return null;
          },
          onSaved: (String? value) {
            _formData['phoneNum'] = value!;
          },
        ),
      ),
    );
  }

  Widget _authBtn() {
    return _isLoading
        ? CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          )
        : Container(
            width: getProportionateScreenWidth(230),
            height: getProportionateScreenHeight(50),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: () {
                if (_authMode == AuthMode.forget) {
                  _forget();
                } else if (_authMode == AuthMode.logIn) {
                  _login();
                } else {
                  _signup();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: getProportionateScreenHeight(2)),
                child: Text(
                  _authMode == AuthMode.forget
                      ? translation(context).reset
                      : _authMode == AuthMode.logIn
                          ? translation(context).login
                          : translation(context).signup,
                  style: TextStyle(fontSize: getProportionateScreenHeight(20)),
                ),
              ),
            ),
          );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .login(_formData['email'], _formData['password']);
      Future.wait({
        Provider.of<AppointmentProvider>(context, listen: false)
            .fetchActiveAppointments(
                Provider.of<UserProvider>(context, listen: false).user.id),
        Provider.of<AppointmentProvider>(context, listen: false)
            .fetchHistoryAppointments(
                Provider.of<UserProvider>(context, listen: false).user.id),
      });
      if (widget._redirected) {
        Navigator.pop(context);
      } else {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed('home');
      }
    } on HttpException catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error.toString());
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(translation(context).swr);
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).signup(
          _formData["firstName"],
          _formData["lastName"],
          _formData["phoneNum"],
          _formData["email"],
          _formData["password"]);
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchActiveAppointments(
              Provider.of<UserProvider>(context, listen: false).user.id);
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchHistoryAppointments(
              Provider.of<UserProvider>(context, listen: false).user.id);
      if (widget._redirected) {
        Navigator.pop(context);
      } else {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed('home');
      }
    } on HttpException catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error.toString());
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(translation(context).swr);
    }
  }

  Future<void> _forget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .forgetPassword(_formData["email"], context);
    } on HttpException catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error.toString());
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(translation(context).swr);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translation(context).errorOccured),
        content: Flexible(child: Text(message)),
        actions: <Widget>[
          TextButton(
            child: Text(
              translation(context).okay,
              // 'Okay',
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

  Widget _buildBackBtn() {
    return widget._redirected
        ? IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ))
        : Container();
  }
}
