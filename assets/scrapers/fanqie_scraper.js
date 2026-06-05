// Fanqie (番茄小说) scraper via CDP.
// Rank pages use font anti-scraping, so we extract book IDs from rank page
// links then visit detail pages for clean data (system fonts, no encoding).
//
// Detail page selectors:
//   title:    .info-name > h1
//   status:   .info-label-yellow
//   cats:     .info-label-grey (multiple)
//   wordCnt:  .info-count-word
//   author:   .author-name-text
//   desc:     text after .page-abstract-header

const { connectCdp, sleep } = require('./cdp-helper');

// One representative category per chart.
// Each chart has many sub-categories; we pick the first/top one.
const CHARTS = [
  { name: '男频阅读榜', url: 'https://fanqienovel.com/rank/1_2_1141' },
  { name: '男频新书榜', url: 'https://fanqienovel.com/rank/1_1_1141' },
  { name: '女频阅读榜', url: 'https://fanqienovel.com/rank/0_2_1139' },
  { name: '女频新书榜', url: 'https://fanqienovel.com/rank/0_1_1139' },
];

const MAX_BOOKS_PER_CHART = 20;
const DETAIL_CONCURRENCY = 3;

async function extractBookIds(browser, chart) {
  const page = await browser.newPage();
  try {
    await page.goto(chart.url, { waitUntil: 'networkidle2', timeout: 30000 });
    await sleep(5000);

    const bookIds = await page.evaluate(() => {
      const ids = new Set();
      document.querySelectorAll('a[href*="/page/"]').forEach((a) => {
        const m = a.getAttribute('href')?.match(/\/page\/(\d{10,})/);
        if (m) ids.add(m[1]);
      });
      return [...ids];
    });

    process.stderr.write(
      `[fanqie] ${chart.name}: found ${bookIds.length} book IDs\n`
    );
    return bookIds.slice(0, MAX_BOOKS_PER_CHART);
  } finally {
    await page.close();
  }
}

async function fetchBookDetail(browser, bookId) {
  const page = await browser.newPage();
  try {
    await page.goto(`https://fanqienovel.com/page/${bookId}`, {
      waitUntil: 'networkidle2',
      timeout: 20000,
    });
    await sleep(1500);

    const data = await page.evaluate(() => {
      const title =
        document.querySelector('.info-name h1')?.textContent?.trim() ||
        document.querySelector('h1')?.textContent?.trim() ||
        '';

      // Fallback: parse from <title> tag.
      let backupTitle = '';
      if (!title) {
        const m = document.title?.match(/^(.+?)(?:完整版|小说|_)/);
        backupTitle = m ? m[1] : '';
      }

      // Status: .info-label-yellow
      const statusEl = document.querySelector('.info-label-yellow');
      const statusText = statusEl?.textContent?.trim() || '';
      const bookStatus =
        statusText.includes('完结') ? 'completed' : 'ongoing';

      // Categories: .info-label-grey (multiple spans)
      const categories = [
        ...document.querySelectorAll('.info-label-grey'),
      ]
        .map((el) => el.textContent?.trim())
        .filter(Boolean);

      // Word count: .info-count-word or parse from body
      let totalWordCount = 0;
      const wcEl = document.querySelector('.info-count-word');
      if (wcEl) {
        const m = wcEl.textContent?.match(/([\d.]+)\s*万/);
        if (m) totalWordCount = Math.round(parseFloat(m[1]) * 10000);
      }

      // Author: .author-name-text
      const author =
        document.querySelector('.author-name-text')?.textContent?.trim() || '';

      // Description: first paragraph after .page-abstract-header
      let description = '';
      const abstractHeader = document.querySelector(
        '.page-abstract-header'
      );
      if (abstractHeader) {
        const next = abstractHeader.nextElementSibling;
        if (next) {
          description = next.textContent?.trim()?.slice(0, 200) || '';
        }
      }

      return {
        title: title || backupTitle,
        author,
        categories,
        status: bookStatus,
        totalWordCount,
        description,
      };
    });

    if (!data.title) return null;

    return {
      platform: 'fanqie',
      platformBookId: bookId,
      title: data.title,
      author: data.author,
      description: data.description,
      categories: data.categories,
      tags: [],
      totalWordCount: data.totalWordCount,
      status: data.status,
      firstPublishDate: null,
      favorites: null,
      recommendVotes: null,
      monthlyTickets: null,
      commentCount: null,
      scrapedAt: new Date().toISOString(),
    };
  } finally {
    await page.close();
  }
}

async function scrapeChart(browser, chart) {
  const bookIds = await extractBookIds(browser, chart);
  if (bookIds.length === 0) return [];

  const items = [];
  for (let i = 0; i < bookIds.length; i += DETAIL_CONCURRENCY) {
    const batch = bookIds.slice(i, i + DETAIL_CONCURRENCY);
    const results = await Promise.allSettled(
      batch.map((id) => fetchBookDetail(browser, id))
    );

    results.forEach((r, j) => {
      if (r.status === 'fulfilled' && r.value) {
        items.push({ ...r.value, chartName: chart.name, rank: i + j + 1 });
      } else if (r.status === 'rejected') {
        process.stderr.write(
          `[fanqie] Detail failed ${batch[j]}: ${r.reason?.message}\n`
        );
      }
    });

    if (i + DETAIL_CONCURRENCY < bookIds.length) await sleep(500);
  }

  process.stderr.write(
    `[fanqie] ${chart.name}: ${items.length} books with clean data\n`
  );
  return items;
}

async function main() {
  const browser = await connectCdp();
  const allItems = [];

  try {
    for (const chart of CHARTS) {
      try {
        const items = await scrapeChart(browser, chart);
        allItems.push(...items);
      } catch (e) {
        process.stderr.write(`[fanqie] ${chart.name} failed: ${e.message}\n`);
      }
    }

    const valid = allItems.filter(
      (item) =>
        item.title &&
        item.platformBookId &&
        item.platformBookId !== '0' &&
        item.title.length >= 2
    );

    process.stderr.write(
      `[fanqie] Total: ${valid.length} valid / ${allItems.length} raw\n`
    );
    process.stdout.write(JSON.stringify(valid));
  } finally {
    // disconnect() keeps Chrome alive; close() would kill it.
    await browser.disconnect();
  }
}

main().catch((e) => {
  process.stderr.write(`[fanqie] Fatal: ${e.message}\n`);
  process.exit(1);
});
