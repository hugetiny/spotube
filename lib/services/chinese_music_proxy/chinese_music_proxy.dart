import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

final chineseMusicProxyProvider = Provider<ChineseMusicProxy>((ref) {
  return ChineseMusicProxy(ref);
});

class ChineseMusicProxy {
  final Ref ref;
  
  ChineseMusicProxy(this.ref);
  
  // Base URL for the proxy server
  String get _baseUrl {
    final preferences = ref.read(userPreferencesProvider);
    return preferences.chineseMusicProxyUrl ?? 'https://music-api.example.com';
  }
  
  // Check if proxy URL is configured
  bool get isProxyConfigured {
    final preferences = ref.read(userPreferencesProvider);
    return preferences.chineseMusicProxyUrl != null;
  }
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'User-Agent': 'Spotube/1.0',
  };
  
  // Generate a signature for request authentication
  String _generateSignature(Map<String, dynamic> params, String timestamp) {
    final sortedKeys = params.keys.toList()..sort();
    final sortedParams = <String, dynamic>{};
    for (final key in sortedKeys) {
      sortedParams[key] = params[key];
    }
    
    final paramsString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    final signString = '$paramsString&timestamp=$timestamp';
    final secretKey = 'your_secret_key'; // This would be stored securely
    
    final hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    final digest = hmacSha256.convert(utf8.encode(signString));
    
    return digest.toString();
  }
  
  // Check if the proxy server is working
  Future<bool> checkProxyStatus() async {
    if (!isProxyConfigured) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Search for music on Chinese platforms
  Future<Map<String, dynamic>> searchMusic({
    required String platform,
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final params = {
      'platform': platform,
      'keyword': keyword,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    final signature = _generateSignature(params, timestamp);
    
    final response = await http.post(
      Uri.parse('$_baseUrl/search'),
      headers: {
        ..._headers,
        'X-Timestamp': timestamp,
        'X-Signature': signature,
      },
      body: jsonEncode({
        ...params,
        'timestamp': timestamp,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to search music: ${response.body}');
    }
    
    return jsonDecode(response.body);
  }
  
  // Get music URL from Chinese platforms
  Future<Map<String, dynamic>> getMusicUrl({
    required String platform,
    required String songId,
    required String quality,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final params = {
      'platform': platform,
      'songId': songId,
      'quality': quality,
    };
    
    final signature = _generateSignature(params, timestamp);
    
    final response = await http.post(
      Uri.parse('$_baseUrl/url'),
      headers: {
        ..._headers,
        'X-Timestamp': timestamp,
        'X-Signature': signature,
      },
      body: jsonEncode({
        ...params,
        'timestamp': timestamp,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to get music URL: ${response.body}');
    }
    
    return jsonDecode(response.body);
  }
  
  // Get lyrics from Chinese platforms
  Future<Map<String, dynamic>> getLyric({
    required String platform,
    required String songId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final params = {
      'platform': platform,
      'songId': songId,
    };
    
    final signature = _generateSignature(params, timestamp);
    
    final response = await http.post(
      Uri.parse('$_baseUrl/lyric'),
      headers: {
        ..._headers,
        'X-Timestamp': timestamp,
        'X-Signature': signature,
      },
      body: jsonEncode({
        ...params,
        'timestamp': timestamp,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to get lyrics: ${response.body}');
    }
    
    return jsonDecode(response.body);
  }
}