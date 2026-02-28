import 'package:flutter/material.dart';
import 'package:q_flow/core/config/api_config.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/widgets/app_card.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/data/models/queue_model.dart';
import 'package:q_flow/data/repositories/queue_repository.dart';

class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  final _repo = QueueRepository();
  List<QueueModel> _initialQueue = [];
  Stream<List<QueueModel>>? _liveStream;
  bool _loading = true;
  String? _error;
  bool _wsConnected = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Fetch initial queue via REST
      final queue = await _repo.getTodayQueue();
      // 2. Open WebSocket for live updates
      final stream = _repo.connectLiveQueue();
      if (mounted) {
        setState(() {
          _initialQueue = queue;
          _liveStream = stream;
          _wsConnected = _repo.isConnected;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _repo.disconnectLiveQueue();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Live Queue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _wsConnected ? Icons.wifi : Icons.wifi_off,
                  color: _wsConnected ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _wsConnected ? 'Live' : 'Offline',
                  style: TextStyle(
                    color: _wsConnected ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _init();
            },
          ),
        ],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _liveStream != null
          ? StreamBuilder<List<QueueModel>>(
              stream: _liveStream,
              initialData: _initialQueue,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return _buildError(snap.error.toString());
                }
                final queue = snap.data ?? _initialQueue;
                if (queue.isEmpty) return _buildEmpty();
                return _buildQueueList(queue);
              },
            )
          : _buildQueueList(_initialQueue),
    );
  }

  Widget _buildError([String? msg]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Unable to load queue',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            msg ?? _error ?? 'Unknown error',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _init();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Backend: ${ApiConfig.baseUrl}',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No patients in queue today',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(List<QueueModel> queue) {
    final waiting = queue.where((q) => q.isWaiting).toList();
    final called = queue.where((q) => q.isCalled).toList();
    final completed = queue.where((q) => q.isCompleted || q.isSkipped).toList();

    return RefreshIndicator(
      onRefresh: _init,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Stats Bar ────────────────────────────────────────────
          _statsRow(
            waiting: waiting.length,
            called: called.length,
            completed: completed.length,
          ),
          const SizedBox(height: 16),

          // ── Currently Called ─────────────────────────────────────
          if (called.isNotEmpty) ...[
            _sectionHeader('🔔 Now Called', Colors.orange),
            ...called.map((q) => _QueueCard(entry: q, highlight: true)),
            const SizedBox(height: 12),
          ],

          // ── Waiting ───────────────────────────────────────────────
          if (waiting.isNotEmpty) ...[
            _sectionHeader('⏳ Waiting (${waiting.length})', AppColors.primary),
            ...waiting.map((q) => _QueueCard(entry: q)),
            const SizedBox(height: 12),
          ],

          // ── Done ─────────────────────────────────────────────────
          if (completed.isNotEmpty) ...[
            _sectionHeader('✅ Completed (${completed.length})', Colors.green),
            ...completed.map((q) => _QueueCard(entry: q, faded: true)),
          ],
        ],
      ),
    );
  }

  Widget _statsRow({
    required int waiting,
    required int called,
    required int completed,
  }) {
    return Row(
      children: [
        _statChip('Waiting', waiting, Colors.blue),
        const SizedBox(width: 8),
        _statChip('Called', called, Colors.orange),
        const SizedBox(width: 8),
        _statChip('Done', completed, Colors.green),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final QueueModel entry;
  final bool highlight;
  final bool faded;

  const _QueueCard({
    required this.entry,
    this.highlight = false,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (entry.status) {
      case 'called':
        statusColor = Colors.orange;
        statusLabel = 'Called';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusLabel = 'Completed';
        break;
      case 'skipped':
        statusColor = Colors.grey;
        statusLabel = 'Skipped';
        break;
      default:
        statusColor = Colors.blue;
        statusLabel = 'Waiting';
    }

    return AnimatedOpacity(
      opacity: faded ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.all(4),
          borderGlow: highlight,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.15),
              child: Text(
                '#${entry.tokenNumber}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            title: Text(
              entry.patientName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.doctorName != null)
                  Text(
                    '${entry.doctorName} • ${entry.specialization ?? ""}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (entry.bookingId != null)
                  Text(
                    entry.bookingId!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (entry.severity != null)
                  Text(
                    entry.severity!,
                    style: TextStyle(
                      fontSize: 10,
                      color: entry.severity == 'High'
                          ? Colors.red
                          : entry.severity == 'Medium'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
