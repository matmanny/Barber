import 'package:abc_barbershop/providers/appointment_provider.dart';
import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:abc_barbershop/models/appointments.dart';
import 'package:abc_barbershop/providers/services_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../providers/barber_provider.dart';
import '../size_config.dart';

class AppointmentDetailsPage extends StatefulWidget {
  String appointmentId;
  final bool _isBooking;
  final bool _iscancel;
  AppointmentDetailsPage(this.appointmentId, this._isBooking, this._iscancel,
      {Key? key})
      : super(key: key);

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    appointment = Provider.of<AppointmentProvider>(context, listen: false)
        .activeAppointments
        .firstWhereOrNull((element) => element.id == widget.appointmentId);
    appointment ??= Provider.of<AppointmentProvider>(context, listen: false)
        .historyAppointments
        .firstWhereOrNull((element) => element.id == widget.appointmentId);
    return WillPopScope(
      onWillPop: () async {
        if (widget._isBooking) {
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed('home');
          return Future.value(false);
        } else {
          await Provider.of<ServicesProvider>(context, listen: false)
              .fetchServices();
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchBarbers();
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchDaysoff();
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchWorkingTime();
          await Provider.of<AppointmentProvider>(context, listen: false)
              .fetchAllActiveAppointments();
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text(
            translation(context).appointmentDetails,
            // "Appointment Details",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            onPressed: () async {
              if (widget._isBooking) {
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed('home');
              } else {
                Navigator.pop(context);
                await Provider.of<ServicesProvider>(context, listen: false)
                    .fetchServices();
                await Provider.of<BarberProvider>(context, listen: false)
                    .fetchBarbers();
                await Provider.of<BarberProvider>(context, listen: false)
                    .fetchDaysoff();
                await Provider.of<BarberProvider>(context, listen: false)
                    .fetchWorkingTime();
                await Provider.of<AppointmentProvider>(context, listen: false)
                    .fetchAllActiveAppointments();
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              widget._iscancel
                  ? Container()
                  : Text(
                      translation(context).thanks,
                      //"Thank you for booking!",
                      style:
                          TextStyle(fontSize: getProportionateScreenHeight(20)),
                    ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              _barberProfilePic(context),
              _buildDetails()
            ],
          ),
        ),
        bottomSheet: widget._iscancel
            ? _buildCancelBtn(context)
            : Container(
                child: Text(""),
              ),
      ),
    );
  }

  Widget _barberProfilePic(BuildContext context) {
    final barberProvider = Provider.of<BarberProvider>(context, listen: false);
    final barbers = barberProvider.barbers;
    final barber = barbers.firstWhereOrNull(
      (element) => element.id == appointment!.barberId,
    );
    return Container(
      // padding: EdgeInsets.only(top: 30.0),
      width: MediaQuery.of(context).size.width,
      height: getProportionateScreenHeight(200),
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
                    fit: BoxFit.cover),
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
            width: getProportionateScreenWidth(145),
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
        .firstWhereOrNull((element) => element.id == appointment!.serviceId);
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
                //"Service Chosen",
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: getProportionateScreenHeight(5),
              ),
              Text(
                service!.name,
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
    return Column(
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
                  DateFormat.yMMMMd().format(appointment!.bookingStart),
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
                  '${DateFormat.Hm().format(appointment!.bookingStart)} - ${DateFormat.Hm().format(appointment!.bookingEnd)}',
                  style: TextStyle(
                      fontSize: getProportionateScreenHeight(13),
                      fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCancelBtn(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(translation(context).appointmentCancelled),
      action: SnackBarAction(
        label: translation(context).okay,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context2) => AlertDialog(
            content: Text(translation(context).cancelAlert),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context2),
                child: Text(
                  translation(context).no,
                  style: TextStyle(
                    color: Theme.of(context2).colorScheme.secondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<AppointmentProvider>(context, listen: false)
                      .cancelAppointment(appointment!.id, context);
                  Navigator.pop(context2);
                },
                child: Text(
                  translation(context).yes,
                  style: TextStyle(
                    color: Theme.of(context2).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        child: Text(
          translation(context).cancel,
          // "Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
              (states) => Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
