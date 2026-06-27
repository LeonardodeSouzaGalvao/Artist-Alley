// lib/services/event_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  EventService._();
  static final EventService instance = EventService._();

  final String _apiUrl = 'http://10.0.2.2:3000';
  StreamController<Map<String, dynamic>>? _controller;
  http.Client? _client;

  Stream<Map<String, dynamic>> connect(String userId) {

    if (_controller != null && !_controller!.isClosed) {
      return _controller!.stream;
    }

    _controller = StreamController<Map<String, dynamic>>.broadcast();
    _client = http.Client();
    _iniciar(userId);
    return _controller!.stream;
  }

  Future<void> _iniciar(String userId) async {
    try {
      final request = http.Request(
        'GET',
        Uri.parse('$_apiUrl/events/stream/$userId'),
      );

      final response = await _client!.send(request);
      final stream = response.stream.transform(utf8.decoder);

      String buffer = '';
      await for (final chunk in stream) {
        buffer += chunk;

        final partes = buffer.split('\n\n');
        buffer = partes.removeLast();

        for (final parte in partes) {
          if (parte.trim().isEmpty || parte.startsWith(': ping')) continue;

          final json = parte.replaceFirst('data: ', '').trim();
          try {
            final Map<String, dynamic> evento = jsonDecode(json);
            _controller?.add(evento);
          } catch (_) {}
        }
      }
    } catch (_) {

      await Future.delayed(const Duration(seconds: 5));
      _iniciar(userId);
    }
  }

  void disconnect() {
    _client?.close();
    _controller?.close();
    _controller = null;
    _client = null;
  }
}