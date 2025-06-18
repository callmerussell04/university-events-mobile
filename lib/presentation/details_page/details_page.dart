import 'package:flutter/material.dart';
import 'package:university_events/domain/models/card.dart';
import 'package:university_events/data/repositories/invitation_repository.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailsPage extends StatefulWidget {
  final CardData data;

  const DetailsPage(this.data, {super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late InvitationRepository _invitationRepository;
  bool _isUpdatingStatus = false;
  String _currentInvitationStatus = '';
  bool _statusChanged = false;

  @override
  void initState() {
    super.initState();
    _invitationRepository = context.read<InvitationRepository>();
    _currentInvitationStatus = widget.data.invitationStatus;
  }

  Future<void> _markAsCompleted() async {
    setState(() {
      _isUpdatingStatus = true;
    });

    final success = await _invitationRepository.updateInvitationStatus(
      widget.data.id,
      widget.data.userId,
      widget.data.eventId,
      'Посетил',
      onError: (error) {
        Fluttertoast.showToast(msg: error ?? 'Неизвестная ошибка!', toastLength: Toast.LENGTH_LONG);
      },
    );

    setState(() {
      _isUpdatingStatus = false;
      if (success) {
        _currentInvitationStatus = 'Посетил';
        _statusChanged = true;
        Fluttertoast.showToast(msg: 'Статус обновлен на Посетил!', toastLength: Toast.LENGTH_SHORT);
      } else {
        Fluttertoast.showToast(msg: 'Не удалось обновить статус.', toastLength: Toast.LENGTH_SHORT);
      }
    });
  }


  @override
  void dispose() {

    Navigator.pop(context, _statusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали Мероприятия'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _statusChanged);
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildInfoRow(
                context,
                icon: Icons.event_note,
                label: 'Статус события:',
                value: widget.data.status,
              ),
              const Divider(),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Начало:',
                value: widget.data.startDateTime,
              ),
              const Divider(),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Окончание:',
                value: widget.data.endDateTime,
              ),
              const Divider(),
              _buildInfoRow(
                context,
                icon: Icons.person,
                label: 'Организатор:',
                value: widget.data.organizer,
              ),
              const Divider(),
              _buildInfoRow(
                context,
                icon: Icons.location_on,
                label: 'Место:',
                value: widget.data.locationName,
              ),
              const Divider(),
              _buildInfoRow(
                context,
                icon: Icons.how_to_reg,
                label: 'Статус приглашения:',
                value: _currentInvitationStatus,
              ),
              const SizedBox(height: 32.0),
              if (_currentInvitationStatus != 'Посетил')
                Center(
                  child: _isUpdatingStatus
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                    onPressed: _markAsCompleted,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Отметить как пройденное'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              if (_currentInvitationStatus == 'Посетил')
                const Center(
                  child: Chip(
                    label: Text('Мероприятие пройдено!'),
                    avatar: Icon(Icons.done_all, color: Colors.white),
                    backgroundColor: Colors.lightGreen,
                    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}