import 'dart:convert';
import 'package:http/http.dart' as http;
import 'userSection.dart';

class OrderService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${UserSession.instance.token}',
  };

  static Future<Map<String, dynamic>> createOrder({
    required String artistId,
    required String commissionSlotId,
    String? description,
    String? referenceImage,
  }) async {
    final clientId = UserSession.instance.id;
    if (clientId == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$_baseUrl/orders/createOrder'),
      headers: _headers,
      body: jsonEncode({
        'clientId': clientId,
        'artistId': artistId,
        'commissionSlotId': commissionSlotId,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (referenceImage != null && referenceImage.isNotEmpty)
          'referenceImage': referenceImage,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) return body;

    throw Exception(body['error'] ?? 'Erro ao criar pedido');
  }

  static Future<List<dynamic>> findByClientId() async {
    final clientId = UserSession.instance.id;
    if (clientId == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('$_baseUrl/orders/client/$clientId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['error'] ?? 'Erro ao buscar pedidos');
  }

  static Future<Map<String, dynamic>> findById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/$id'),
      headers: _headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Erro ao buscar pedido');
  }

  static Future<List<dynamic>> findQueueByCommissionSlot(
      String commissionSlotId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/commissionSlot/$commissionSlotId/queue'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['error'] ?? 'Erro ao buscar fila');
  }

  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final artistId = UserSession.instance.id;
    if (artistId == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$_baseUrl/orders/$orderId/accept'),
      headers: _headers,
      body: jsonEncode({'artistId': artistId}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Erro ao aceitar pedido');
  }

  static Future<Map<String, dynamic>> rejectOrder(String orderId) async {
    final artistId = UserSession.instance.id;
    if (artistId == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$_baseUrl/orders/$orderId/reject'),
      headers: _headers,
      body: jsonEncode({'artistId': artistId}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Erro ao rejeitar pedido');
  }
}