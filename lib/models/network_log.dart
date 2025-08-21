class NetworkLog {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final String sourceIp;
  final String destinationIp;
  final int? sourcePort;
  final int? destinationPort;
  final String protocol;
  final int? packetSize;
  final String logLevel;
  final Map<String, dynamic>? rawData;
  final bool isSuspicious;

  NetworkLog({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.sourceIp,
    required this.destinationIp,
    this.sourcePort,
    this.destinationPort,
    required this.protocol,
    this.packetSize,
    required this.logLevel,
    this.rawData,
    required this.isSuspicious,
  });

  factory NetworkLog.fromJson(Map<String, dynamic> json) {
    return NetworkLog(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sourceIp: json['source_ip'] as String,
      destinationIp: json['destination_ip'] as String,
      sourcePort: json['source_port'] as int?,
      destinationPort: json['destination_port'] as int?,
      protocol: json['protocol'] as String,
      packetSize: json['packet_size'] as int?,
      logLevel: json['log_level'] as String? ?? 'info',
      rawData: json['raw_data'] as Map<String, dynamic>?,
      isSuspicious: json['is_suspicious'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'source_ip': sourceIp,
      'destination_ip': destinationIp,
      'source_port': sourcePort,
      'destination_port': destinationPort,
      'protocol': protocol,
      'packet_size': packetSize,
      'log_level': logLevel,
      'raw_data': rawData,
      'is_suspicious': isSuspicious,
    };
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get connectionString {
    final srcPort = sourcePort != null ? ':$sourcePort' : '';
    final destPort = destinationPort != null ? ':$destinationPort' : '';
    return '$sourceIp$srcPort → $destinationIp$destPort';
  }

  String get formattedSize {
    if (packetSize == null) return 'Unknown';

    final bytes = packetSize!;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool get isInfo => logLevel == 'info';
  bool get isWarning => logLevel == 'warning';
  bool get isError => logLevel == 'error';
  bool get isCritical => logLevel == 'critical';

  bool get isTcp => protocol.toUpperCase() == 'TCP';
  bool get isUdp => protocol.toUpperCase() == 'UDP';
  bool get isIcmp => protocol.toUpperCase() == 'ICMP';
}
