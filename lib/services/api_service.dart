import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Your API key
  static const String apiKey = 'vj2cFaTvx6Ywa4RQC8MtFnftsckd2fZuZVQjhfaR';

  // Function to fetch a random quote
  static Future<Map<String, String>> fetchRandomQuote() async {
    final url = Uri.parse(
      'https://api.api-ninjas.com/v2/randomquotes?categories=success,wisdom',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Api-Key': apiKey, // ✅ single comma only
        },
      );

      if (response.statusCode == 200) {
        // API returns a JSON array
        final List data = jsonDecode(response.body);
        return {
          'content': data[0]['quote'], // Quote text
          'author': data[0]['author'], // Author name
        };
      } else {
        throw Exception(
          'Failed to fetch quote. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching quote: $e');
    }
  }
}
