USE subtitle_analyzer;

-- total number of words
SELECT COUNT(*) AS total_words
FROM Words;

-- total number of unique words
SELECT COUNT(DISTINCT word) AS unique_words
FROM Words;

-- vocab richness
SELECT ROUND(COUNT(DISTINCT word) / COUNT(*) * 100, 2) AS vocab_richness_pct
FROM Words;

-- top 20 most used words
SELECT word, COUNT(*) AS frequency
FROM Words
GROUP BY word
ORDER BY frequency DESC
LIMIT 20;

-- number of word occurrences sorted by HSK level
SELECT hsk_level,
    COUNT(*) AS word_count
FROM Words
WHERE hsk_level IS NOT NULL
GROUP BY hsk_level
ORDER BY hsk_level;

-- percentage of words belonging to each HSK level
SELECT hsk_level,
    COUNT(*) AS word_count,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 2) AS pct
FROM Words
WHERE hsk_level IS NOT NULL
GROUP BY hsk_level
ORDER BY hsk_level;

-- avg hsk level of vocab encountered while watching show
SELECT ROUND(AVG(hsk_level), 2) AS weighted_avg_hsk_level
FROM Words
WHERE hsk_level IS NOT NULL;

-- most common words by hsk level
WITH ranked_words AS (
    SELECT word, hsk_level,
        COUNT(*) AS frequency,
        ROW_NUMBER() OVER(
            PARTITION BY hsk_level
            ORDER BY COUNT(*) DESC
        ) AS word_rank
    FROM Words
    WHERE hsk_level IS NOT NULL
    GROUP BY word, hsk_level
)
SELECT hsk_level, word, frequency, word_rank
FROM ranked_words
WHERE word_rank <= 10
ORDER BY hsk_level, word_rank;

-- words that appear only once
SELECT word, 
    COUNT(*) AS frequency
FROM Words
GROUP BY word
HAVING COUNT(*) = 1
ORDER BY word;

-- number of words that appear only once
SELECT COUNT(*) AS singleton_words
FROM (
    SELECT word
    FROM Words
    GROUP BY word
    HAVING COUNT(*) = 1
) AS singletons;

-- vocab coverage
WITH word_frequency AS (
    SELECT word,
        COUNT(*) AS frequency
    FROM Words
    GROUP BY word
),
ranked_words AS (
    SELECT word, frequency,
        ROW_NUMBER() OVER (
            ORDER BY frequency DESC
        ) AS word_rank
    FROM word_frequency
),
coverage AS (
    SELECT word, frequency, word_rank,
        ROUND(SUM(frequency) OVER (
            ORDER BY word_rank
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(frequency) OVER () * 100, 2) AS coverage_pct
    FROM ranked_words
)
SELECT MIN(CASE
        WHEN coverage_pct >= 80 THEN word_rank
    END) AS words_for_80_pct,
    MIN(CASE
        WHEN coverage_pct >= 90 THEN word_rank
    END) AS words_for_90_pct,
    MIN(CASE
        WHEN coverage_pct >= 95 THEN word_rank
    END) AS words_for_95_pct
FROM coverage;




