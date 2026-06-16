import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert.dart';
import '../utils/backend.dart';

class BackendApi {
  static String _base() => BackendConfig.apiBase;

  static Future<List<Alert>> fetchAlertsForUser(String userId) async {
    if (EmulatorConfig.useEmulator) {
      final coll = FirebaseFirestore.instance.collection('alerts');
      final snap = await coll.where('userId', isEqualTo: userId).get();
      return snap.docs
          .map((d) => Alert.fromMap(d.data()..['id'] = d.id))
          .toList();
    }

    final url = Uri.parse('${_base()}/alerts/user/$userId');
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.get(url, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load alerts (${res.statusCode})');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return data.map((e) => Alert.fromMap(e)).toList();
  }

  // Add other methods as needed (profiles, contacts, settings)
}
