import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/sourced_track/sourced_track.dart';
import 'package:spotube/services/sourced_track/sources/chinese/base.dart';

class WYSourcedTrack extends ChineseSourcedTrack {
  WYSourcedTrack({
    required super.ref,
    required super.source,
    required super.siblings,
    required super.sourceInfo,
    required super.track,
  });

  static Future<WYSourcedTrack> fetchFromTrack({
    required Track track,
    required Ref ref,
  }) async {
    final searchTerm = SourcedTrack.getSearchTerm(track);
    
    final data = await ChineseSourcedTrack.searchMusic(
      platform: 'wy',
      keyword: searchTerm,
      ref: ref,
      limit: 10,
    );
    
    if (data['result'] == null || data['result']['songs'] == null || data['result']['songs'].isEmpty) {
      throw Exception('No results found for: $searchTerm');
    }
    
    final firstResult = data['result']['songs'][0];
    final songId = firstResult['id'].toString();
    
    // Get music URL for different qualities
    final urlData = await ChineseSourcedTrack.getMusicUrl(
      platform: 'wy',
      songId: songId,
      quality: ChineseSourcedTrack.mapQuality(SourceQualities.high, 'wy'),
      ref: ref,
    );
    
    // Create source map with available qualities
    final sourceMap = SourceMap({
      SourceCodecs.m4a: {
        SourceQualities.high: urlData['data'][0]['url'],
        SourceQualities.medium: urlData['data'][0]['url'],
        SourceQualities.low: urlData['data'][0]['url'],
      },
      SourceCodecs.weba: {
        SourceQualities.high: urlData['data'][0]['url'],
        SourceQualities.medium: urlData['data'][0]['url'],
        SourceQualities.low: urlData['data'][0]['url'],
      },
    });
    
    // Create source info
    final sourceInfo = SourceInfo(
      id: songId,
      title: firstResult['name'],
      author: firstResult['artists'].map((a) => a['name']).join(', '),
      duration: Duration(milliseconds: firstResult['duration']),
      thumbnails: [firstResult['album']['picUrl'] ?? ''],
    );
    
    // Get siblings (alternative versions)
    final siblings = <SourceInfo>[];
    for (var i = 1; i < data['result']['songs'].length && i < 5; i++) {
      final item = data['result']['songs'][i];
      siblings.add(
        SourceInfo(
          id: item['id'].toString(),
          title: item['name'],
          author: item['artists'].map((a) => a['name']).join(', '),
          duration: Duration(milliseconds: item['duration']),
          thumbnails: [item['album']['picUrl'] ?? ''],
        ),
      );
    }
    
    return WYSourcedTrack(
      ref: ref,
      source: sourceMap,
      siblings: siblings,
      sourceInfo: sourceInfo,
      track: track,
    );
  }

  static Future<List<SiblingType>> fetchSiblings({
    required Track track,
    required Ref ref,
  }) async {
    final searchTerm = SourcedTrack.getSearchTerm(track);
    
    final data = await ChineseSourcedTrack.searchMusic(
      platform: 'wy',
      keyword: searchTerm,
      ref: ref,
      limit: 10,
    );
    if (data['result'] == null || data['result']['songs'] == null || data['result']['songs'].isEmpty) {
      return [];
    }
    
    final siblings = <SiblingType>[];
    
    for (var item in data['result']['songs']) {
      siblings.add((
        info: SourceInfo(
          id: item['id'].toString(),
          title: item['name'],
          author: item['artists'].map((a) => a['name']).join(', '),
          duration: Duration(milliseconds: item['duration']),
          thumbnails: [item['album']['picUrl'] ?? ''],
        ),
        source: null,
      ));
    }
    
    return siblings;
  }

  @override
  Future<SourcedTrack> copyWithSibling() async {
    return this;
  }

  @override
  Future<SourcedTrack?> swapWithSibling(SourceInfo sibling) async {
    // Get music URL for the sibling
    final urlData = await ChineseSourcedTrack.getMusicUrl(
      platform: 'wy',
      songId: sibling.id,
      quality: ChineseSourcedTrack.mapQuality(SourceQualities.high, 'wy'),
      ref: ref,
    );
    
    // Create source map with available qualities
    final sourceMap = SourceMap({
      SourceCodecs.m4a: {
        SourceQualities.high: urlData['data'][0]['url'],
        SourceQualities.medium: urlData['data'][0]['url'],
        SourceQualities.low: urlData['data'][0]['url'],
      },
      SourceCodecs.weba: {
        SourceQualities.high: urlData['data'][0]['url'],
        SourceQualities.medium: urlData['data'][0]['url'],
        SourceQualities.low: urlData['data'][0]['url'],
      },
    });
    
    // Create new siblings list without the current sibling
    final newSiblings = [...siblings];
    newSiblings.add(sourceInfo);
    newSiblings.removeWhere((s) => s.id == sibling.id);
    
    return WYSourcedTrack(
      ref: ref,
      source: sourceMap,
      siblings: newSiblings,
      sourceInfo: sibling,
      track: this,
    );
  }
}