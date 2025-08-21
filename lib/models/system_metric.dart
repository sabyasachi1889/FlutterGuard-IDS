class SystemMetric {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final double? cpuUsage;
  final double? memoryUsage;
  final double? diskUsage;
  final double? networkThroughput;
  final int? activeConnections;
  final int? packetsPerSecond;

  SystemMetric({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    this.cpuUsage,
    this.memoryUsage,
    this.diskUsage,
    this.networkThroughput,
    this.activeConnections,
    this.packetsPerSecond,
  });

  factory SystemMetric.fromJson(Map<String, dynamic> json) {
    return SystemMetric(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      cpuUsage: (json['cpu_usage'] as num?)?.toDouble(),
      memoryUsage: (json['memory_usage'] as num?)?.toDouble(),
      diskUsage: (json['disk_usage'] as num?)?.toDouble(),
      networkThroughput: (json['network_throughput'] as num?)?.toDouble(),
      activeConnections: json['active_connections'] as int?,
      packetsPerSecond: json['packets_per_second'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'cpu_usage': cpuUsage,
      'memory_usage': memoryUsage,
      'disk_usage': diskUsage,
      'network_throughput': networkThroughput,
      'active_connections': activeConnections,
      'packets_per_second': packetsPerSecond,
    };
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedCpuUsage =>
      cpuUsage != null ? '${cpuUsage!.toStringAsFixed(1)}%' : 'N/A';
  String get formattedMemoryUsage =>
      memoryUsage != null ? '${memoryUsage!.toStringAsFixed(1)}%' : 'N/A';
  String get formattedDiskUsage =>
      diskUsage != null ? '${diskUsage!.toStringAsFixed(1)}%' : 'N/A';

  String get formattedThroughput {
    if (networkThroughput == null) return 'N/A';
    return '${networkThroughput!.toStringAsFixed(1)} MB/s';
  }

  String get formattedConnections => activeConnections?.toString() ?? 'N/A';
  String get formattedPackets => packetsPerSecond?.toString() ?? 'N/A';

  // Helper methods for chart data
  Map<String, double> get chartData => {
        'cpu': cpuUsage ?? 0.0,
        'memory': memoryUsage ?? 0.0,
        'disk': diskUsage ?? 0.0,
      };

  bool get hasHighCpuUsage => cpuUsage != null && cpuUsage! > 80.0;
  bool get hasHighMemoryUsage => memoryUsage != null && memoryUsage! > 85.0;
  bool get hasHighDiskUsage => diskUsage != null && diskUsage! > 90.0;
  bool get hasPerformanceIssue =>
      hasHighCpuUsage || hasHighMemoryUsage || hasHighDiskUsage;
}
