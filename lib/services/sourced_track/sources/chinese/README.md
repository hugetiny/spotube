# Chinese Music Sources for Spotube

This directory contains the implementation of Chinese music platforms as audio sources for Spotube.

## Supported Platforms

- `kw.dart` - 酷我音乐 (Kuwo Music)
- `kg.dart` - 酷狗音乐 (Kugou Music)
- `tx.dart` - QQ音乐 (QQ Music)
- `wy.dart` - 网易音乐 (NetEase Music)
- `mg.dart` - 咪咕音乐 (Migu Music)

## Architecture

- `base.dart` - Base class for all Chinese music sources with common methods
- `index.dart` - Exports all Chinese music sources

## How It Works

1. Each platform implementation extends the `ChineseSourcedTrack` class from `base.dart`
2. The `ChineseSourcedTrack` class provides common methods for searching music, getting URLs, and lyrics
3. Each platform implementation provides platform-specific implementations of these methods
4. All API requests are proxied through a server configured by the user

## API Proxy

The Chinese music sources require a proxy server to handle API requests to Chinese music platforms. This is configured in the `ChineseMusicProxy` class.

See the documentation in `/docs/chinese_music_sources.md` for more information on setting up a proxy server.

## Credits

This implementation was inspired by and adapted from the [lx-music-desktop](https://github.com/lyswhut/lx-music-desktop) project.