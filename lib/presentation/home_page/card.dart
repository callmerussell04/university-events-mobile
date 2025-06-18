part of 'home_page.dart';

class _Card extends StatefulWidget {
  final int id;
  final String name;
  final String status;
  final String startDateTime;
  final String endDateTime;
  final String organizer;
  final String locationName;
  final String invitationStatus;
  final int? userId;
  final int? eventId;
  final VoidCallback? onTap;

  const _Card(
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
      {this.onTap}
      );

  factory _Card.fromData(
      CardData data, {
        VoidCallback? onTap,
      }) =>
      _Card(
        data.id,
        data.name,
        data.status,
        data.startDateTime,
        data.endDateTime,
        data.organizer,
        data.locationName,
        data.invitationStatus,
        data.userId,
        data.eventId,
        onTap: onTap,
      );

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  Color _getInvitationStatusColor(String status) {
    switch (status) {
      case 'Посетил':
        return Colors.green[700]!;
      case 'Не посетил':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getInvitationStatusIcon(String status) {
    switch (status) {
      case 'Посетил':
        return Icons.check_circle_outline;
      case 'Не посетил':
        return Icons.highlight_off;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizedInvitationStatus = widget.invitationStatus;
    final invitationStatusColor = _getInvitationStatusColor(widget.invitationStatus);
    final invitationStatusIcon = _getInvitationStatusIcon(widget.invitationStatus);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              _buildInfoRow(
                context,
                icon: Icons.info_outline,
                label: 'Статус:',
                value: widget.status,
                color: Colors.blueGrey,
              ),

              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Начало:',
                value: widget.startDateTime,
                color: Colors.grey[800],
              ),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Окончание:',
                value: widget.endDateTime,
                color: Colors.grey[800],
              ),

              _buildInfoRow(
                context,
                icon: Icons.person_outline,
                label: 'Организатор:',
                value: widget.organizer,
                color: Colors.black87,
              ),

              _buildInfoRow(
                context,
                icon: Icons.location_on_outlined,
                label: 'Место:',
                value: widget.locationName,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    invitationStatusIcon,
                    color: invitationStatusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Статус приглашения: $localizedInvitationStatus', 
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: invitationStatusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary.withOpacity(0.7), size: 18.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color ?? Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}