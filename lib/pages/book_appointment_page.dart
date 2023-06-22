import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:abc_barbershop/pages/confirmation_page.dart';
import 'package:abc_barbershop/providers/appointment_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/barber_provider.dart';
import '../providers/services_provider.dart';
import '../size_config.dart';

class BookAppointmentPage extends StatefulWidget {
  String barberId;
  String serviceId;
  String restorationId;
  RestorableDateTime selDate;

  BookAppointmentPage(
      this.serviceId, this.barberId, this.selDate, this.restorationId,
      {Key? key})
      : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage>
    with RestorationMixin {
  Map<String, dynamic> _workingTime = {};

  static String _barberId = "-1";

  String _selectedTime = "";
  String _selectedTime2 = "";

  int _selectedTimeIndex = -1;

  final _isBookBtnLoading = false;

  bool _isWorkingDay = true;

  bool _isDayAdded = false;

  bool _isFirstTime = true;

  List<String> activeAppointments = [];
  var activeApp;

  @override
  Widget build(BuildContext context) {
    Future refreshAppointments() async {
      Provider.of<BarberProvider>(context, listen: false);
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchAllActiveAppointments();
      activeApp = Provider.of<AppointmentProvider>(context, listen: false)
          .allActiveAppointments;
    }

    _barberId = widget.barberId;

    if (_isFirstTime) {
      final barberprovider =
          Provider.of<BarberProvider>(context, listen: false);
      final workingday = barberprovider.findWorkingDays(_barberId);

      List<int> workingweekdays = [];
      for (var element in workingday) {
        workingweekdays.add(int.parse(element['weekDay'] as String));
      }

      if (!workingweekdays.contains(widget.selDate.value.weekday)) {
        _isWorkingDay = false;
      }

      final barberProvider = Provider.of<BarberProvider>(context);

      final activeAppointmentsOriginal =
          Provider.of<AppointmentProvider>(context).allActiveAppointments;
      activeApp = activeAppointmentsOriginal;
      for (var appointment in activeAppointmentsOriginal) {
        if (appointment.bookingStart.month == widget.selDate.value.month &&
            appointment.bookingStart.day == widget.selDate.value.day &&
            widget.barberId == appointment.barberId) {
          activeAppointments
              .add(appointment.bookingStart.toString().substring(11, 16));
          if (appointment.bookingStart.toString().substring(14, 16) == "00" &&
              appointment.bookingEnd.toString().substring(14, 16) == "00") {
            activeAppointments.add(appointment.bookingStart
                .toString()
                .replaceRange(14, 16, "30")
                .substring(11, 16));
          }
          if (appointment.bookingStart.toString().substring(14, 16) == "30" &&
              appointment.bookingEnd.toString().substring(14, 16) == "30") {
            activeAppointments.add(appointment.bookingEnd
                .toString()
                .replaceRange(14, 16, "00")
                .substring(11, 16));
          }
        }
      }

      for (var element in barberProvider.barbers
          .firstWhere((element) => element.id == _barberId)
          .daysoff) {
        if (widget.selDate.value == element) {
          _isWorkingDay = false;
        }
      }
      final times = barberProvider.findWorkingTime(
          widget.barberId, widget.selDate.value.weekday.toString());
      if (_isDayAdded || widget.selDate.value.day != DateTime.now().day) {
        for (var element in times) {
          String startTimeString =
              element["startTime"].toString().substring(0, 5);
          String endTimeString = element["endTime"].toString().substring(0, 5);
          while (startTimeString != endTimeString) {
            if (_selectedTime == startTimeString ||
                _selectedTime2 == startTimeString ||
                activeAppointments.contains(startTimeString)) {
              _workingTime.addAll({startTimeString: true});
            } else {
              _workingTime.addAll({startTimeString: !_isWorkingDay});
            }

            if (startTimeString[3] == "0") {
              startTimeString = startTimeString.replaceRange(3, 4, "3");
            } else {
              int f = int.parse(startTimeString.substring(0, 2));
              f = f + 1;
              startTimeString = startTimeString.replaceRange(3, 4, "0");
              if (f < 10) {
                startTimeString = startTimeString.replaceRange(0, 2, "0$f");
              } else {
                startTimeString = startTimeString.replaceRange(0, 2, "$f");
              }
            }
          }
        }
      } else {
        for (var element in times) {
          String startTimeString =
              element["startTime"].toString().substring(0, 5);
          String endTimeString = element["endTime"].toString().substring(0, 5);
          while (startTimeString != endTimeString) {
            if (_selectedTime == startTimeString ||
                _selectedTime2 == startTimeString ||
                activeAppointments.contains(startTimeString)) {
              _workingTime.addAll({startTimeString: true});
            } else {
              DateTime startTime = DateTime.now();
              if (startTime.hour > int.parse(startTimeString.substring(0, 2))) {
                _workingTime.addAll({startTimeString: true});
              } else {
                _workingTime.addAll({startTimeString: !_isWorkingDay});
              }
            }
            if (startTimeString[3] == "0") {
              startTimeString = startTimeString.replaceRange(3, 4, "3");
            } else {
              int f = int.parse(startTimeString.substring(0, 2));
              f = f + 1;
              startTimeString = startTimeString.replaceRange(3, 4, "0");
              if (f < 10) {
                startTimeString = startTimeString.replaceRange(0, 2, "0$f");
              } else {
                startTimeString = startTimeString.replaceRange(0, 2, "$f");
              }
            }
          }
        }
      }
    }

    _isFirstTime = true;

    return RefreshIndicator(
      onRefresh: refreshAppointments,
      child: WillPopScope(
        onWillPop: () async {
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchBarbers();
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchWorkingHours();
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchDaysoff();
          await Provider.of<BarberProvider>(context, listen: false)
              .fetchWorkingTime();
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              translation(context).bookingP,
              //"Booking Page",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () async {
                await Provider.of<BarberProvider>(context, listen: false)
                    .fetchBarbers();

                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 40.0,
                ),
                _barberProfilePic(context),
                //selctedDateinitial(context),
                _buildCalendar(context),
                const SizedBox(height: 50.0),
                _buildTimeFrame(context),
                const SizedBox(height: 100.0),
              ],
            ),
          ),
          bottomSheet: _buildBookBtn(context),
        ),
      ),
    );
  }

  Widget _barberProfilePic(BuildContext context) {
    final barberProvider = Provider.of<BarberProvider>(context, listen: false);
    final barbers = barberProvider.barbers;
    final barber = barbers.firstWhere(
      (element) => element.id == widget.barberId,
    );
    return Container(
      // padding: EdgeInsets.only(top: 30.0),
      width: MediaQuery.of(context).size.width,
      height: 155.0,
      child: Column(children: <Widget>[
        Container(
          width: 120.0,
          height: 115.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.25), BlendMode.multiply),
                  image: NetworkImage(barber.pictureUrl.isEmpty
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
        const SizedBox(
          height: 15.0,
        ),
        Flexible(
          child: Container(
            // padding: EdgeInsets.only( top: 20.0 ),
            width: 140.0,
            height: 50.0,
            child: Column(
              children: <Widget>[
                Text(
                  barber.firstName,
                  style: const TextStyle(
                      fontSize: 21.0, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('EEE, MMM d, yyyy').format(widget.selDate.value),
                style: const TextStyle(
                  fontSize: 20,
                )),
            const SizedBox(
              width: 5.0,
            ),
            IconButton(
              iconSize: 30,
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                _restorableDatePickerRouteFuture.present();
              },
              icon: const Icon(Icons.calendar_month),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBookBtn(BuildContext context) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 5),
      content: Text(translation(context).alreadyBooked
          // 'ALREADY BOOKED'
          ),
      action: SnackBarAction(
        label: translation(context).okay,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    bool isalready = false;
    final workingTime = _workingTime.keys.toList();
    return _isBookBtnLoading
        ? const CircularProgressIndicator()
        : Container(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                if (_selectedTimeIndex >= 0 && _isWorkingDay) {
                  final bookingStart = DateTime(
                    widget.selDate.value.year,
                    widget.selDate.value.month,
                    widget.selDate.value.day,
                    int.parse(_selectedTime.substring(0, 2)),
                    int.parse(_selectedTime.substring(3)),
                  );

                  DateTime bookingEnd =
                      bookingStart.add(const Duration(minutes: 30));
                  final service = Provider.of<ServicesProvider>(context,
                          listen: false)
                      .services
                      .firstWhere((element) => element.id == widget.serviceId);
                  //   Coupe Cheveux et Barbe
                  if (service.durationSeconds == 3600) {
                    bookingEnd = bookingStart.add(const Duration(minutes: 60));
                  }

                  for (var appointment in activeApp) {
                    if (appointment.barberId == widget.barberId &&
                        appointment.bookingStart == bookingStart) {
                      isalready = true;
                    }
                    if (appointment.barberId == widget.barberId &&
                        bookingStart.add(const Duration(minutes: 30)) ==
                            appointment.bookingStart &&
                        bookingEnd ==
                            appointment.bookingStart
                                .add(const Duration(minutes: 30))) {
                      isalready = true;
                    }

                    if (appointment.barberId == widget.barberId &&
                        appointment.bookingStart
                                .add(const Duration(minutes: 60)) ==
                            appointment.bookingEnd) {
                      if (bookingStart ==
                          appointment.bookingStart
                              .add(const Duration(minutes: 30))) {
                        isalready = true;
                      }
                    }
                  }

                  if (bookingStart.isBefore(DateTime.now())) {
                    isalready = true;
                  }

                  if (isalready == true) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    setState(() {
                      _workingTime[workingTime[_selectedTimeIndex]] = false;
                      _selectedTime = "";
                      _selectedTime2 = "";
                      _selectedTimeIndex = -1;
                    });

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmationPage(
                              barberId: widget.barberId,
                              serviceId: widget.serviceId,
                              bookingStart: bookingStart,
                              bookingEnd: bookingEnd),
                        ));
                  }
                }
              },
              child: Text(
                translation(context).cont,
                // "Continue",
                style: TextStyle(
                    color: _isWorkingDay
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontSize: 20),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) =>
                    _isWorkingDay
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.6)),
              ),
            ),
          );
  }

  Widget _buildTimeFrame(BuildContext context) {
    final workingTime = _workingTime.keys.toList();
    return Container(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(170)),
      height: getProportionateScreenHeight(400),
      child: GridView.builder(
        itemCount: workingTime.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () {
            if (_selectedTimeIndex != i) {
              setState(() {
                if (_selectedTimeIndex >= 0) {
                  _workingTime[workingTime[_selectedTimeIndex]] = false;
                }
                _workingTime[workingTime[i]] = true;
                _selectedTimeIndex = i;
                _selectedTime = workingTime[i];

                final service = Provider.of<ServicesProvider>(context,
                        listen: false)
                    .services
                    .firstWhere((element) => element.id == widget.serviceId);
                if (service.durationSeconds == 3600) {
                  if (_selectedTimeIndex >= 0) {
                    _workingTime[workingTime[_selectedTimeIndex + 1]] = false;
                  }
                  _workingTime[workingTime[i]] = true;
                  _selectedTimeIndex = i;
                  _selectedTime2 = workingTime[i + 1];
                }
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(5.0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _workingTime[workingTime[i]] ? Colors.grey : Colors.black87,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Center(
              child: Text(
                workingTime[i],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  String? get restorationId => widget.restorationId;

  // RestorableDateTime _selectedDate = widget.selDate;

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: widget.selDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    DateTime initialDate = DateTime.now();
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Colors.black,
              onSurface: Colors.blueAccent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Theme.of(context)
                    .colorScheme
                    .secondary, // button text color
              ),
            ),
          ),
          child: DatePickerDialog(
              restorationId: 'date_picker_dialog',
              initialEntryMode: DatePickerEntryMode.calendarOnly,
              initialDate:
                  DateTime.fromMillisecondsSinceEpoch(arguments! as int),
              firstDate: initialDate,
              lastDate: initialDate.add(const Duration(days: 90)),
              selectableDayPredicate: (DateTime val) {
                final barberProvider =
                    Provider.of<BarberProvider>(context, listen: false);
                final barber = barberProvider.barbers
                    .firstWhere((element) => element.id == _barberId);

                final workingday = barberProvider.findWorkingDays(_barberId);

                List<int> workingweekdays = [];
                for (var element in workingday) {
                  workingweekdays.add(int.parse(element['weekDay'] as String));
                }
                return !workingweekdays.contains(val.weekday) ||
                        barber.daysoff.contains(val)
                    ? false
                    : true;
              }),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(widget.selDate, 'Selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    _isFirstTime = true;
    final workingTime = _workingTime.keys.toList();
    if (newSelectedDate != null) {
      setState(() {
        widget.selDate.value = newSelectedDate;
        activeAppointments = [];
        if (_selectedTimeIndex > 0) {
          for (var key in _workingTime.keys) {
            _workingTime[key] = false;
          }
          _workingTime[workingTime[_selectedTimeIndex]] = false;
          _selectedTime = "";
          _selectedTime2 = "";
          _selectedTimeIndex = -1;
        }
      });
    }
  }

  void _showDialog(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSuccess
            ? translation(context).successful
            : translation(context).error),
        content: Row(children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 35.0,
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
}
