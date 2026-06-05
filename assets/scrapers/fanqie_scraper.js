// Fanqie (番茄小说) core chart scraper.
// Scrapes: 热门榜 (popular), 新书榜 (new books), 完结榜 (completed).
// Output: JSON array to stdout.

const puppeteer = require('puppeteer');

const CHARTS = [
  { name: '热门榜', url: 'https://fanqienovel.com/rank/hot_all' },
  { name: '新书榜', url: 'https://fanqienovel.com/rank/new_hot' },
  { name: '完结榜', url: 'https://fanqienovel.com/rank/finish_hot' },
];

async function scrapeChart(browser, chart) {
  const page = await browser.newPage();
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' +
    'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
  );

  try {
    await page.goto(chart.url, { waitUntil: 'networkidle2', timeout: 30000 });
    // Fanqie uses SPA rendering — wait for the book list container.
    await page.waitForSelector(
      '[class*="rank"], [class*="book-list"], [class*="BookList"]',
      { timeout: 15000 }
    );
    // Allow extra time for dynamic content.
    await new Promise((r) => setTimeout(r, 2000));

    const items = await page.evaluate((chartName) => {
      const results = [];
      const bookElements = document.querySelectorAll(
        '[class*="rank-item"], [class*="book-item"], [class*="BookItem"], a[href*="/page/book/"]'
      );

      bookElements.forEach((el, index) => {
        try {
          const linkEl = el.tagName === 'A' ? el : el.querySelector('a[href*="/page/book/"]');
          const titleEl = el.querySelector('[class*="title"], [class*="name"], h3, h4') || linkEl;
          const authorEl = el.querySelector('[class*="author"], [class*="writer"]');
          const categoryEl = el.querySelector('[class*="category"], [class*="tag"], [class*="genre"]');
          const wordCountEl = el.querySelector('[class*="word"], [class*="count"]');

          const title = titleEl?.textContent?.trim() || '';
          const href = linkEl?.getAttribute('href') || '';
          const author = authorEl?.textContent?.trim() || '';
          const category = categoryEl?.textContent?.trim() || '';

          // Extract book ID from Fanqie URL pattern: /page/book/<id>
          const idMatch = href.match(/\/page\/book\/(\d+)/);
          const platformBookId = idMatch ? idMatch[1] : String(index);

          let totalWordCount = 0;
          const wcText = wordCountEl?.textContent?.trim() || '';
          const wcMatch = wcText.match(/([\d.]+)\s*万/);
          if (wcMatch) {
            totalWordCount = Math.round(parseFloat(wcMatch[1]) * 10000);
          }

          if (!title) return;

          results.push({
            platform: 'fanqie',
            platformBookId,
            title,
            author,
            description: '',
            categories: category ? [category] : [],
            tags: [],
            totalWordCount,
            status: chartName === '完结榜' ? 'completed' : 'ongoing',
            firstPublishDate: null,
            chartName,
            rank: index + 1,
            favorites: null,
            recommendVotes: null,
            monthlyTickets: null,
            commentCount: null,
            scrapedAt: new Date().toISOString(),
          });
        } catch (e) {
          // Skip malformed entries.
        }
      });

      return results;
    }, chart.name);

    return items;
  } finally {
    await page.close();
  }
}

async function main() {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const allItems = [];
    for (const chart of CHARTS) {
      try {
        const items = await scrapeChart(browser, chart);
        allItems.push(...items);
      } catch (e) {
        process.stderr.write(`[fanqie] Failed to scrape ${chart.name}: ${e.message}\n`);
      }
    }
    process.stdout.write(JSON.stringify(allItems));
  } finally {
    await browser.close();
  }
}

main().catch((e) => {
  process.stderr.write(`[fanqie] Fatal: ${e.message}\n`);
  process.exit(1);
});
