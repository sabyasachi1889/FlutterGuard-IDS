import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/monitoring_session.dart';
import '../models/network_log.dart';
import '../models/security_alert.dart';
import '../models/system_metric.dart';
import './supabase_service.dart';

class MonitoringService {
  static MonitoringService? _instance;
  static MonitoringService get instance => _instance ??= MonitoringService._();

  MonitoringService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Monitoring Sessions
  Future<List<MonitoringSession>> getMonitoringSessions() async {
    try {
      final response = await _client
          .from('monitoring_sessions')
          .select()
          .order('created_at', ascending: false);

      return response
          .map<MonitoringSession>((json) => MonitoringSession.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get monitoring sessions: $error');
    }
  }

  Future<MonitoringSession> createMonitoringSession() async {
    try {
      final response = await _client
          .from('monitoring_sessions')
          .insert({
            'user_id': _client.auth.currentUser!.id,
            'status': 'active',
            'started_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return MonitoringSession.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create monitoring session: $error');
    }
  }

  Future<MonitoringSession> updateMonitoringSession(
      String sessionId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('monitoring_sessions')
          .update(updates)
          .eq('id', sessionId)
          .select()
          .single();

      return MonitoringSession.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update monitoring session: $error');
    }
  }

  Future<void> endMonitoringSession(String sessionId) async {
    try {
      await _client.from('monitoring_sessions').update({
        'status': 'inactive',
        'ended_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
    } catch (error) {
      throw Exception('Failed to end monitoring session: $error');
    }
  }

  // Security Alerts
  Future<List<SecurityAlert>> getSecurityAlerts({
    String? sessionId,
    String? severity,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('security_alerts').select('''
            *,
            monitoring_sessions!inner(user_id)
          ''');

      if (sessionId != null) {
        query = query.eq('session_id', sessionId);
      }
      if (severity != null) {
        query = query.eq('severity', severity);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return response
          .map<SecurityAlert>((json) => SecurityAlert.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get security alerts: $error');
    }
  }

  Future<SecurityAlert> createSecurityAlert({
    required String sessionId,
    required String alertType,
    required String severity,
    required String title,
    required String description,
    String? sourceIp,
    String? targetIp,
    int? port,
  }) async {
    try {
      final response = await _client
          .from('security_alerts')
          .insert({
            'session_id': sessionId,
            'alert_type': alertType,
            'severity': severity,
            'title': title,
            'description': description,
            'source_ip': sourceIp,
            'target_ip': targetIp,
            'port': port,
          })
          .select()
          .single();

      return SecurityAlert.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create security alert: $error');
    }
  }

  Future<void> resolveSecurityAlert(
      String alertId, String resolutionNotes) async {
    try {
      await _client.from('security_alerts').update({
        'is_resolved': true,
        'resolved_by': _client.auth.currentUser!.id,
        'resolved_at': DateTime.now().toIso8601String(),
        'resolution_notes': resolutionNotes,
      }).eq('id', alertId);
    } catch (error) {
      throw Exception('Failed to resolve security alert: $error');
    }
  }

  // Network Logs
  Future<List<NetworkLog>> getNetworkLogs({
    String? sessionId,
    String? logLevel,
    bool? isSuspicious,
    int limit = 100,
  }) async {
    try {
      var query = _client.from('network_logs').select('''
            *,
            monitoring_sessions!inner(user_id)
          ''');

      if (sessionId != null) {
        query = query.eq('session_id', sessionId);
      }
      if (logLevel != null) {
        query = query.eq('log_level', logLevel);
      }
      if (isSuspicious != null) {
        query = query.eq('is_suspicious', isSuspicious);
      }

      final response =
          await query.order('timestamp', ascending: false).limit(limit);

      return response
          .map<NetworkLog>((json) => NetworkLog.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get network logs: $error');
    }
  }

  Future<NetworkLog> createNetworkLog({
    required String sessionId,
    required String sourceIp,
    required String destinationIp,
    required String protocol,
    int? sourcePort,
    int? destinationPort,
    int? packetSize,
    String logLevel = 'info',
    Map<String, dynamic>? rawData,
    bool isSuspicious = false,
  }) async {
    try {
      final response = await _client
          .from('network_logs')
          .insert({
            'session_id': sessionId,
            'source_ip': sourceIp,
            'destination_ip': destinationIp,
            'source_port': sourcePort,
            'destination_port': destinationPort,
            'protocol': protocol,
            'packet_size': packetSize,
            'log_level': logLevel,
            'raw_data': rawData,
            'is_suspicious': isSuspicious,
          })
          .select()
          .single();

      return NetworkLog.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create network log: $error');
    }
  }

  // System Metrics
  Future<List<SystemMetric>> getSystemMetrics({
    required String sessionId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 50,
  }) async {
    try {
      var query =
          _client.from('system_metrics').select().eq('session_id', sessionId);

      if (startTime != null) {
        query = query.gte('timestamp', startTime.toIso8601String());
      }
      if (endTime != null) {
        query = query.lte('timestamp', endTime.toIso8601String());
      }

      final response =
          await query.order('timestamp', ascending: false).limit(limit);

      return response
          .map<SystemMetric>((json) => SystemMetric.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get system metrics: $error');
    }
  }

  Future<SystemMetric> recordSystemMetric({
    required String sessionId,
    double? cpuUsage,
    double? memoryUsage,
    double? diskUsage,
    double? networkThroughput,
    int? activeConnections,
    int? packetsPerSecond,
  }) async {
    try {
      final response = await _client
          .from('system_metrics')
          .insert({
            'session_id': sessionId,
            'cpu_usage': cpuUsage,
            'memory_usage': memoryUsage,
            'disk_usage': diskUsage,
            'network_throughput': networkThroughput,
            'active_connections': activeConnections,
            'packets_per_second': packetsPerSecond,
          })
          .select()
          .single();

      return SystemMetric.fromJson(response);
    } catch (error) {
      throw Exception('Failed to record system metric: $error');
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToAlerts(
      void Function(PostgresChangePayload) onAlert) {
    return _client
        .channel('security_alerts_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'security_alerts',
          callback: onAlert,
        )
        .subscribe();
  }

  RealtimeChannel subscribeToSessionUpdates(
      String sessionId, void Function(PostgresChangePayload) onUpdate) {
    return _client
        .channel('session_updates_$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'monitoring_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: sessionId,
          ),
          callback: onUpdate,
        )
        .subscribe();
  }

  // Cleanup
  Future<void> cleanupOldData({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      // Clean up old logs
      await _client
          .from('network_logs')
          .delete()
          .lt('timestamp', cutoffDate.toIso8601String());

      // Clean up old metrics
      await _client
          .from('system_metrics')
          .delete()
          .lt('timestamp', cutoffDate.toIso8601String());
    } catch (error) {
      throw Exception('Failed to cleanup old data: $error');
    }
  }
}
