import fetch from 'node-fetch';
import { XMLParser, XMLBuilder } from 'fast-xml-parser';

export async function parseAtomFeed() {
    const feedUrl = 'https://github.com/winglang/wing/releases.atom';

    let feed;
    try {
        // Make GET request and parse XML data
        const response = await fetch(feedUrl);
        const text = await response.text();

        const parser = new XMLParser();
        feed = parser.parse(text);
    } catch (error) {
        console.error('Error parsing feed:', error);
        return null;
    }
    // Check if feed and its properties exist before extracting data
    const feedData = feed ? {
        id: feed.feed.id,
        link: feed.feed.link && feed.feed.link[0].$ ? feed.feed.link[0].$.href : null,
        title: feed.feed.title,
        updated: feed.feed.updated,
    } : null;

    // Check if feed items exist before extracting entries data
    const entries = feed && feed.feed.entry ? feed.feed.entry.map(item => ({
        id: item.id,
        updated: item.updated,
        link: item.link && item.link[0].$ && item.link[0].$.rel === 'alternate' ? item.link[0].$.href : null,
        title: item.title,
        content: item.content,
    })) : null;

    console.log({entries, feedData, feed})

    return {feed: feedData, entries};
}
