import 'package:flutter/foundation.dart';

import '../models/beautiful_sim.dart';
import 'api_client.dart';

class SimService extends ChangeNotifier {
  SimService._();

  static final SimService instance = SimService._();

  final List<BeautifulSim> _sims = [];
  var _hasLoadedFromApi = false;
  var _isLoading = false;

  bool get hasLoadedFromApi => _hasLoadedFromApi;
  bool get isLoading => _isLoading;

  List<BeautifulSim> getAllSims() {
    return List.unmodifiable(_sims);
  }

  Future<void> loadSims() async {
    await fetchSims(force: true);
  }

  Future<List<BeautifulSim>> fetchSims({bool force = false}) async {
    if (_hasLoadedFromApi && !force) {
      return getAllSims();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.getList('/sims');
      _sims
        ..clear()
        ..addAll(
          response.map(
            (item) => BeautifulSim.fromJson(Map<String, Object?>.from(item as Map)),
          ),
        );
      _hasLoadedFromApi = true;
      return getAllSims();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BeautifulSim?> fetchSimById(String id) async {
    try {
      final response = await ApiClient.instance.getObject('/sims/$id');
      final sim = BeautifulSim.fromJson(response);
      final index = _sims.indexWhere((item) => item.id == sim.id);
      if (index == -1) {
        _sims.add(sim);
      } else {
        _sims[index] = sim;
      }
      notifyListeners();
      return sim;
    } on ApiException {
      return null;
    }
  }

  Future<void> addSim(BeautifulSim sim) async {
    final response = await ApiClient.instance.post(
      '/sims',
      body: sim.toJson(),
      requiresAuth: true,
    );
    final created = BeautifulSim.fromJson(Map<String, Object?>.from(response as Map));
    _sims.add(created);
    notifyListeners();
  }

  Future<void> updateSim(BeautifulSim updatedSim) async {
    await ApiClient.instance.put(
      '/sims/${updatedSim.id}',
      body: updatedSim.toJson(),
      requiresAuth: true,
    );

    final index = _sims.indexWhere((sim) => sim.id == updatedSim.id);
    if (index != -1) {
      _sims[index] = updatedSim;
    }
    notifyListeners();
  }

  Future<void> updateSimLocal(BeautifulSim updatedSim) async {
    final index = _sims.indexWhere((sim) => sim.id == updatedSim.id);
    if (index != -1) {
      _sims[index] = updatedSim;
      notifyListeners();
    }
  }

  Future<void> deleteSim(String id) async {
    await ApiClient.instance.delete('/sims/$id', requiresAuth: true);
    _sims.removeWhere((sim) => sim.id == id);
    notifyListeners();
  }
}
