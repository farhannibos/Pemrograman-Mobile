// lib/app/modules/events/models/event_form_model.dart
class EventFormModel {
  String? id;
  String title;
  String description;
  DateTime date;
  String speaker;
  String location;

  EventFormModel({
    this.id,
    this.title = '',
    this.description = '',
    required this.date,
    this.speaker = '',
    this.location = '',
  });
}