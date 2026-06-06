// Qidian (起点中文网) SSR scraper.
// Uses m.qidian.com mobile SSR which embeds ranking data as JSON in pageContext.
// No browser needed — pure HTTP fetch + JSON extraction.
//
// Charts: 畅销榜, 月票榜, 新书榜, 阅读指数榜, 新人作者新书榜, 三江推荐.
// Pagination: fetches page 1-3 per chart for broader coverage.

const CHARTS = [
  { name: '畅销榜', path: '/rank/hotsales/' },
  { name: '月票榜', path: '/rank/yuepiao/' },
  { name: '新书榜', path: '/rank/newbook/' },
  { name: '阅读指数榜', path: '/rank/readindex/' },
  { name: '新人作者新书榜', path: '/rank/newauthor/' },
  { name: '三江推荐', path: '/sanjiang/' },
];

const PAGES_PER_CHART = 3;
const BASE_URL = 'https://m.qidian.com';
const UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) ' +
  'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

async function fetchPage(path, page) {
  const url = page > 1
    ? `${BASE_URL}${path}?page=${page}`
    : `${BASE_URL}${path}`;

  const resp = await fetch(url, {
    headers: { 'User-Agent': UA },
    signal: AbortSignal.timeout(15000),
  });

  if (!resp.ok) {
    throw new Error(`HTTP ${resp.status} for ${url}`);
  }

  return resp.text();
}

function extractPageContext(html) {
  // The SSR data lives in <script id="vite-plugin-ssr_pageContext" type="application/json">
  const match = html.match(
    /<script\s+id="vite-plugin-ssr_pageContext"[^>]*>([\s\S]*?)<\/script>/
  );
  if (!match) return null;

  try {
    const data = JSON.parse(match[1]);
    return data?.pageContext?.pageProps?.pageData?.records || [];
  } catch {
    return null;
  }
}

function parseWordCount(cntStr) {
  if (!cntStr) return 0;
  const m = cntStr.match(/([\d.]+)\s*万/);
  if (m) return Math.round(parseFloat(m[1]) * 10000);
  return parseInt(cntStr.replace(/[^\d]/g, ''), 10) || 0;
}

function recordToScrapedBook(record, chartName, rank) {
  return {
    platform: 'qidian',
    platformBookId: String(record.bid || ''),
    title: record.bName || '',
    author: record.bAuth || '',
    description: record.desc || '',
    categories: record.cat ? [record.cat] : [],
    tags: record.subCat ? [record.subCat] : [],
    totalWordCount: parseWordCount(record.cnt),
    status: 'ongoing',
    firstPublishDate: null,
    chartName,
    rank,
    favorites: null,
    recommendVotes: null,
    monthlyTickets: null,
    commentCount: null,
    scrapedAt: new Date().toISOString(),
  };
}

async function scrapeChart(chart) {
  const allItems = [];

  for (let page = 1; page <= PAGES_PER_CHART; page++) {
    try {
      const html = await fetchPage(chart.path, page);
      const records = extractPageContext(html);

      if (!records || records.length === 0) {
        if (page === 1) {
          process.stderr.write(
            `[qidian] No pageContext data for ${chart.name}\n`
          );
        }
        break; // no more pages
      }

      const baseRank = (page - 1) * 20;
      records.forEach((rec, i) => {
        if (rec.bName) {
          allItems.push(recordToScrapedBook(rec, chart.name, baseRank + i + 1));
        }
      });
    } catch (e) {
      process.stderr.write(
        `[qidian] Failed page ${page} for ${chart.name}: ${e.message}\n`
      );
      break;
    }
  }

  return allItems;
}

async function main() {
  const allItems = [];

  // Fetch all charts concurrently.
  const results = await Promise.allSettled(
    CHARTS.map((chart) => scrapeChart(chart))
  );

  for (const result of results) {
    if (result.status === 'fulfilled') {
      allItems.push(...result.value);
    }
  }

  // Basic quality check: each entry must have non-empty title and author.
  const valid = allItems.filter(
    (item) => item.title && item.author && item.title !== item.author
  );

  process.stdout.write(JSON.stringify(valid));
}

main().catch((e) => {
  process.stderr.write(`[qidian] Fatal: ${e.message}\n`);
  process.exit(1);
});
