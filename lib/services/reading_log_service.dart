import 'dart:convert';

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
}
