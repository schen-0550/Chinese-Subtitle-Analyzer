CREATE DATABASE subtitle_analyzer;

USE subtitle_analyzer;

CREATE TABLE Subtitles (
    line_id INT AUTO_INCREMENT PRIMARY KEY,
    start_time INT,
    end_time INT,
    subtitle_text TEXT NOT NULL
);

CREATE TABLE Words (
    word_id INT AUTO_INCREMENT PRIMARY KEY,
    line_id INT NOT NULL, 
    word VARCHAR(100) NOT NULL,
    hsk_level INT,
    FOREIGN KEY (line_id) REFERENCES Subtitles(line_id)
);