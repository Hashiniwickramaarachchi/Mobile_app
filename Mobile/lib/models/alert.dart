enum AlertStatus { pending, checked }

enum AlertSeverity { medium, high }

class Alert {
  const Alert({
    required this.id,
    required this.type,
    required this.status,
    required this.severity,
    required this.occurredAt,
    required this.incidentDetail,
  });

  final int id;
  final String type;
  final AlertStatus status;
  final AlertSeverity severity;
  final DateTime occurredAt;
  final String incidentDetail;

  Alert copyWith({
    int? id,
    String? type,
    AlertStatus? status,
    AlertSeverity? severity,
    DateTime? occurredAt,
    String? incidentDetail,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      occurredAt: occurredAt ?? this.occurredAt,
      incidentDetail: incidentDetail ?? this.incidentDetail,
    );
  }

  factory Alert.fromMap(Map<String, dynamic> m) {
    return Alert(
      id: m['id'] is int ? m['id'] : int.tryParse('${m['id']}') ?? 0,
      type: m['type'] ?? '',
      status: (m['status'] == 'checked')
          ? AlertStatus.checked
          : AlertStatus.pending,
      severity:
          (m['severity'] == 'high') ? AlertSeverity.high : AlertSeverity.medium,
      occurredAt: DateTime.tryParse(m['occurredAt']?.toString() ?? '') ??
          DateTime.now(),
      incidentDetail: m['incidentDetail'] ?? '',
    );
  }
}
