import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/services/chinese_music_proxy/chinese_music_proxy.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/sourced_track/sourced_track.dart';

abstract class ChineseSourcedTrack extends SourcedTrack {
  ChineseSourcedTrack({
    required super.ref,
    required super.source,
    required super.siblings,
    required super.sourceInfo,
    required super.track,
  });

  // Common method to search for music across Chinese platforms
  static Future<Map<String, dynamic>> searchMusic({
    required String platform,
    required String keyword,
    required Ref ref,
    int page = 1,
    int limit = 10,
  }) async {
    final proxy = ref.read(chineseMusicProxyProvider);
    
    return await proxy.searchMusic(
      platform: platform,
      keyword: keyword,
      page: page,
      limit: limit,
    );
  }

  // Common method to get music URL across Chinese platforms
  static Future<Map<String, dynamic>> getMusicUrl({
    required String platform,
    required String songId,
    required String quality,
    required Ref ref,
  }) async {
    final proxy = ref.read(chineseMusicProxyProvider);
    
    return await proxy.getMusicUrl(
      platform: platform,
      songId: songId,
      quality: quality,
    );
  }

  // Common method to get lyrics across Chinese platforms
  static Future<Map<String, dynamic>> getLyric({
    required String platform,
    required String songId,
    required Ref ref,
  }) async {
    final proxy = ref.read(chineseMusicProxyProvider);
    
    return await proxy.getLyric(
      platform: platform,
      songId: songId,
    );
  }
  
  // Helper method to convert quality to platform-specific format
  static String mapQuality(SourceQualities quality, String platform) {
    switch (platform) {
      case 'kw':
        return switch (quality) {
          SourceQualities.high => '320',
          SourceQualities.medium => '192',
          SourceQualities.low => '128',
        };
      case 'kg':
        return switch (quality) {
          SourceQualities.high => '320',
          SourceQualities.medium => '192',
          SourceQualities.low => '128',
        };
      case 'tx':
        return switch (quality) {
          SourceQualities.high => '320',
          SourceQualities.medium => '192',
          SourceQualities.low => '128',
        };
      case 'wy':
        return switch (quality) {
          SourceQualities.high => '320000',
          SourceQualities.medium => '192000',
          SourceQualities.low => '128000',
        };
      case 'mg':
        return switch (quality) {
          SourceQualities.high => 'flac',
          SourceQualities.medium => '320',
          SourceQualities.low => '128',
        };
      default:
        return '320';
    }
  }
}