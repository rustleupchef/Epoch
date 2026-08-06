static func<void> main() {
    string[] headlines = NewsAPI();
    for (int i = 0; i < headlines.Length; i++) {
        print(headlines[i]);
    }
    HackerNews();
}

static tooth<string[]> NewsAPI() language("javascript") => |
    const url = `https://newsapi.org/v2/top-headlines?country=us&apiKey=${process.env.key}`;
    const res = syncRequest('GET', url, {
        headers: {
            'User-agent' : 'SnapshotApp/1.0'
        }
    });

    if (res.statusCode === 200) {

        const data = JSON.parse(res.getBody('utf8'));
        const headlines = [];
        for (let article of data.articles) {
            headlines.push(article.title);
        }

        return headlines;
    }

    return [];
|

static tooth<void> HackerNews() language("javascript") => hacker_news
    const topStoriesRes = syncRequest('GET', 'https://hacker-news.firebaseio.com/v0/topstories.json');
    const storyIds = JSON.parse(topStoriesRes.getBody('utf8'))

    console.log('--- Hacker News Top Stories ---');
    
    storyIds.forEach(id => {
        const itemRes = syncRequest('GET', `https://hacker-news.firebaseio.com/v0/item/${id}.json`);
        const item = JSON.parse(itemRes.getBody('utf8'));
        console.log(`- [${item.score} points] ${item.title} (${item.url || 'No URL'})`);
    });
hacker_news

static tooth<void> print(string text) language("C") => |
    if (text != NULL) {
        printf("%s\n", text);
    }
|