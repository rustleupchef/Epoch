static func<void> main() {
    string[] headlines = NewsAPI();
    string[] stories = HackerNews();

    string[] texts = [..headlines, ..stories];
    for (int i = 0; i < texts.Length; i++) {
        print(texts[i]);
    }
}

static tooth<float[,]>

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

static tooth<string[]> HackerNews() language("javascript") => hacker_news
    const topStoriesRes = syncRequest('GET', 'https://hacker-news.firebaseio.com/v0/topstories.json');
    const storyIds = JSON.parse(topStoriesRes.getBody('utf8'))
    
    const stories = [];
    storyIds.forEach(id => {
        const itemRes = syncRequest('GET', `https://hacker-news.firebaseio.com/v0/item/${id}.json`);
        const item = JSON.parse(itemRes.getBody('utf8'));
        stories.push(item.title);
    });

    return stories;
hacker_news

static tooth<void> print(string text) language("C") => |
    if (text != NULL) {
        printf("%s\n", text);
    }
|