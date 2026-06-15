import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/userSection.dart';

class OrderService {
  static const String _apiUrl = 'http://10.0.2.2:3000';

  static Future<void> createOrder({
    required String artistId,
    required String commissionSlotId,
    required String description,
    String? referenceImage,
  }) async {
    final clientId = UserSession.instance.id;
    if (clientId == null) throw Exception('Sessão expirada. Faça login novamente.');

    final token = UserSession.instance.token;

    final url = Uri.parse('$_apiUrl/orders/createOrder');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'clientId': clientId,
        'artistId': artistId,
        'commissionSlotId': commissionSlotId,
        'description': description,
        if (referenceImage != null) 'referenceImage': referenceImage,
      }),
    );

    if (response.statusCode == 201) return;

    final erro = jsonDecode(response.body);
    throw Exception(erro['error'] ?? 'Erro ao enviar proposta.');
  }
}