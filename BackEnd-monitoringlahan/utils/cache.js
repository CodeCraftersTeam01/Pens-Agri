const NodeCache = require('node-cache');

// Inisialisasi Cache dengan TTL default 5 menit (300 detik), checkperiod 60 detik
const cache = new NodeCache({
    stdTTL: 300,
    checkperiod: 60,
    useClones: false
});

/**
 * Helper untuk mengambil data dari cache atau menjalankan query jika miss
 * @param {string} key - Cache Key unik
 * @param {Function} fetchFunction - Async function untuk query database
 * @param {number} [ttl] - Optional TTL khusus dalam detik
 */
async function getOrSet(key, fetchFunction, ttl = 300) {
    const cachedData = cache.get(key);
    if (cachedData !== undefined) {
        return cachedData;
    }

    const freshData = await fetchFunction();
    if (freshData !== undefined && freshData !== null) {
        cache.set(key, freshData, ttl);
    }
    return freshData;
}

/**
 * Hapus seluruh cache yang cocok dengan awalan prefix
 * @param {string} prefix - Awalan key (misal: 'lahan_', 'poktan_')
 */
function invalidatePrefix(prefix) {
    const keys = cache.keys();
    const matchingKeys = keys.filter(k => k.startsWith(prefix));
    if (matchingKeys.length > 0) {
        cache.del(matchingKeys);
    }
}

/**
 * Hapus cache spesifik
 * @param {string|string[]} keys
 */
function del(keys) {
    cache.del(keys);
}

/**
 * Kosongkan seluruh cache
 */
function flushAll() {
    cache.flushAll();
}

module.exports = {
    cache,
    getOrSet,
    invalidatePrefix,
    del,
    flushAll
};
