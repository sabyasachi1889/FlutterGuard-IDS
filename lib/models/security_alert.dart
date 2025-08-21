class SecurityAlert {
  final String id;
  final String sessionId;
  final String alertType;
  final String severity;
  final String title;
  final String description;
  final String? sourceIp;
  final String? targetIp;
  final int? port;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final DateTime createdAt;

  SecurityAlert({
    required this.id,
    required this.sessionId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.description,
    this.sourceIp,
    this.targetIp,
    this.port,
    required this.isResolved,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNotes,
    required this.createdAt,
  });

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sourceIp: json['source_ip'] as String?,
      targetIp: json['target_ip'] as String?,
      port: json['port'] as int?,
      isResolved: json['is_resolved'] as bool? ?? false,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolutionNotes: json['resolution_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'alert_type': alertType,
      'severity': severity,
      'title': title,
      'description': description,
      'source_ip': sourceIp,
      'target_ip': targetIp,
      'port': port,
      'is_resolved': isResolved,
      'resolved_by': resolvedBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  bool get isCritical => severity == 'critical';
  bool get isHigh => severity == 'high';
  bool get isMedium => severity == 'medium';
  bool get isLow => severity == 'low';

  bool get isPortScan => alertType == 'port_scan';
  bool get isBruteForce => alertType == 'brute_force';
  bool get isAnomaly => alertType == 'anomaly';
  bool get isMalware => alertType == 'malware';
  bool get isDdos => alertType == 'ddos';
  bool get isIntrusion => alertType == 'intrusion';
}
