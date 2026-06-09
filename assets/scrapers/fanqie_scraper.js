// Fanqie (番茄小说) market scanner.
// Uses public HTTP endpoints only. Category rank lists can contain font-mapped
// text, so they are treated as ranking occurrences and book IDs; clean book
// details are fetched from /api/book/info before emitting ScrapedBook JSON.

const BASE_URL = 'https://fanqienovel.com';
const UA =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' +
  'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';

const RANK_MOLDS = [
  { mold: 2, label: '阅读榜' },
  { mold: 1, label: '新书榜' },
];

const RECOMMEND_TYPES = [0, 1, 2, 3];

const MAX_BOOKS_PER_CHART = readPositiveInt('FANQIE_MAX_BOOKS_PER_CHART', 20);
const MAX_CATEGORIES = readPositiveInt('FANQIE_MAX_CATEGORIES', 0);
const TOP_LIST_LIMIT = readPositiveInt('FANQIE_TOP_LIMIT', 200);
const RECOMMEND_LIMIT = readPositiveInt('FANQIE_RECOMMEND_LIMIT', 20);
const FETCH_CONCURRENCY = readPositiveInt('FANQIE_FETCH_CONCURRENCY', 6);
const DETAIL_CONCURRENCY = readPositiveInt('FANQIE_DETAIL_CONCURRENCY', 8);
const FETCH_TIMEOUT_MS = readPositiveInt('FANQIE_FETCH_TIMEOUT_MS', 15000);

function readPositiveInt(name, fallback) {
  const raw = process.env[name];
  if (!raw) return fallback;
  const value = Number.parseInt(raw, 10);
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

async function fetchJson(pathOrUrl, { retries = 2 } = {}) {
  const url = pathOrUrl.startsWith('http')
    ? pathOrUrl
    : `${BASE_URL}${pathOrUrl}`;
  let lastError;

  for (let attempt = 0; attempt <= retries; attempt += 1) {
    try {
      const resp = await fetch(url, {
        headers: {
          'User-Agent': UA,
          Accept: 'application/json,text/plain,*/*',
          Referer: `${BASE_URL}/`,
        },
        signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
      });
      if (!resp.ok) {
        throw new Error(`HTTP ${resp.status}`);
      }
      return await resp.json();
    } catch (error) {
      lastError = error;
      if (attempt < retries) {
        await sleep(350 * (attempt + 1));
      }
    }
  }

  throw new Error(`${lastError?.message || 'request failed'} for ${url}`);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function runLimited(items, concurrency, worker) {
  const results = new Array(items.length);
  let cursor = 0;

  async function runWorker() {
    while (cursor < items.length) {
      const index = cursor;
      cursor += 1;
      try {
        results[index] = { ok: true, value: await worker(items[index], index) };
      } catch (error) {
        results[index] = { ok: false, error };
      }
    }
  }

  const workerCount = Math.min(Math.max(concurrency, 1), items.length);
  await Promise.all(
    Array.from({ length: workerCount }, () => runWorker())
  );
  return results;
}

async function fetchCategories() {
  const json = await fetchJson(
    '/api/config/list?config_key=serial_rank_category_list_common'
  );
  const list = Array.isArray(json?.data?.list) ? json.data.list : [];
  const categories = [];

  for (const item of list) {
    const groups = Array.isArray(item.group) ? item.group : [];
    const id = stringValue(item.id);
    const name = stringValue(item.name);
    if (!id || !name) continue;

    if (groups.includes('male')) {
      categories.push({ id, name, gender: 1, genderLabel: '男频' });
    }
    if (groups.includes('female')) {
      categories.push({ id, name, gender: 0, genderLabel: '女频' });
    }
  }

  if (MAX_CATEGORIES > 0) {
    return categories.slice(0, MAX_CATEGORIES);
  }
  return categories;
}

async function fetchCategoryRank(category, rankMold) {
  const params = new URLSearchParams({
    app_id: '2503',
    rank_list_type: '3',
    offset: '0',
    limit: String(MAX_BOOKS_PER_CHART),
    category_id: category.id,
    rank_version: '',
    gender: String(category.gender),
    rankMold: String(rankMold.mold),
  });
  const chartName = `${category.genderLabel}${rankMold.label}-${category.name}`;

  try {
    const json = await fetchJson(`/api/rank/category/list?${params}`);
    const list = Array.isArray(json?.data?.book_list)
      ? json.data.book_list
      : [];
    return list
      .map((book, index) =>
        occurrenceFromItem(book, {
          chartName,
          rank: numberValue(book.currentPos) || index + 1,
          fallbackCategory: category.name,
        })
      )
      .filter(Boolean);
  } catch (error) {
    process.stderr.write(
      `[fanqie] Failed ${chartName}: ${error.message}\n`
    );
    return [];
  }
}

async function fetchTopList() {
  try {
    const json = await fetchJson(
      `/api/author/misc/top_book_list/v1/?limit=${TOP_LIST_LIMIT}&offset=0`
    );
    const list = Array.isArray(json?.book_list) ? json.book_list : [];
    return list
      .map((book, index) =>
        occurrenceFromItem(book, {
          chartName: '番茄巅峰榜',
          rank: index + 1,
          fallbackCategory: stringValue(book.category),
        })
      )
      .filter(Boolean);
  } catch (error) {
    process.stderr.write(`[fanqie] Failed 番茄巅峰榜: ${error.message}\n`);
    return [];
  }
}

async function fetchRecommendSlot(type) {
  const chartName = `首页推荐位-样本${type}`;
  try {
    const json = await fetchJson(
      `/api/rank/recommend/list?type=${type}&limit=${RECOMMEND_LIMIT}&offset=0`
    );
    const list = Array.isArray(json?.data?.list) ? json.data.list : [];
    return list
      .map((book, index) =>
        occurrenceFromItem(book, {
          chartName,
          rank: index + 1,
          fallbackCategory: stringValue(book.category),
        })
      )
      .filter(Boolean);
  } catch (error) {
    process.stderr.write(`[fanqie] Failed ${chartName}: ${error.message}\n`);
    return [];
  }
}

function occurrenceFromItem(item, { chartName, rank, fallbackCategory }) {
  const bookId = stringValue(item.bookId || item.book_id || item.media_id);
  if (!bookId) return null;

  return {
    bookId,
    chartName,
    rank,
    fallback: {
      title: stringValue(item.bookName || item.book_name),
      author: stringValue(item.author || item.authorName || item.author_name),
      description: stringValue(item.abstract || item.description),
      category: fallbackCategory || stringValue(item.category),
      totalWordCount: numberValue(item.wordNumber || item.word_number),
      creationStatus:
        item.creationStatus ?? item.creation_status ?? item.status ?? null,
    },
  };
}

async function fetchBookDetail(bookId) {
  const json = await fetchJson(`/api/book/info?bookId=${bookId}`);
  return json?.data || {};
}

function detailToScrapedBook(occurrence, detail, scrapedAt) {
  const fallback = occurrence.fallback;
  const categories = parseCategories(detail.categoryV2);
  if (categories.length === 0 && fallback.category) {
    categories.push(fallback.category);
  }

  const title = stringValue(detail.bookName || detail.book_name || fallback.title);
  const author = stringValue(
    detail.authorName || detail.author || detail.author_name || fallback.author
  );
  const description = stringValue(
    detail.abstract || detail.description || fallback.description
  );
  const totalWordCount =
    numberValue(detail.wordNumber || detail.word_number) ||
    fallback.totalWordCount ||
    0;
  const creationStatus =
    detail.creationStatus ?? detail.creation_status ?? fallback.creationStatus;

  return {
    platform: 'fanqie',
    platformBookId: occurrence.bookId,
    title,
    author,
    description,
    categories: uniqueNonEmpty(categories),
    tags: [],
    totalWordCount,
    status: isCompleted(creationStatus, detail) ? 'completed' : 'ongoing',
    firstPublishDate: null,
    chartName: occurrence.chartName,
    rank: occurrence.rank,
    favorites: null,
    recommendVotes: null,
    monthlyTickets: null,
    commentCount: null,
    scrapedAt,
  };
}

function parseCategories(raw) {
  if (!raw) return [];
  let value = raw;
  if (typeof raw === 'string') {
    try {
      value = JSON.parse(raw);
    } catch {
      return [raw];
    }
  }
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => stringValue(item?.Name || item?.name || item?.category))
    .filter(Boolean);
}

function isCompleted(creationStatus, detail) {
  const status = stringValue(creationStatus).toLowerCase();
  if (status === '0' || status === 'completed') return true;
  if (status === '1' || status === 'ongoing') return false;
  const lastChapter = stringValue(detail?.lastChapterTitle);
  return lastChapter.includes('完结') || lastChapter.includes('完本');
}

function uniqueNonEmpty(values) {
  const seen = new Set();
  const result = [];
  for (const value of values) {
    const cleaned = stringValue(value).trim();
    if (!cleaned || seen.has(cleaned)) continue;
    seen.add(cleaned);
    result.push(cleaned);
  }
  return result;
}

function stringValue(value) {
  if (value == null) return '';
  return String(value).trim();
}

function numberValue(value) {
  if (value == null || value === '') return 0;
  const parsed = Number.parseInt(String(value).replace(/[^\d]/g, ''), 10);
  return Number.isFinite(parsed) ? parsed : 0;
}

function dedupeOccurrences(occurrences) {
  const seen = new Set();
  const result = [];
  for (const occurrence of occurrences) {
    const key = `${occurrence.chartName}:${occurrence.bookId}`;
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(occurrence);
  }
  return result;
}

async function main() {
  const categories = await fetchCategories();
  process.stderr.write(`[fanqie] Categories: ${categories.length}\n`);

  const categoryTasks = [];
  for (const category of categories) {
    for (const rankMold of RANK_MOLDS) {
      categoryTasks.push({ category, rankMold });
    }
  }

  const categoryResults = await runLimited(
    categoryTasks,
    FETCH_CONCURRENCY,
    ({ category, rankMold }) => fetchCategoryRank(category, rankMold)
  );

  const occurrences = [];
  for (const result of categoryResults) {
    if (result.ok) occurrences.push(...result.value);
  }

  const extraResults = await Promise.allSettled([
    fetchTopList(),
    ...RECOMMEND_TYPES.map((type) => fetchRecommendSlot(type)),
  ]);
  for (const result of extraResults) {
    if (result.status === 'fulfilled') {
      occurrences.push(...result.value);
    }
  }

  const deduped = dedupeOccurrences(occurrences);
  const bookIds = [...new Set(deduped.map((item) => item.bookId))];
  process.stderr.write(
    `[fanqie] Ranking occurrences: ${deduped.length}, books: ${bookIds.length}\n`
  );

  const detailResults = await runLimited(
    bookIds,
    DETAIL_CONCURRENCY,
    fetchBookDetail
  );
  const detailById = new Map();
  for (let i = 0; i < bookIds.length; i += 1) {
    const result = detailResults[i];
    if (result?.ok) {
      detailById.set(bookIds[i], result.value);
    } else {
      process.stderr.write(
        `[fanqie] Failed detail ${bookIds[i]}: ${result?.error?.message || 'unknown'}\n`
      );
    }
  }

  const scrapedAt = new Date().toISOString();
  const output = deduped
    .map((occurrence) =>
      detailToScrapedBook(
        occurrence,
        detailById.get(occurrence.bookId) || {},
        scrapedAt
      )
    )
    .filter((item) => item.title && item.author && item.title !== item.author);

  process.stdout.write(JSON.stringify(output));
}

main().catch((error) => {
  process.stderr.write(`[fanqie] Fatal: ${error.message}\n`);
  process.exit(1);
});
