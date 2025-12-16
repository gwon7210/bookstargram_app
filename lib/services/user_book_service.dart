import 'dart:convert';

import '../models/book_search_result.dart';
import '../models/user_book.dart';
import 'api_client.dart';

class UserBookService {
  const UserBookService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<List<UserBook>> fetchUserBooks() async {
    final response = await _apiClient.get('/user-books');

    if (response.statusCode != 200) {
      throw Exception('내 서재 정보를 불러오지 못했어요. (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => UserBook.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> registerBook({
    required BookSearchResult book,
    required DateTime goalDate,
  }) async {
    final requestBody = jsonEncode({
      'externalId': book.isbn,
      'title': book.title,
      'author': book.author,
      'coverUrl': book.imageUrl,
      'status': 'reading',
      'currentPage': 0,
      'goalDate': _formatDate(goalDate),
      'startedAt': _formatDate(DateTime.now()),
    });

    final response = await _apiClient.post(
      '/user-books',
      body: requestBody,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('도서 등록 실패 (${response.statusCode})');
    }
  }

  Future<UserBook> updateUserBook({
    required String id,
    required int currentPage,
  }) async {
    final requestBody = jsonEncode({
      'currentPage': currentPage,
    });

    final response = await _apiClient.patch(
      '/user-books/$id',
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception('도서 정보를 업데이트하지 못했어요. (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return UserBook.fromJson(decoded);
  }

  String _formatDate(DateTime date) =>
      date.toIso8601String().split('T').first;
}
