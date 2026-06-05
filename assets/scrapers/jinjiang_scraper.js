// Jinjiang (晋江文学城) core chart scraper.
// Scrapes: 月榜 (monthly), 季榜 (quarterly), 半年榜 (half-year).
// Output: JSON array to stdout.

const puppeteer = require('puppeteer');

const CHARTS = [
  { name: '月榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=2' },
  { name: '季榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=3' },
  { name: '半年榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=4' },
];

async function scrapeChart(browser, chart) {
  const page = await browser.newPage();
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' +
    'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
  );

  try {
    await page.goto(chart.url, { waitUntil: 'domcontentloaded', timeout: 30000 });
    // Jinjiang uses server-side rendering, so DOM is available immediately.
    // Wait for the table to be present.
    await page.waitForSelector('table, .bookbase, td[id]', { timeout: 10000 });

    const items = await page.evaluate((chartName) => {
      const results = [];
      // Jinjiang uses table-based layout.
      const rows = document.querySelectorAll(
        'table tr, .bookbase tr, #bookbase tr'
      );

      let rank = 0;
      rows.forEach((row) => {
        try {
          const cells = row.querySelectorAll('td');
          if (cells.length < 3) return;

          const titleLink = row.querySelector('td a[href*="onebook.php"]');
          if (!titleLink) return;

          rank++;
          const title = titleLink.textContent?.trim() || '';
          const href = titleLink.getAttribute('href') || '';

          // Extract book ID from Jinjiang URL: onebook.php?novelid=XXXXX
          const idMatch = href.match(/novelid=(\d+)/);
          const platformBookId = idMatch ? idMatch[1] : String(rank);

          const author = cells.length > 1 ? cells[1]?.textContent?.trim() || '' : '';
          const wordCountText = cells.length > 2 ? cells[2]?.textContent?.trim() || '0' : '0';
          const categoryText = cells.length > 3 ? cells[3]?.textContent?.trim() || '' : '';
          const statusText = cells.length > 4 ? cells[4]?.textContent?.trim() || '' : '';

          let totalWordCount = 0;
          const wcMatch = wordCountText.match(/([\d.]+)\s*[万千Kk]/);
          if (wcMatch) {
            const num = parseFloat(wcMatch[1]);
            totalWordCount = wordCountText.includes('万')
              ? Math.round(num * 10000)
              : Math.round(num * 1000);
          } else {
            totalWordCount = parseInt(wordCountText.replace(/[^\d]/g, ''), 10) || 0;
          }

          const isCompleted = statusText.includes('完结') || statusText.includes('完成');

          results.push({
            platform: 'jinjiang',
            platformBookId,
            title,
            author,
            description: '',
            categories: categoryText ? categoryText.split(/[/-]/).map(s => s.trim()).filter(Boolean) : [],
            tags: [],
            totalWordCount,
            status: isCompleted ? 'completed' : 'ongoing',
            firstPublishDate: null,
            chartName,
            rank,
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
        process.stderr.write(`[jinjiang] Failed to scrape ${chart.name}: ${e.message}\n`);
      }
    }
    process.stdout.write(JSON.stringify(allItems));
  } finally {
    await browser.close();
  }
}

main().catch((e) => {
  process.stderr.write(`[jinjiang] Fatal: ${e.message}\n`);
  process.exit(1);
});
