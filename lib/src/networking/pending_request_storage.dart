// lib/src/networking/pending_request_storage.dart
import '../storage/hive_storage.dart';
import 'models/pending_request.dart';

class PendingRequestStorage extends HiveStorageImpl<PendingRequest> {
  PendingRequestStorage()
      : super(
          'pending_requests_box',
          getEntityId: (request) => request.id,
        );
  
  Future<List<PendingRequest>> getAllSortedByPriority() async {
    final requests = await getAll();
    requests.sort((a, b) {
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.createdAt.compareTo(b.createdAt);
    });
    return requests;
  }
  
  Future<List<PendingRequest>> getByPriority(int priority) async {
    final requests = await getAll();
    return requests.where((r) => r.priority == priority).toList();
  }
  
  Future<int> getCount() async {
    return await count();
  }
}