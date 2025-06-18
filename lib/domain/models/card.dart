import 'package:flutter/material.dart';

class CardData {
  final int id;
  final String name;
  final String status;
  final String startDateTime;
  final String endDateTime;
  final String organizer;
  final String locationName;
  final String invitationStatus;
  final int userId;
  final int eventId;


  CardData(
      this.id,
      this.name,
      this.status,
      this.startDateTime,
      this.endDateTime,
      this.organizer,
      this.locationName,
      this.invitationStatus,
      this.userId,
      this.eventId,
      );
}
