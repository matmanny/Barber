import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:abc_barbershop/pages/appointment_details_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../models/http_exception.dart';
import '../pages/auth_page.dart';
import '../providers/appointment_provider.dart';
import '../providers/barber_provider.dart';
import '../providers/services_provider.dart';
import '../providers/user_provider.dart';
import '../size_config.dart';

class ConfirmationPage extends StatefulWidget {
  String barberId;
  String serviceId;
  DateTime bookingStart;
  DateTime bookingEnd;
  ConfirmationPage(
      {Key? key,
      required this.barberId,
      required this.serviceId,
      required this.bookingStart,
      required this.bookingEnd})
      : super(key: key);

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool _isBookBtnLoading = false;
  bool canBook = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text(
            translation(context).confirmation,
            // "Confirmation",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              Provider.of<BarberProvider>(context, listen: false);
              await Provider.of<AppointmentProvider>(context, listen: false)
                  .fetchAllActiveAppointments();

              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40.0,
              ),
              _barberProfilePic(context),
              _buildDetails()
            ],
          ),
        ),
        bottomSheet: _buildBookBtn(context),
      ),
    );
  }

  Widget _barberProfilePic(BuildContext context) {
    final barberProvider = Provider.of<BarberProvider>(context, listen: false);
    final barbers = barberProvider.barbers;
    final barber = barbers.firstWhereOrNull(
      (element) => element.id == widget.barberId,
    );
    return Container(
      // padding: EdgeInsets.only(top: 30.0),
      width: MediaQuery.of(context).size.width,
      height: getProportionateScreenHeight(180),
      child: Column(children: <Widget>[
        ClipOval(
          child: Container(
            width: getProportionateScreenWidth(130),
            height: getProportionateScreenHeight(125),
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.25), BlendMode.multiply),
                    image: NetworkImage(barber!.pictureUrl.isEmpty
                        ? "https://media.istockphoto.com/photos/male-barber-cutting-sideburns-of-client-in-barber-shop-picture-id1301256896?b=1&k=20&m=1301256896&s=170667a&w=0&h=LHqIUomhTGZjpUY12vWg9Ki0lUGz2F0FfXSicsmSpR8="
                        : barber.pictureUrl),
                    fit: BoxFit.fill),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0.0, 3.0),
                      blurRadius: 10.0)
                ]),
          ),
        ),
        SizedBox(
          height: getProportionateScreenHeight(15),
        ),
        Flexible(
          child: Container(
            // padding: EdgeInsets.only( top: 20.0 ),
            width: getProportionateScreenWidth(150),
            height: getProportionateScreenHeight(80),
            child: Column(
              children: <Widget>[
                Text(
                  barber.firstName,
                  style: TextStyle(
                      fontSize: getProportionateScreenHeight(25),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDetails() {
    final service = Provider.of<ServicesProvider>(context, listen: false)
        .services
        .firstWhere((element) => element.id == widget.serviceId);
    return Container(
      margin: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalTime(),
          SizedBox(
            height: getProportionateScreenHeight(28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translation(context).serviceChosen,
                // "Service Chosen",
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: getProportionateScreenHeight(5),
              ),
              Text(
                service.name,
                style: TextStyle(fontSize: getProportionateScreenHeight(14)),
              )
            ],
          ),
          SizedBox(
            height: getProportionateScreenHeight(28),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translation(context).studentPrice,
                    //"Student Price",
                    style: TextStyle(
                        fontSize: getProportionateScreenHeight(15),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(5),
                  ),
                  Text(
                    "${service.studentPrice} CHF",
                    style:
                        TextStyle(fontSize: getProportionateScreenHeight(14)),
                  )
                ],
              ),
              SizedBox(
                width: getProportionateScreenWidth(100),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translation(context).normalPrice,
                    // "Normal Price",
                    style: TextStyle(
                        fontSize: getProportionateScreenHeight(15),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(5),
                  ),
                  Text(
                    "${service.normalPrice} CHF",
                    style:
                        TextStyle(fontSize: getProportionateScreenHeight(14)),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCalTime() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: getProportionateScreenHeight(35),
                  ),
                  Text(
                    DateFormat.yMMMMd().format(widget.bookingStart),
                    style: TextStyle(
                        fontSize: getProportionateScreenHeight(13),
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
              SizedBox(
                width: getProportionateScreenWidth(100),
              ),
              Column(
                children: [
                  Icon(
                    Icons.watch_later,
                    size: getProportionateScreenHeight(35),
                  ),
                  Text(
                    '${DateFormat.Hms().format(widget.bookingStart).substring(0, 5)} - ${DateFormat.Hms().format(widget.bookingEnd).substring(0, 5)}',
                    style: TextStyle(
                        fontSize: getProportionateScreenHeight(13),
                        fontWeight: FontWeight.w500),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookBtn(BuildContext context) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 1000000),
      content: Text(translation(context).alreadyBooked
          // 'ALREADY BOOKED'
          ),
      action: SnackBarAction(
        label: translation(context).okay,
        onPressed: () {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
    var userProvider = Provider.of<UserProvider>(context);

    var activeAppointmentsOriginal;
    return _isBookBtnLoading
        ? Container(
            height: 55,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          )
        : Container(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                if (!userProvider.isAuth()) {
                  _showRedirectDialog();
                } else {
                  try {
                    setState(() {
                      _isBookBtnLoading = true;
                    });

                    await Provider.of<AppointmentProvider>(context,
                            listen: false)
                        .fetchAllActiveAppointments();

                    activeAppointmentsOriginal =
                        Provider.of<AppointmentProvider>(context, listen: false)
                            .allActiveAppointments;
                    for (var appointment in activeAppointmentsOriginal) {
                      if (appointment.barberId == widget.barberId &&
                          appointment.bookingStart == widget.bookingStart) {
                        canBook = false;
                      }

                      if (widget.bookingStart.isBefore(DateTime.now())) {
                        canBook = false;
                      }
                    }

                    if (canBook) {
                      await Provider.of<AppointmentProvider>(context,
                              listen: false)
                          .bookAppointment(
                        userId:
                            Provider.of<UserProvider>(context, listen: false)
                                .user
                                .id,
                        barberId: widget.barberId,
                        serviceId: widget.serviceId,
                        servicePrice: Provider.of<ServicesProvider>(context,
                                listen: false)
                            .services
                            .firstWhere(
                                (element) => element.id == widget.serviceId)
                            .normalPrice,
                        bookingStart: widget.bookingStart.toString(),
                        bookingEnd: widget.bookingEnd.toString(),
                      );
                      await Provider.of<AppointmentProvider>(context,
                              listen: false)
                          .fetchActiveAppointments(userProvider.user.id);
                      await Provider.of<AppointmentProvider>(context,
                              listen: false)
                          .fetchAllActiveAppointments();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailsPage(
                                Provider.of<AppointmentProvider>(context,
                                        listen: false)
                                    .allActiveAppointments
                                    .last
                                    .id,
                                true,
                                false),
                          ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  } on HttpException catch (e) {
                    _showDialog(e.toString());
                  } catch (e) {
                    _showDialog(translation(context).oops
                        //"Ooops something went wrong!"
                        );
                  }
                  setState(() {
                    _isBookBtnLoading = false;
                  });
                }
              },
              child: Text(
                translation(context).book,
                // "Book",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => Theme.of(context).colorScheme.secondary),
              ),
            ),
          );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          translation(context).errorOccured,
          //  'An Error Occurred!'
        ),
        content: Row(children: [
          const Icon(
            Icons.error,
            color: Colors.red,
            size: 35,
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ]),
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

  void _showRedirectDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          translation(context).alert,
          //  'Alert',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        content: Text(
          translation(context).regFirst,
          // 'In order to continue you must login or register first!'
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: Text(
              translation(context).cancel,
              //  'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .pushReplacement(MaterialPageRoute(
              builder: (context) => AuthPage(true),
            )),
            child: Text(
              translation(context).okay,
              //  'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
