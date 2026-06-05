// Jinjiang (晋江文学城) SSR scraper.
// Uses bookbase.php which returns server-rendered HTML in GBK encoding.
// No browser needed — pure HTTP fetch + HTML parsing.
//
// Table structure per book row (7 cells):
//   Cell 0: Author (link to oneauthor.php)
//   Cell 1: Title (link to onebook.php?novelid=XXXXX)
//   Cell 2: Categories (e.g. "原创-纯爱-架空历史-爱情-主受")
//   Cell 3: Status ("完结" or "连载")
//   Cell 4: Collection count (integer)
//   Cell 5: Score/points (large integer)
//   Cell 6: First publish date

const CHARTS = [
  { name: '月榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=2' },
  { name: '季榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=3' },
  { name: '半年榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=4' },
  { name: '年榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=5' },
  { name: '总榜', url: 'https://www.jjwxc.net/bookbase.php?fw0=0&t=0&b=0&s=0&w=0&yc=0&sd=0&orderstr=1' },
];

const UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' +
  'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';

// Decode GBK buffer to UTF-8 string using Node.js TextDecoder.
function decodeGbk(buffer) {
  const decoder = new TextDecoder('gbk');
  return decoder.decode(buffer);
}

async function fetchPage(url) {
  const resp = await fetch(url, {
    headers: {
      'User-Agent': UA,
      'Accept-Encoding': 'gzip, deflate',
    },
    signal: AbortSignal.timeout(20000),
  });

  if (!resp.ok) {
    throw new Error(`HTTP ${resp.status} for ${url}`);
  }

  const buffer = await resp.arrayBuffer();
  return decodeGbk(Buffer.from(buffer));
}

function extractBookRows(html) {
  // Match <tr> elements that contain onebook.php links.
  const rowRegex = /<tr[^>]*>([\s\S]*?onebook\.php[\s\S]*?)<\/tr>/gi;
  const cellRegex = /<td[^>]*>([\s\S]*?)<\/td>/gi;
  const linkRegex = /href=["'](.*?)["']/i;
  const novelIdRegex = /novelid=(\d+)/i;
  const authorIdRegex = /authorid=(\d+)/i;
  const tagStripRegex = /<[^>]+>/g;

  const items = [];
  let rowMatch;

  while ((rowMatch = rowRegex.exec(html)) !== null) {
    const rowHtml = rowMatch[1];
    const cells = [];
    let cellMatch;

    // Reset cell regex for each row.
    cellRegex.lastIndex = 0;
    while ((cellMatch = cellRegex.exec(rowHtml)) !== null) {
      cells.push(cellMatch[1]);
    }

    if (cells.length < 5) continue;

    // Cell 0: Author.
    const authorClean = cells[0].replace(tagStripRegex, '').trim();
    const authorLinkMatch = cells[0].match(linkRegex);

    // Cell 1: Title + book ID.
    const titleClean = cells[1].replace(tagStripRegex, '').trim();
    const titleLinkMatch = cells[1].match(linkRegex);
    const novelIdMatch = titleLinkMatch
      ? novelIdRegex.exec(titleLinkMatch[1])
      : null;
    const bookId = novelIdMatch ? novelIdMatch[1] : '';

    // Cell 2: Categories (dash-separated).
    const catRaw = cells[2].replace(tagStripRegex, '').trim();
    const categories = catRaw.split('-').map((s) => s.trim()).filter(Boolean);

    // Cell 3: Status.
    const statusText = cells[3].replace(tagStripRegex, '').trim();
    const isCompleted = statusText.includes('完结');

    // Cell 4: Collection count.
    const collections = parseInt(
      cells[4].replace(tagStripRegex, '').trim().replace(/[^\d]/g, ''),
      10
    ) || 0;

    // Cell 5: Score/points.
    const score = parseInt(
      cells[5]?.replace(tagStripRegex, '').trim().replace(/[^\d]/g, '') || '0',
      10
    ) || 0;

    // Cell 6: Date.
    const dateStr = cells[6]?.replace(tagStripRegex, '').trim() || null;

    if (!titleClean || !bookId) continue;

    items.push({
      author: authorClean,
      title: titleClean,
      bookId,
      categories,
      status: isCompleted ? 'completed' : 'ongoing',
      collections,
      score,
      date: dateStr,
    });
  }

  return items;
}

async function scrapeChart(chart) {
  try {
    const html = await fetchPage(chart.url);
    const rawItems = extractBookRows(html);

    return rawItems.map((item, i) => ({
      platform: 'jinjiang',
      platformBookId: item.bookId,
      title: item.title,
      author: item.author,
      description: '',
      categories: item.categories.slice(1, 4), // skip "原创", keep genre tags
      tags: item.categories,
      totalWordCount: 0, // not available on list page
      status: item.status,
      firstPublishDate: item.date,
      chartName: chart.name,
      rank: i + 1,
      favorites: item.collections,
      recommendVotes: null,
      monthlyTickets: null,
      commentCount: null,
      score: item.score,
      scrapedAt: new Date().toISOString(),
    }));
  } catch (e) {
    process.stderr.write(
      `[jinjiang] Failed ${chart.name}: ${e.message}\n`
    );
    return [];
  }
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

  // Quality check.
  const valid = allItems.filter(
    (item) =>
      item.title &&
      item.author &&
      item.title !== item.author &&
      item.platformBookId
  );

  process.stdout.write(JSON.stringify(valid));
}

main().catch((e) => {
  process.stderr.write(`[jinjiang] Fatal: ${e.message}\n`);
  process.exit(1);
});
