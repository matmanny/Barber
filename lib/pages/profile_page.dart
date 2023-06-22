import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/appointments_page.dart';
import '../providers/appointment_provider.dart';
import '../providers/user_provider.dart';
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  static String routeName = "/profilePage";
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translation(context).profile,

          //'Profile',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          _buildMenuOptions(
              context,
              translation(context).myAccount,
              // "My Account",
              Icon(
                Icons.person_outline_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed("/editProfilePage");
          }),
          const SizedBox(height: 30),
          _buildMenuOptions(
              context,
              translation(context).activeAppointments,
              //  "Active Appointments",
              Icon(
                Icons.local_activity_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentsPage("Active"),
                ));
          }),
          const SizedBox(height: 30),
          _buildMenuOptions(
              context,
              translation(context).historyAppointments,
              // "History Appointments",
              Icon(
                Icons.history,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentsPage("History"),
                ));
          }),
          const SizedBox(height: 30),
          _buildMenuOptions(
              context,
              translation(context).privacy,
              //"Privacy",
              Icon(
                Icons.privacy_tip_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            _launchInWebViewOrVC(Uri.parse("https://abc-barber.ch/privacy/"));
          }),
          const SizedBox(height: 30),
          _buildMenuOptions(
              context,
              translation(context).about,
              //"About",
              Icon(
                Icons.abc_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            _launchInWebViewOrVC(Uri.parse("https://abc-barber.ch/about-us/"));
          }),
          const SizedBox(height: 30),
          _buildMenuOptions(
              context,
              translation(context).logout,
              // "LogOut",
              Icon(
                Icons.logout,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            Provider.of<AppointmentProvider>(context, listen: false)
                .setActiveAppointment([]);
            Provider.of<AppointmentProvider>(context, listen: false)
                .setHistoryAppointment([]);
            Provider.of<UserProvider>(context, listen: false).logout();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => AuthPage(true)),
              ),
            );
          }),
          const SizedBox(height: 30),
          _buildMenuOptions(
              context,
              translation(context).deleteAccount,
              // "Delete account!",
              Icon(
                Icons.delete_forever,
                size: 36,
                color: Theme.of(context).colorScheme.secondary,
              ), () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(
                  translation(context).alert,
                  // 'Alert',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                content: Text(
                  translation(context).deleteConfirmation,
                  // 'Are you sure you want to delete your account?'
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: Text(
                      translation(context).cancel,
                      // 'Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<AppointmentProvider>(context, listen: false)
                          .setActiveAppointment([]);
                      Provider.of<AppointmentProvider>(context, listen: false)
                          .setHistoryAppointment([]);
                      Provider.of<UserProvider>(context, listen: false)
                          .deleteAccount();
                      Provider.of<UserProvider>(context, listen: false)
                          .logout();
                      Navigator.pop(context, 'Cancel');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => AuthPage(true)),
                        ),
                      );
                    },
                    child: Text(
                      translation(context).okay,
                      //'OK',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(
      BuildContext context, String option, Icon icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.resolveWith((states) =>
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => const Color.fromARGB(255, 239, 239, 240),
            ),
          ),
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                icon,
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6), fontSize: 17),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black.withOpacity(0.6),
                )
              ],
            ),
          )),
    );
  }

  Future<void> _launchInWebViewOrVC(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw 'Could not launch $url';
    }
  }
}
