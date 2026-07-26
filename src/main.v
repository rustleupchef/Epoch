static func<void> main() {
    string s = scrape("https://waiscshs-dev.onrender.com/");
    pause(2000);
    print(s);
}

static tooth<void> pause(int delay) language("csharp") => {
    Thread.Sleep(delay);
}

static tooth<string> scrape(string website) language("javascript") => {

    const res = syncRequest('GET', website);
    return res.body.toString('utf8');
}

static tooth<void> print(string text) language("c") => {
    printf(text);
}