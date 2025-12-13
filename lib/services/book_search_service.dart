import 'dart:convert';

import '../models/book_search_result.dart';
import 'api_client.dart';

class BookSearchService {
  const BookSearchService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<List<BookSearchResult>> searchBooks(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final encodedQuery = Uri.encodeQueryComponent(trimmedQuery);
    final response = await _apiClient.get('/books/search?query=$encodedQuery');

    if (response.statusCode != 200) {
      throw Exception('도서 검색 실패 (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? [];

    return items
        .map((item) => BookSearchResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
