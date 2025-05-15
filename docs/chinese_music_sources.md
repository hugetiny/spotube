# Chinese Music Sources for Spotube

This document explains how to use Chinese music platforms as audio sources in Spotube, allowing users in mainland China to access music.

## Supported Platforms

Spotube now supports the following Chinese music platforms:

- 酷我音乐 (KW)
- 酷狗音乐 (KG)
- QQ音乐 (TX)
- 网易音乐 (WY)
- 咪咕音乐 (MG)

## Setup

### 1. Select a Chinese Music Platform

In Spotube settings, go to the "Playback" section and select one of the Chinese music platforms as your audio source.

### 2. Configure API Proxy (Optional)

For better performance and reliability, you can set up a proxy server that handles requests to Chinese music platforms. This is especially useful if you're experiencing connection issues.

1. In the settings, under the Chinese music platform section, click the edit button next to "音乐API代理"
2. Enter the URL of your proxy server
3. Click "Save"

## Setting Up Your Own Proxy Server

The Chinese music sources in Spotube require a proxy server to handle API requests to Chinese music platforms. You have two options:

### Option 1: Use lx-music-api-server (Recommended)

1. Clone the [lx-music-api-server](https://github.com/lyswhut/lx-music-api-server) repository
2. Follow the installation instructions in the repository
3. Configure the server to listen on a publicly accessible URL
4. Enter this URL in Spotube's settings

### Option 2: Create Your Own Proxy Server

We've provided a simple example implementation in `docs/proxy_server_example.js` that demonstrates the API structure required by Spotube. To use it:

1. Install Node.js if you don't have it already
2. Create a new directory for your proxy server
3. Copy the example file and install dependencies:
   ```bash
   npm init -y
   npm install express cors axios crypto
   node proxy_server_example.js
   ```
4. Modify the placeholder functions to implement the actual API calls to Chinese music platforms
5. Deploy the server to a publicly accessible URL
6. Enter this URL in Spotube's settings

The example server implements the following endpoints:
- `GET /status` - Check if the server is running
- `POST /search` - Search for music on a specific platform
- `POST /url` - Get the streaming URL for a song
- `POST /lyric` - Get lyrics for a song

## How It Works

When you play a track in Spotube with a Chinese music source selected:

1. Spotube searches for the track on the selected Chinese music platform
2. It retrieves the audio URL and metadata from the platform
3. The audio is streamed directly from the Chinese platform's servers

This allows users in mainland China to access music without requiring a VPN or other circumvention tools.

## Troubleshooting

If you encounter issues:

1. Make sure your proxy server is correctly configured and accessible
2. Try a different Chinese music platform as some may have better availability for certain tracks
3. Check your internet connection to ensure it can access Chinese websites

## Credits

This feature was inspired by and adapted from the [lx-music-desktop](https://github.com/lyswhut/lx-music-desktop) project.