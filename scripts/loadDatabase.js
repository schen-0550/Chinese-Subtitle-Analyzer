import fs from 'fs';
import mysql from 'mysql2/promise';
import 'dotenv/config';

const fileBaseName = 'thehope_episode1';

const input = fs.readFileSync(`./data/processed/${fileBaseName}.json`, 'utf-8');
const subtitles = JSON.parse(input);

// create connection to database
const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

// insert subtitles into database 
try {
    for (const subtitle of subtitles) {
        await connection.execute(
            `INSERT INTO Subtitles (start_time, end_time, subtitle_text)
             VALUES (?,?,?)`,
            [subtitle.start, subtitle.end, subtitle.text]
        );
    }
    console.log(`Inserted ${subtitles.length} lines into Subtitles.`);
} catch (err) {
    console.error(err);
} finally {
    await connection.end();
}
