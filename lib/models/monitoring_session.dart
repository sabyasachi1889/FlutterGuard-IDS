class MonitoringSession {
  final String id;
  final String userId;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int packetsAnalyzed;
  final int threatsDetected;
  final double bandwidthUsed;
  final int activeConnections;
  final String? sessionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MonitoringSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.packetsAnalyzed,
    required this.threatsDetected,
    required this.bandwidthUsed,
    required this.activeConnections,
    this.sessionNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonitoringSession.fromJson(Map<String, dynamic> json) {
    return MonitoringSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      packetsAnalyzed: json['packets_analyzed'] as int? ?? 0,
      threatsDetected: json['threats_detected'] as int? ?? 0,
      bandwidthUsed: (json['bandwidth_used'] as num?)?.toDouble() ?? 0.0,
      activeConnections: json['active_connections'] as int? ?? 0,
      sessionNotes: json['session_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'packets_analyzed': packetsAnalyzed,
      'threats_detected': threatsDetected,
      'bandwidth_used': bandwidthUsed,
      'active_connections': activeConnections,
      'session_notes': sessionNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Duration get elapsedTime {
    final endTime = endedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  String get formattedElapsedTime {
    final duration = elapsedTime;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isInactive => status == 'inactive';
  bool get hasError => status == 'error';
}
