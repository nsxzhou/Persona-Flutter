// CDP helper — shared utilities for scrapers that need a browser.
// Provides: CDP availability check, browser connection, graceful fallback.
//
// Usage in other scripts:
//   const { connectCdp, CDP_UNAVAILABLE_EXIT_CODE } = require('./cdp-helper');
//   const browser = await connectCdp();

const CDP_ENDPOINT = process.env.CDP_ENDPOINT || 'http://127.0.0.1:9222';
const CDP_UNAVAILABLE_EXIT_CODE = 2;

async function isCdpAvailable() {
  try {
    const resp = await fetch(`${CDP_ENDPOINT}/json/version`, {
      signal: AbortSignal.timeout(3000),
    });
    return resp.ok;
  } catch {
    return false;
  }
}

async function connectCdp() {
  const puppeteer = require('puppeteer-core');

  if (!(await isCdpAvailable())) {
    process.stderr.write(
      `[cdp] No Chrome DevTools at ${CDP_ENDPOINT}. ` +
      `Start Chrome with --remote-debugging-port=9222\n`
    );
    process.exit(CDP_UNAVAILABLE_EXIT_CODE);
  }

  try {
    const browser = await puppeteer.connect({
      browserURL: CDP_ENDPOINT,
      defaultViewport: { width: 1280, height: 900 },
    });
    return browser;
  } catch (e) {
    process.stderr.write(`[cdp] Connect failed: ${e.message}\n`);
    process.exit(CDP_UNAVAILABLE_EXIT_CODE);
  }
}

// Wait for a selector with a timeout, returns null if not found.
async function safeWaitFor(page, selector, timeout = 10000) {
  try {
    await page.waitForSelector(selector, { timeout });
    return true;
  } catch {
    return false;
  }
}

// Sleep helper.
function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

module.exports = {
  CDP_ENDPOINT,
  CDP_UNAVAILABLE_EXIT_CODE,
  isCdpAvailable,
  connectCdp,
  safeWaitFor,
  sleep,
};
