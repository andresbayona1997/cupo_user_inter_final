import 'package:shopkeeper/services/storage_service.dart';
import 'package:shopkeeper/config.dart';

class StatusService {
  StorageService _storageService = new StorageService();

  Future<bool> shoopkeeperValidated() async {
    String status = await _storageService.getValue('status');
    if (status != null && status == SHOPKEEPER_ENABLED) {
      return true;
    }
    return false;
  }
}