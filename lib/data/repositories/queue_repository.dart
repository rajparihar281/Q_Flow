import 'package:q_flow/core/config/api_config.dart';
import 'package:q_flow/core/services/api_service.dart';
import 'package:q_flow/core/websocket/queue_websocket_service.dart';
import 'package:q_flow/data/models/queue_model.dart';

class QueueRepository {
  static final QueueWebSocketService _wsService = QueueWebSocketService();

  Future<List<QueueModel>> getTodayQueue() async {
    final response = await ApiService.get(ApiConfig.queueToday);
    final List queueData = response['data'] ?? [];
    return queueData
        .map((json) => QueueModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<QueueModel> updateQueueStatus(String id, String status) async {
    final response = await ApiService.patch(ApiConfig.queueStatus(id), {
      'status': status,
    });
    return QueueModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Connect to the live WebSocket queue stream.
  /// Returns a Stream<List<QueueModel>> that emits on every backend broadcast.
  Stream<List<QueueModel>>? connectLiveQueue() {
    _wsService.connect(ApiConfig.wsUrl);
    return _wsService.queueStream;
  }

  void disconnectLiveQueue() {
    _wsService.dispose();
  }

  bool get isConnected => _wsService.isConnected;
}
