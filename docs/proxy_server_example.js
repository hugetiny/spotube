// Example proxy server for Chinese music platforms
// This is a simple implementation to demonstrate the API structure
// For production use, consider using the lx-music-api-server project

const express = require('express');
const cors = require('cors');
const axios = require('axios');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

// Secret key for signature verification
const SECRET_KEY = 'your_secret_key'; // Change this in production

// Middleware
app.use(express.json());
app.use(cors());

// Verify request signature
function verifySignature(req, res, next) {
  const { timestamp, ...params } = req.body;
  const signature = req.headers['x-signature'];
  
  if (!timestamp || !signature) {
    return res.status(401).json({ error: 'Missing timestamp or signature' });
  }
  
  // Sort params alphabetically
  const sortedKeys = Object.keys(params).sort();
  const sortedParams = {};
  for (const key of sortedKeys) {
    sortedParams[key] = params[key];
  }
  
  // Create signature string
  const paramsString = Object.entries(sortedParams)
    .map(([key, value]) => `${key}=${value}`)
    .join('&');
  
  const signString = `${paramsString}&timestamp=${timestamp}`;
  
  // Generate HMAC-SHA256
  const hmac = crypto.createHmac('sha256', SECRET_KEY);
  hmac.update(signString);
  const calculatedSignature = hmac.digest('hex');
  
  if (calculatedSignature !== signature) {
    return res.status(401).json({ error: 'Invalid signature' });
  }
  
  next();
}

// Status endpoint (no auth required)
app.get('/status', (req, res) => {
  res.json({ status: 'ok' });
});

// Search endpoint
app.post('/search', verifySignature, async (req, res) => {
  try {
    const { platform, keyword, page = 1, limit = 10 } = req.body;
    
    // Implement platform-specific search logic
    let result;
    switch (platform) {
      case 'kw': // 酷我音乐
        result = await searchKuwo(keyword, page, limit);
        break;
      case 'kg': // 酷狗音乐
        result = await searchKugou(keyword, page, limit);
        break;
      case 'tx': // QQ音乐
        result = await searchQQ(keyword, page, limit);
        break;
      case 'wy': // 网易音乐
        result = await searchNetease(keyword, page, limit);
        break;
      case 'mg': // 咪咕音乐
        result = await searchMigu(keyword, page, limit);
        break;
      default:
        return res.status(400).json({ error: 'Unsupported platform' });
    }
    
    res.json(result);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Search failed', message: error.message });
  }
});

// URL endpoint
app.post('/url', verifySignature, async (req, res) => {
  try {
    const { platform, songId, quality } = req.body;
    
    // Implement platform-specific URL retrieval logic
    let result;
    switch (platform) {
      case 'kw': // 酷我音乐
        result = await getKuwoUrl(songId, quality);
        break;
      case 'kg': // 酷狗音乐
        result = await getKugouUrl(songId, quality);
        break;
      case 'tx': // QQ音乐
        result = await getQQUrl(songId, quality);
        break;
      case 'wy': // 网易音乐
        result = await getNeteaseUrl(songId, quality);
        break;
      case 'mg': // 咪咕音乐
        result = await getMiguUrl(songId, quality);
        break;
      default:
        return res.status(400).json({ error: 'Unsupported platform' });
    }
    
    res.json(result);
  } catch (error) {
    console.error('URL error:', error);
    res.status(500).json({ error: 'Failed to get URL', message: error.message });
  }
});

// Lyric endpoint
app.post('/lyric', verifySignature, async (req, res) => {
  try {
    const { platform, songId } = req.body;
    
    // Implement platform-specific lyric retrieval logic
    let result;
    switch (platform) {
      case 'kw': // 酷我音乐
        result = await getKuwoLyric(songId);
        break;
      case 'kg': // 酷狗音乐
        result = await getKugouLyric(songId);
        break;
      case 'tx': // QQ音乐
        result = await getQQLyric(songId);
        break;
      case 'wy': // 网易音乐
        result = await getNeteaseLyric(songId);
        break;
      case 'mg': // 咪咕音乐
        result = await getMiguLyric(songId);
        break;
      default:
        return res.status(400).json({ error: 'Unsupported platform' });
    }
    
    res.json(result);
  } catch (error) {
    console.error('Lyric error:', error);
    res.status(500).json({ error: 'Failed to get lyric', message: error.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Proxy server running on port ${PORT}`);
});

// ===== Platform-specific implementations =====
// These are placeholder functions. In a real implementation,
// you would need to implement the actual API calls to each platform.

// Kuwo (酷我音乐)
async function searchKuwo(keyword, page, limit) {
  // Implement Kuwo search API
  // This is a placeholder - you need to implement the actual API call
  return {
    list: [
      {
        songmid: 'example_id',
        name: 'Example Song',
        singer: 'Example Artist',
        duration: '180000',
        pic: 'https://example.com/image.jpg',
      }
    ],
    total: 1,
  };
}

async function getKuwoUrl(songId, quality) {
  // Implement Kuwo URL API
  return {
    url: 'https://example.com/song.mp3',
  };
}

async function getKuwoLyric(songId) {
  // Implement Kuwo lyric API
  return {
    lyric: '[00:00.00]Example lyrics',
  };
}

// Kugou (酷狗音乐)
async function searchKugou(keyword, page, limit) {
  // Implement Kugou search API
  return { list: [], total: 0 };
}

async function getKugouUrl(songId, quality) {
  // Implement Kugou URL API
  return { url: '' };
}

async function getKugouLyric(songId) {
  // Implement Kugou lyric API
  return { lyric: '' };
}

// QQ Music (QQ音乐)
async function searchQQ(keyword, page, limit) {
  // Implement QQ Music search API
  return { list: [], total: 0 };
}

async function getQQUrl(songId, quality) {
  // Implement QQ Music URL API
  return { url: '' };
}

async function getQQLyric(songId) {
  // Implement QQ Music lyric API
  return { lyric: '' };
}

// Netease (网易音乐)
async function searchNetease(keyword, page, limit) {
  // Implement Netease search API
  return { list: [], total: 0 };
}

async function getNeteaseUrl(songId, quality) {
  // Implement Netease URL API
  return { url: '' };
}

async function getNeteaseLyric(songId) {
  // Implement Netease lyric API
  return { lyric: '' };
}

// Migu (咪咕音乐)
async function searchMigu(keyword, page, limit) {
  // Implement Migu search API
  return { list: [], total: 0 };
}

async function getMiguUrl(songId, quality) {
  // Implement Migu URL API
  return { url: '' };
}

async function getMiguLyric(songId) {
  // Implement Migu lyric API
  return { lyric: '' };
}