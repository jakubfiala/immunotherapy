const fs = require('fs');
const express = require('express');
const config = require('../config.json');

const app = express();

const SECTION_FILE_PATH = '../section';

app.get('/health', (req, res) => res.send('ok'));
app.get('/next-section', (req, res) => {
  const currentSection = parseInt(fs.readFileSync(SECTION_FILE_PATH, { encoding: 'utf8' }));
  const nextSection = (currentSection + 1) % config.n_sections;
  fs.writeFileSync(SECTION_FILE_PATH, `${nextSection}\n`);
  res.send(`updated section to ${nextSection}\n`);
});

app.get('/section/:index', (req, res) => {
  const nextSection = parseInt(req.params.index) % config.n_sections;
  fs.writeFileSync(SECTION_FILE_PATH, `${nextSection}\n`);
  res.send(`updated section to ${nextSection}\n`);
});

app.listen(8080, () => { console.info('Running communication server.'); })
