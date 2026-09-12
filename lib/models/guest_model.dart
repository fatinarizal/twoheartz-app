class GuestModel {
  final String id;
  final String weddingId;
  final String guestName;
  final String email;
  final String phoneNumber;
  final String rsvpStatus;

  GuestModel({
    required this.id,
    required this.weddingId,
    required this.guestName,
    required this.email,
    required this.phoneNumber,
    required this.rsvpStatus,
  });

  factory GuestModel.fromMap(Map<String, dynamic> map) {
    return GuestModel(
      id: map['id'] ?? '',
      weddingId: map['wedding_id'] ?? '',
      guestName: map['guest_name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      rsvpStatus: map['rsvp_status'] ?? 'Pending',
    );
  }
}