class Appointment {
  String id;
  DateTime bookingStart;
  DateTime bookingEnd;
  String serviceId;
  String barberId;

  Appointment({
    required this.id,
    required this.bookingStart,
    required this.bookingEnd,
    required this.serviceId,
    required this.barberId,
  });
}
