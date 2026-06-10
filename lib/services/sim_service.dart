import 'package:flutter/foundation.dart';

import '../data/mock_sim_data.dart';
import '../models/beautiful_sim.dart';

class SimService extends ChangeNotifier {
  SimService._();

  static final SimService instance = SimService._();

  final List<BeautifulSim> _sims = List.from(mockSims);

  List<BeautifulSim> getAllSims() {
    return List.unmodifiable(_sims);
  }

  void addSim(BeautifulSim sim) {
    _sims.add(sim);
    notifyListeners();
  }

  void updateSim(BeautifulSim updatedSim) {
    final index = _sims.indexWhere((sim) => sim.id == updatedSim.id);
    if (index != -1) {
      _sims[index] = updatedSim;
      notifyListeners();
    }
  }

  void deleteSim(String id) {
    final beforeLength = _sims.length;
    _sims.removeWhere((sim) => sim.id == id);
    if (_sims.length != beforeLength) {
      notifyListeners();
    }
  }
}
