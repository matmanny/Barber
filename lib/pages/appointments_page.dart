import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:abc_barbershop/pages/appointment_details_page.dart';
import 'package:abc_barbershop/providers/appointment_provider.dart';
import 'package:abc_barbershop/providers/services_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/barber_provider.dart';
import '../providers/user_provider.dart';
import '../size_config.dart';

class AppointmentsPage extends StatefulWidget {
  String appointmentType;
  AppointmentsPage(this.appointmentType, {Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "${widget.appointmentType} Appointments",
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: getProportionateScreenHeight(30),
            ),
            Container(
                height: SizeConfig.screenHeight * 0.78,
                child: _buildAppointments(context)),
          ],
        ),
      ),
    );
  }

  Future refreshAppointments() async {
    bool isAuth = Provider.of<UserProvider>(context, listen: false).isAuth();
    if (isAuth) {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchActiveAppointments(
              Provider.of<UserProvider>(context, listen: false).user.id);
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchHistoryAppointments(
              Provider.of<UserProvider>(context, listen: false).user.id);
    }
  }

  Widget _buildAppointments(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context, listen: true);
    final appointments = widget.appointmentType == "Active"
        ? provider.activeAppointments
        : provider.historyAppointments;
    final services =
        Provider.of<ServicesProvider>(context, listen: true).services;
    return appointments.isNotEmpty
        ? RefreshIndicator(
            color: Theme.of(context).colorScheme.secondary,
            onRefresh: refreshAppointments,
            child: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, i) => Container(
                width: getProportionateScreenWidth(460),
                height: getProportionateScreenHeight(520),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentDetailsPage(
                              appointments[i].id, false, true),
                        ));
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: constraints.maxHeight * 0.9,
                            child: Card(
                              margin: EdgeInsets.all(
                                  getProportionateScreenWidth(20)),
                              elevation: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: getProportionateScreenHeight(60),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.account_circle_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    title: Text(Provider.of<BarberProvider>(
                                                context,
                                                listen: false)
                                            .barbers
                                            .firstWhere((element) =>
                                                element.id ==
                                                appointments[i].barberId)
                                            .firstName +
                                        ' ' +
                                        Provider.of<BarberProvider>(context,
                                                listen: false)
                                            .barbers
                                            .firstWhere((element) =>
                                                element.id ==
                                                appointments[i].barberId)
                                            .lastName),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    title: const Text(
                                        "Rue de la servette 01,\n 1201 Geneve"),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.design_services,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    title: Text(services
                                        .firstWhere((element) =>
                                            element.id ==
                                            appointments[i].serviceId)
                                        .name),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.calendar_month,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    title: Text(
                                        ' ${DateFormat.yMMMMd().format(appointments[i].bookingStart)}'),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.watch_later,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    title: Text(
                                        '${DateFormat.Hms().format(appointments[i].bookingStart)} - ${DateFormat.Hms().format(appointments[i].bookingEnd)}'),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ClipOval(
                              child: Container(
                                width: getProportionateScreenWidth(130),
                                height: getProportionateScreenHeight(125),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.25),
                                          BlendMode.multiply),
                                      image: NetworkImage(Provider.of<BarberProvider>(context, listen: false)
                                                  .barbers
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      appointments[i].barberId)
                                                  .pictureUrl
                                                  .isEmpty ||
                                              Provider.of<BarberProvider>(context, listen: false)
                                                  .barbers
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      appointments[i].barberId)
                                                  .pictureUrl
                                                  .isEmpty
                                          ? "https://media.istockphoto.com/photos/male-barber-cutting-sideburns-of-client-in-barber-shop-picture-id1301256896?b=1&k=20&m=1301256896&s=170667a&w=0&h=LHqIUomhTGZjpUY12vWg9Ki0lUGz2F0FfXSicsmSpR8="
                                          : Provider.of<BarberProvider>(context, listen: false)
                                              .barbers
                                              .firstWhere((element) => element.id == appointments[i].barberId)
                                              .pictureUrl),
                                      fit: BoxFit.fill),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Center(
            child: Text(
            translation(context).noAppointments,
            // "No Appointments!",
            style: TextStyle(
                fontSize: 20, color: Theme.of(context).colorScheme.secondary),
          ));
  }
}
