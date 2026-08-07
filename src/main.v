static func<void> main() {
    string[] headlines = NewsAPI();
    string[] stories = HackerNews();

    string[] texts = [..headlines, ..stories];

    float[][] embeddings = generateEmbeddings(texts);
    float[] flattenedEmbeddings = [];
    for (int i = 0; i < embeddings.Length; i++) {
        flattenedEmbeddings = [..flattenedEmbeddings, ..embeddings[i]];
    }

    groupTexts(texts, flattenedEmbeddings, texts.Length, embeddings[0].Length, .2);
}

static tooth<void> groupTexts(
    string[] texts, 
    float[] flat_embeddings, 
    long size, 
    long dimensions,
    double similarity_threshold) language("c") => |

    float embeddings[size][dimensions];

    // Allocate an array to keep track of which group each text belongs to.
    int* group_ids = (int*)malloc(size * sizeof(int));
    if (group_ids == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return;
    }
    
    // Initialize all to -1 (meaning "unassigned").
    for (long i = 0; i < size; i++) {
        group_ids[i] = -1; 
    }

    int current_group_id = 0;

    // Grouping Logic
    for (long i = 0; i < size; i++) {
        // Skip if this text is already assigned to a group
        if (group_ids[i] != -1) continue; 

        // Assign the current text to a new group
        group_ids[i] = current_group_id;

        // Find all other unassigned texts that are similar to this one
        for (long j = i + 1; j < size; j++) {
            if (group_ids[j] == -1) {
                // Point directly to the vectors inside the flat array (Zero-copy)
                const float* embA = &flat_embeddings[i * dimensions];
                const float* embB = &flat_embeddings[j * dimensions];

                // Inline Cosine Similarity Calculation
                float dot_product = 0.0;
                float normA = 0.0;
                float normB = 0.0;
                
                for (long d = 0; d < dimensions; d++) {
                    dot_product += embA[d] * embB[d];
                    normA += embA[d] * embA[d];
                    normB += embB[d] * embB[d];
                }
                
                float sim = 0.0;
                // Prevent division by zero
                if (normA != 0.0 && normB != 0.0) {
                    sim = dot_product / (sqrt(normA) * sqrt(normB));
                }

                // If similarity exceeds threshold, group them together
                if (sim >= similarity_threshold) {
                    group_ids[j] = current_group_id;
                }
            }
        }
        current_group_id++; // Move on to create the next group
    }

    // Print the grouped texts
    printf("--- Grouped Texts (Threshold: %.2f) ---\n", similarity_threshold);
    for (int g = 0; g < current_group_id; g++) {
        printf("Group %d:\n", g + 1);
        for (long i = 0; i < size; i++) {
            if (group_ids[i] == g) {
                printf("  - %s\n", texts[i]);
            }
        }
        printf("\n");
    }

    // Clean up heap memory
    free(group_ids);
|

static tooth<float[][]> generateEmbeddings(string[] texts) language("python") => {
    model = SentenceTransformer("all-MiniLM-L6-v2")
    embeddings = model.encode(list(texts), show_progress_bar=False)
    return embeddings.tolist()
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

static tooth<void> print(string text) language("CSHARP") => |
    Console.WriteLine(text);
|