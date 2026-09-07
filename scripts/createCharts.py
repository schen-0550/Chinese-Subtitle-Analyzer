import os
import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
from dotenv import load_dotenv

load_dotenv()

connection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)
os.makedirs("visualizations", exist_ok=True)

hsk_query = """
SELECT hsk_level,
    COUNT(*) AS word_count
FROM Words
WHERE hsk_level IS NOT NULL
GROUP BY hsk_level
ORDER BY hsk_level;
"""

hsk_df = pd.read_sql(hsk_query, connection)

hsk_labels = ["7+" if level == 7 else str(level) for level in hsk_df["hsk_level"]]

plt.figure(figsize=(8, 5))

plt.bar(hsk_labels, hsk_df["word_count"])

plt.xlabel("HSK Level")
plt.ylabel("Word Occurrences")
plt.title("HSK Vocabulary Distribution in The Hope - Episode 1")

plt.tight_layout()

plt.savefig("visualizations/hsk_distribution.png", dpi=300)

plt.close()

coverage_query = """
WITH word_counts AS (
    SELECT word,
        COUNT(*) AS frequency
    FROM Words
    GROUP BY word
),
ranked_words AS (
    SELECT word, frequency,
        ROW_NUMBER() OVER (
            ORDER BY frequency DESC
        ) AS word_rank,
        SUM(frequency) OVER (
            ORDER BY frequency DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_frequency,
        SUM(frequency) OVER () AS total_frequency
    FROM word_counts
)
SELECT word_rank,
    cumulative_frequency / total_frequency * 100 AS coverage_pct
FROM ranked_words
ORDER BY word_rank;
"""

coverage_df = pd.read_sql(coverage_query, connection)

plt.figure(figsize=(9, 6))

plt.plot(coverage_df["word_rank"], coverage_df["coverage_pct"])

for threshold in [80, 90, 95]:

    matching_rows = coverage_df[coverage_df["coverage_pct"] >= threshold]

    if not matching_rows.empty:

        row = matching_rows.iloc[0]

        word_rank = int(row["word_rank"])
        coverage_pct = row["coverage_pct"]

        plt.axhline(y=threshold, linestyle="--",alpha=0.5)
        plt.scatter(word_rank, coverage_pct)
        plt.text(word_rank, threshold - 5, f"{threshold}% = {word_rank} words")

plt.xlabel("Number of Unique Words Learned")
plt.ylabel("Cumulative Vocabulary Coverage (%)")
plt.title("Cumulative Vocabulary Coverage in The Hope - Episode 1")

plt.ylim(0, 100)

plt.tight_layout()

plt.savefig("visualizations/vocabulary_coverage.png",dpi=300)

plt.close()
connection.close()
print("Finished creating charts.")