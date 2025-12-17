import 'dart:convert';

import '../models/feeling_entry.dart';
import 'api_client.dart';

class ReadingLogService {
  const ReadingLogService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<void> createFeeling({
    required String userBookId,
    required String text,
  }) async {
    final response = await _apiClient.post(
      '/feelings',
      body: jsonEncode({
        'userBookId': userBookId,
        'text': text,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('독서 기록을 저장하지 못했어요. (${response.statusCode})');
    }
  }

  Future<List<FeelingEntry>> fetchFeelings(String userBookId) async {
    final response = await _apiClient.get('/feelings/$userBookId');

    if (response.statusCode != 200) {
      throw Exception('독서 기록을 불러오지 못했어요. (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => FeelingEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
