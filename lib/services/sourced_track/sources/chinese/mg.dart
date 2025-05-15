import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/sourced_track/sourced_track.dart';
import 'package:spotube/services/sourced_track/sources/chinese/base.dart';

class MGSourcedTrack extends ChineseSourcedTrack {
  MGSourcedTrack({
    required super.ref,
    required super.source,
    required super.siblings,
    required super.sourceInfo,
    required super.track,
  });

  static Future<MGSourcedTrack> fetchFromTrack({
    required Track track,
    required Ref ref,
  }) async {
    final searchTerm = SourcedTrack.getSearchTerm(track);
    
    final data = await ChineseSourcedTrack.searchMusic(
      platform: 'mg',
      keyword: searchTerm,
      ref: ref,
      limit: 10,
    );
    
    if (data['musics'] == null || data['musics'].isEmpty) {
      throw Exception('No results found for: $searchTerm');
    }
    
    final firstResult = data['musics'][0];
    final songId = firstResult['copyrightId'];
    
    // Get music URL for different qualities
    final urlData = await ChineseSourcedTrack.getMusicUrl(
      platform: 'mg',
      songId: songId,
      quality: ChineseSourcedTrack.mapQuality(SourceQualities.high, 'mg'),
      ref: ref,
    );
    
    // Create source map with available qualities
    final sourceMap = SourceMap({
      SourceCodecs.m4a: {
        SourceQualities.high: urlData['url'],
        SourceQualities.medium: urlData['url'],
        SourceQualities.low: urlData['url'],
      },
      SourceCodecs.weba: {
        SourceQualities.high: urlData['url'],
        SourceQualities.medium: urlData['url'],
        SourceQualities.low: urlData['url'],
      },
    });
    
    // Create source info
    final sourceInfo = SourceInfo(
      id: songId,
      title: firstResult['songName'],
      author: firstResult['singerName'],
      duration: Duration(seconds: int.parse(firstResult['length'] ?? '0')),
      thumbnails: [firstResult['cover'] ?? ''],
    );
    
    // Get siblings (alternative versions)
    final siblings = <SourceInfo>[];
    for (var i = 1; i < data['musics'].length && i < 5; i++) {
      final item = data['musics'][i];
      siblings.add(
        SourceInfo(
          id: item['copyrightId'],
          title: item['songName'],
          author: item['singerName'],
          duration: Duration(seconds: int.parse(item['length'] ?? '0')),
          thumbnails: [item['cover'] ?? ''],
        ),
      );
    }
    
    return MGSourcedTrack(
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
      platform: 'mg',
      keyword: searchTerm,
      ref: ref,
      limit: 10,
    );
    if (data['musics'] == null || data['musics'].isEmpty) {
      return [];
    }
    
    final siblings = <SiblingType>[];
    
    for (var item in data['musics']) {
      siblings.add((
        info: SourceInfo(
          id: item['copyrightId'],
          title: item['songName'],
          author: item['singerName'],
          duration: Duration(seconds: int.parse(item['length'] ?? '0')),
          thumbnails: [item['cover'] ?? ''],
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
      platform: 'mg',
      songId: sibling.id,
      quality: ChineseSourcedTrack.mapQuality(SourceQualities.high, 'mg'),
      ref: ref,
    );
    
    // Create source map with available qualities
    final sourceMap = SourceMap({
      SourceCodecs.m4a: {
        SourceQualities.high: urlData['url'],
        SourceQualities.medium: urlData['url'],
        SourceQualities.low: urlData['url'],
      },
      SourceCodecs.weba: {
        SourceQualities.high: urlData['url'],
        SourceQualities.medium: urlData['url'],
        SourceQualities.low: urlData['url'],
      },
    });
    
    // Create new siblings list without the current sibling
    final newSiblings = [...siblings];
    newSiblings.add(sourceInfo);
    newSiblings.removeWhere((s) => s.id == sibling.id);
    
    return MGSourcedTrack(
      ref: ref,
      source: sourceMap,
      siblings: newSiblings,
      sourceInfo: sibling,
      track: this,
    );
  }
}