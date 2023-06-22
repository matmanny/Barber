class Barber {
  String id;
  String firstName;
  String lastName;
  String phoneNum;
  String email;
  String pictureUrl;
  List<DateTime> daysoff;

  Barber({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNum,
    required this.pictureUrl,
    required this.daysoff,
  });
}
