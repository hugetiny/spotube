import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/sourced_track/sourced_track.dart';
import 'package:spotube/services/sourced_track/sources/chinese/base.dart';

class TXSourcedTrack extends ChineseSourcedTrack {
  TXSourcedTrack({
    required super.ref,
    required super.source,
    required super.siblings,
    required super.sourceInfo,
    required super.track,
  });

  static Future<TXSourcedTrack> fetchFromTrack({
    required Track track,
    required Ref ref,
  }) async {
    final searchTerm = SourcedTrack.getSearchTerm(track);
    
    final data = await ChineseSourcedTrack.searchMusic(
      platform: 'tx',
      keyword: searchTerm,
      ref: ref,
      limit: 10,
    );
    
    if (data['list'] == null || data['list'].isEmpty) {
      throw Exception('No results found for: $searchTerm');
    }
    
    final firstResult = data['list'][0];
    final songId = firstResult['songmid'];
    
    // Get music URL for different qualities
    final urlData = await ChineseSourcedTrack.getMusicUrl(
      platform: 'tx',
      songId: songId,
      quality: ChineseSourcedTrack.mapQuality(SourceQualities.high, 'tx'),
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
      title: firstResult['name'],
      author: firstResult['singer'].map((s) => s['name']).join(', '),
      duration: Duration(milliseconds: int.parse(firstResult['interval'] ?? '0') * 1000),
      thumbnails: [firstResult['albummid'] != null 
        ? 'https://y.gtimg.cn/music/photo_new/T002R300x300M000${firstResult['albummid']}.jpg' 
        : ''],
    );
    
    // Get siblings (alternative versions)
    final siblings = <SourceInfo>[];
    for (var i = 1; i < data['list'].length && i < 5; i++) {
      final item = data['list'][i];
      siblings.add(
        SourceInfo(
          id: item['songmid'],
          title: item['name'],
          author: item['singer'].map((s) => s['name']).join(', '),
          duration: Duration(milliseconds: int.parse(item['interval'] ?? '0') * 1000),
          thumbnails: [item['albummid'] != null 
            ? 'https://y.gtimg.cn/music/photo_new/T002R300x300M000${item['albummid']}.jpg' 
            : ''],
        ),
      );
    }
    
    return TXSourcedTrack(
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
      platform: 'tx',
      keyword: searchTerm,
      ref: ref,
      limit: 10,
    );
    if (data['list'] == null || data['list'].isEmpty) {
      return [];
    }
    
    final siblings = <SiblingType>[];
    
    for (var item in data['list']) {
      siblings.add((
        info: SourceInfo(
          id: item['songmid'],
          title: item['name'],
          author: item['singer'].map((s) => s['name']).join(', '),
          duration: Duration(milliseconds: int.parse(item['interval'] ?? '0') * 1000),
          thumbnails: [item['albummid'] != null 
            ? 'https://y.gtimg.cn/music/photo_new/T002R300x300M000${item['albummid']}.jpg' 
            : ''],
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
      platform: 'tx',
      songId: sibling.id,
      quality: ChineseSourcedTrack.mapQuality(SourceQualities.high, 'tx'),
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
    
    return TXSourcedTrack(
      ref: ref,
      source: sourceMap,
      siblings: newSiblings,
      sourceInfo: sibling,
      track: this,
    );
  }
}