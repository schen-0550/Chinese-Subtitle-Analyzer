import { parseSync } from 'subtitle';
import fs from 'fs';

const fileBaseName = 'thehope_episode1';

const input = fs.readFileSync(`./data/raw/${fileBaseName}.srt`, 'utf-8');
const subtitles = parseSync(input);

const newSubtitles = subtitles.map(subtitle => ({
    start: subtitle.data.start,
    end: subtitle.data.end,
    text: subtitle.data.text
}));

fs.writeFileSync(`./data/processed/${fileBaseName}.json`, JSON.stringify(newSubtitles, null, 2));

console.log(`Finished writing subtitles to ${fileBaseName}.json`);