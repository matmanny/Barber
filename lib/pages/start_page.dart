import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/barbers_page.dart';
import '../providers/services_provider.dart';
import '../providers/user_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/barber_provider.dart';
import '../size_config.dart';
import 'package:blur/blur.dart';

class StartPage extends StatefulWidget {
  StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    Future refreshAppointments() async {
      await Provider.of<ServicesProvider>(context, listen: false)
          .fetchServices();
      await Provider.of<BarberProvider>(context, listen: false).fetchBarbers();
      await Provider.of<BarberProvider>(context, listen: false).fetchDaysoff();
      await Provider.of<BarberProvider>(context, listen: false)
          .fetchWorkingTime();

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

    return RefreshIndicator(
      onRefresh: refreshAppointments,
      color: Theme.of(context).colorScheme.secondary,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          centerTitle: true,
          title: Text(
            translation(context).home,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w400),
          ),
          elevation: 0.0,
        ),
        body: Stack(
          children: [
            _buildBackgroundImage(),
            _categoriesBuilder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Blur(
      blur: 1.5,
      blurColor: Color.fromARGB(255, 138, 133, 133),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoriesBuilder(BuildContext context) {
    final servicesProvider =
        Provider.of<ServicesProvider>(context, listen: false);
    final services = servicesProvider.services;

    return ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) => Container(
              child: Container(
                width: SizeConfig.screenWidth * 0.2,
                height: SizeConfig.screenHeight * 0.26,
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.12,
                    vertical: SizeConfig.screenWidth * 0.04),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarberPage(services[index].id),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(color: Colors.white)),
                    elevation: 8.0,
                    color: Colors.white.withOpacity(1),
                    child: Column(children: [
                      Image.network(
                        services[index].pictureUrl,
                        height: SizeConfig.screenHeight * 0.2,
                        width: SizeConfig.screenWidth * 0.35,
                      ),
                      Text(
                        services[index].name,
                        style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.052,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                ),
              ),
            ));
  }
}
