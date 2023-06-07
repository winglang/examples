import fetch from 'node-fetch';
import { JSDOM } from 'jsdom';

export async function parseFoo() {
    return 'bar';
}

export async function parseAtomFeed() {
    const feedUrl = 'https://github.com/winglang/wing/releases.atom';

    // Make GET request
    const response = await fetch(feedUrl);
    const data = await response.text();

    // Parse XML data
    const dom = new JSDOM(data, { contentType: "application/xml" });
    const document = dom.window.document;

    // Extract feed data
    const feed = {
        id: document.querySelector('feed > id').textContent,
        link: document.querySelector('feed > link[rel="alternate"]').getAttribute('href'),
        title: document.querySelector('feed > title').textContent,
        updated: document.querySelector('feed > updated').textContent,
    }

    // Extract entries data
    const entries = [];
    const entryElements = document.querySelectorAll('feed > entry');
    entryElements.forEach(entryElement => {
        const entry = {
            id: entryElement.querySelector('id').textContent,
            updated: entryElement.querySelector('updated').textContent,
            link: entryElement.querySelector('link[rel="alternate"]').getAttribute('href'),
            title: entryElement.querySelector('title').textContent,
            content: entryElement.querySelector('content').textContent,
            author: entryElement.querySelector('author > name').textContent,
            thumbnail: entryElement.querySelector('media\\:thumbnail').getAttribute('url'),
        }
        entries.push(entry);
    });

    return {feed, entries};
}
