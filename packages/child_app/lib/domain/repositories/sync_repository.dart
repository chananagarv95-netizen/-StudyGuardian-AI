/// Abstract repository for data synchronization between local and remote.
abstract class SyncRepository {
  /// Runs a full sync cycle: collect data, store locally, push to Firestore.
  Future<void> runFullSync(String deviceId);

  /// Pushes all pending local items to Firestore.
  Future<void> pushPendingItems();

  /// Returns the number of items waiting to be synced.
  int getPendingCount();

  /// Clears the pending sync queue after successful upload.
  Future<void> clearPendingQueue();
}
