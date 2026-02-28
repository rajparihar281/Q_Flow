import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../../data/models/queue_model.dart';
import '../services/notification_service.dart';

/// Manages the WebSocket connection to the Q-Flow queue endpoint.
/// Usage:
///   final ws = QueueWebSocketService();
///   ws.connect();
///   ws.queueStream.listen((queue) { ... });
///   ws.dispose();
class QueueWebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  Stream<List<QueueModel>>? _broadcastStream;

  bool get isConnected => _isConnected;

  void connect(String wsUrl) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      // Transform raw WebSocket messages → List<QueueModel>
      _broadcastStream = _channel!.stream
          .where((raw) {
            try {
              final payload = json.decode(raw as String);
              if (payload['type'] == 'patient-called') {
                if (payload['patientId'] == 'demo-patient-1') {
                  NotificationService().showNotification(
                    id: 1,
                    title: "It's Your Turn",
                    body: "Please proceed to consultation room",
                  );
                }
                return false;
              }
              return payload['type'] == 'queue_update';
            } catch (_) {
              return false;
            }
          })
          .map((raw) {
            final Map<String, dynamic> payload = json.decode(raw as String);
            final List<dynamic> data = payload['data'] ?? [];
            return data
                .map(
                  (item) => QueueModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          })
          .handleError((dynamic err) {
            _isConnected = false;
          })
          .asBroadcastStream();
    } catch (e) {
      _isConnected = false;
    }
  }

  Stream<List<QueueModel>>? get queueStream => _broadcastStream;

  void dispose() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
