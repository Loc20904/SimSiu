import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/beautiful_sim.dart';
import 'auth_service.dart';

class SimService extends ChangeNotifier {
  SimService._();

  static final SimService instance = SimService._();

  final List<BeautifulSim> _sims = [];

  List<BeautifulSim> getAllSims() {
    return List.unmodifiable(_sims);
  }

  Future<void> loadSims() => fetchSims();

  Future<void> fetchSims() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/sims'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _sims.clear();
        _sims.addAll(data.map((item) => BeautifulSim.fromJson(item)));
        notifyListeners();
      } else {
        debugPrint('Failed to load sims: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sims: $e');
    }
  }

  Future<void> addSim(BeautifulSim sim) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sims'),
        headers: AuthService.instance.authHeaders,
        body: jsonEncode(sim.toJson()),
      );

      if (response.statusCode == 201) {
        final createdSim = BeautifulSim.fromJson(jsonDecode(response.body));
        _sims.add(createdSim);
        notifyListeners();
      } else {
        debugPrint('Failed to add sim: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding sim: $e');
    }
  }

  Future<void> updateSim(BeautifulSim updatedSim) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/sims/${updatedSim.id}'),
        headers: AuthService.instance.authHeaders,
        body: jsonEncode(updatedSim.toJson()),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        final index = _sims.indexWhere((sim) => sim.id == updatedSim.id);
        if (index != -1) {
          _sims[index] = updatedSim;
          notifyListeners();
        }
      } else {
        debugPrint('Failed to update sim: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating sim: $e');
    }
  }

  Future<void> deleteSim(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/sims/$id'),
        headers: AuthService.instance.authHeaders,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        final beforeLength = _sims.length;
        _sims.removeWhere((sim) => sim.id == id);
        if (_sims.length != beforeLength) {
          notifyListeners();
        }
      } else {
        debugPrint('Failed to delete sim: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting sim: $e');
    }
  }
}
