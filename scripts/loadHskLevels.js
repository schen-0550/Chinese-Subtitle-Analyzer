import mysql from 'mysql2/promise';
import fs from 'fs';
import 'dotenv/config';

const hskData = JSON.parse(fs.readFileSync('./data/reference/hsk.json', 'utf8'));

const connection = await mysql.createConnection({
    host: process.env.DB_ENV,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

const hskMap = new Map();

for (const entry of hskData) {
    const newLevel = entry.level.find(level =>
        level.startsWith('new-')
    );

    if (newLevel) {
        let levelNumber;

        if (newLevel == 'new-7+') {
            levelNumber = 7;
        } else {
            levelNumber = Number(
                newLevel.replace('new-', '')
            );
        }
        hskMap.set(entry.simplified, levelNumber);
    }
}

const [words] = await connection.execute(
    `SELECT DISTINCT word
     FROM Words`
);

for (const row of words) {
    const level = hskMap.get(row.word);

    if (level != undefined) {
        await connection.execute(
            `UPDATE Words
             SET hsk_level = ?
             WHERE word = ?`,
            [level, row.word]
        );
    }
}

await connection.end();

console.log('Finished assigning HSK levels to words.');
