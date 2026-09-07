import mysql from 'mysql2/promise';
import segmentitPkg from 'segmentit';
import 'dotenv/config';

const { Segment, useDefault } = segmentitPkg;

const segmentit = useDefault(new Segment());

const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

const [rows] = await connection.execute(
    `SELECT line_id, subtitle_text
     FROM Subtitles`
);

for (const row of rows) {
    const words = segmentit.doSegment(row.subtitle_text, {
        simple: true,
        stripPunctuation: true
    });

    // filters out non-Chinese text
    const chineseWords = words.filter(word => 
        /^[\u4e00-\u9fff]+$/.test(word)
    );

    for (const word of chineseWords) {
        await connection.execute(
            `INSERT INTO Words (line_id, word)
             VALUES (?,?)`,
            [row.line_id, word]
        );
    }
}

await connection.end();

console.log('Finished inserting words into Words.');
