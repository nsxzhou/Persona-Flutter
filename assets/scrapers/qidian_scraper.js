// Qidian (起点中文网) core chart scraper.
// Scrapes: 热销榜 (bestseller), 新书榜 (new books), 推荐榜 (recommendations).
// Output: JSON array to stdout.

const puppeteer = require('puppeteer');

const CHARTS = [
  { name: '热销榜', url: 'https://www.qidian.com/rank/hotsales/' },
  { name: '新书榜', url: 'https://www.qidian.com/rank/newbook/' },
  { name: '推荐榜', url: 'https://www.qidian.com/rank/recom/' },
];

async function scrapeChart(browser, chart) {
  const page = await browser.newPage();
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' +
    'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
  );

  try {
    await page.goto(chart.url, { waitUntil: 'networkidle2', timeout: 30000 });
    await page.waitForSelector('.rank-list, .book-img-text, .book-mid-info', {
      timeout: 15000,
    });

    const items = await page.evaluate((chartName) => {
      const results = [];
      const bookElements = document.querySelectorAll(
        '.book-img-text li, .rank-list .book-mid-info, .book-rank-item'
      );

      bookElements.forEach((el, index) => {
        try {
          const titleEl = el.querySelector('h4 a, .name a, .book-title a');
          const authorEl = el.querySelector('.author a, .book-author a, p.author');
          const wordCountEl = el.querySelector('.word-count, .update span, .count');
          const categoryEl = el.querySelector('.category, .genre, .type a');
          const descEl = el.querySelector('.intro, .book-desc, p.intro');

          const title = titleEl?.textContent?.trim() || '';
          const href = titleEl?.getAttribute('href') || '';
          const author = authorEl?.textContent?.trim() || '';
          const wordCountText = wordCountEl?.textContent?.trim() || '0';
          const category = categoryEl?.textContent?.trim() || '';
          const description = descEl?.textContent?.trim() || '';

          // Extract book ID from URL (e.g., /book/1037890254/)
          const idMatch = href.match(/\/(\d{6,})/);
          const platformBookId = idMatch ? idMatch[1] : String(index);

          // Parse word count (handles "123.45万字" format)
          let totalWordCount = 0;
          const wcMatch = wordCountText.match(/([\d.]+)\s*万/);
          if (wcMatch) {
            totalWordCount = Math.round(parseFloat(wcMatch[1]) * 10000);
          } else {
            totalWordCount = parseInt(wordCountText.replace(/[^\d]/g, ''), 10) || 0;
          }

          results.push({
            platform: 'qidian',
            platformBookId,
            title,
            author,
            description,
            categories: category ? [category] : [],
            tags: [],
            totalWordCount,
            status: 'ongoing',
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
        process.stderr.write(`[qidian] Failed to scrape ${chart.name}: ${e.message}\n`);
      }
    }
    process.stdout.write(JSON.stringify(allItems));
  } finally {
    await browser.close();
  }
}

main().catch((e) => {
  process.stderr.write(`[qidian] Fatal: ${e.message}\n`);
  process.exit(1);
});
