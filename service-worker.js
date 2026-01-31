// Service Worker for Class Attendance Tracker PWA
// Version-based cache busting
const CACHE_VERSION = 'v1.1.0';
const CACHE_NAME = `attendance-tracker-${CACHE_VERSION}`;

// Assets to cache for offline use
const ASSETS_TO_CACHE = [
    './',
    './index.html',
    './manifest.json',
    './icons/icon-72.png',
    './icons/icon-96.png',
    './icons/icon-128.png',
    './icons/icon-144.png',
    './icons/icon-152.png',
    './icons/icon-192.png',
    './icons/icon-384.png',
    './icons/icon-512.png',
    // External CDN resources
    'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',
    'https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js',
    'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap'
];

// Install Event - Cache all assets
self.addEventListener('install', (event) => {
    console.log('[SW] Installing Service Worker...');

    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('[SW] Caching app shell and assets...');
                return cache.addAll(ASSETS_TO_CACHE);
            })
            .then(() => {
                console.log('[SW] All assets cached successfully');
                return self.skipWaiting(); // Activate immediately
            })
            .catch((error) => {
                console.error('[SW] Cache failed:', error);
            })
    );
});

// Activate Event - Clean up old caches
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating Service Worker...');

    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames
                        .filter((name) => name.startsWith('attendance-tracker-') && name !== CACHE_NAME)
                        .map((name) => {
                            console.log('[SW] Deleting old cache:', name);
                            return caches.delete(name);
                        })
                );
            })
            .then(() => {
                console.log('[SW] Service Worker activated');
                // Notify all clients about the update
                return self.clients.matchAll();
            })
            .then((clients) => {
                clients.forEach((client) => {
                    client.postMessage({
                        type: 'SW_UPDATED',
                        version: CACHE_VERSION
                    });
                });
                return self.clients.claim(); // Take control immediately
            })
    );
});

// Fetch Event - Cache-first strategy with network fallback
self.addEventListener('fetch', (event) => {
    const request = event.request;

    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }

    // Skip chrome-extension and other non-http(s) requests
    if (!request.url.startsWith('http')) {
        return;
    }

    event.respondWith(
        caches.match(request)
            .then((cachedResponse) => {
                if (cachedResponse) {
                    // Return cached version
                    // Also fetch from network to update cache in background
                    fetchAndCache(request);
                    return cachedResponse;
                }

                // Not in cache, fetch from network
                return fetchAndCache(request);
            })
            .catch(() => {
                // Offline and not in cache - return offline fallback for HTML
                if (request.headers.get('accept').includes('text/html')) {
                    return caches.match('./index.html');
                }
                return new Response('Offline', { status: 503 });
            })
    );
});

// Helper function to fetch and cache
function fetchAndCache(request) {
    return fetch(request)
        .then((networkResponse) => {
            // Check if valid response
            if (!networkResponse || networkResponse.status !== 200) {
                return networkResponse;
            }

            // Clone the response (can only be consumed once)
            const responseToCache = networkResponse.clone();

            // Cache the new response
            caches.open(CACHE_NAME)
                .then((cache) => {
                    cache.put(request, responseToCache);
                });

            return networkResponse;
        });
}

// Handle messages from main thread
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
});

console.log('[SW] Service Worker script loaded');
