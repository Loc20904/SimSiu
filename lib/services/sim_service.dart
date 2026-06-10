import '../data/mock_sim_data.dart';
import '../models/beautiful_sim.dart';

class SimService {
  SimService._();

  static final SimService instance = SimService._();

  final List<BeautifulSim> _sims = List.from(mockSims);

  List<BeautifulSim> getAllSims() {
    return List.unmodifiable(_sims);
  }

  void addSim(BeautifulSim sim) {
    _sims.add(sim);
  }

  void updateSim(BeautifulSim updatedSim) {
    final index = _sims.indexWhere((sim) => sim.id == updatedSim.id);
    if (index != -1) {
      _sims[index] = updatedSim;
    }
  }

  void deleteSim(String id) {
    _sims.removeWhere((sim) => sim.id == id);
  }
}
