import 'package:flutter/foundation.dart';

import '../models/beautiful_sim.dart';
import 'api_client.dart';

class SimService extends ChangeNotifier {
  SimService._();

  static final SimService instance = SimService._();

  final List<BeautifulSim> _sims = [];

  List<BeautifulSim> getAllSims() {
    return List.unmodifiable(_sims);
  }

  Future<void> loadSims() async {
    try {
      final List<dynamic> jsonList = await ApiClient.instance.get('/sims');
      _sims.clear();
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          _sims.add(BeautifulSim.fromJson(Map<String, Object?>.from(item)));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sims: $e');
      rethrow;
    }
  }

  Future<void> addSim(BeautifulSim sim) async {
    try {
      await ApiClient.instance.post('/sims', sim.toJson());
      await loadSims();
    } catch (e) {
      debugPrint('Error adding sim: $e');
      rethrow;
    }
  }

  Future<void> updateSim(BeautifulSim updatedSim) async {
    try {
      await ApiClient.instance.put('/sims/${updatedSim.id}', updatedSim.toJson());
      await loadSims();
    } catch (e) {
      debugPrint('Error updating sim: $e');
      rethrow;
    }
  }

  Future<void> deleteSim(String id) async {
    try {
      await ApiClient.instance.delete('/sims/$id');
      await loadSims();
    } catch (e) {
      debugPrint('Error deleting sim: $e');
      rethrow;
    }
  }
}
