const assert = require('assert');

describe('Google Search', () => {
    it('should open Google and check title', async () => {
        await browser.url('https://www.google.com');
        const title = await browser.getTitle();
        assert.strictEqual(title.includes('Google'), true);
    });
});
