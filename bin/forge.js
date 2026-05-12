#!/usr/bin/env node
/**
 * forge CLI
 * Usage: npx forge [init|update] [--stack python|node|mobile|data] [--dir PATH]
 */
'use strict';

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const REPO_RAW = 'https://raw.githubusercontent.com/forge-dev/forge/main';
const INSTALL_SCRIPT_URL = `${REPO_RAW}/install.sh`;

const args = process.argv.slice(2);
const command = args.find(a => !a.startsWith('--')) || 'init';
const stackArg = getFlag('--stack');
const dirArg = getFlag('--dir') || '.';

function getFlag(name) {
  const idx = args.indexOf(name);
  return idx !== -1 ? args[idx + 1] : null;
}

function runInstall() {
  const stackFlag = stackArg ? `--stack ${stackArg}` : '';
  const dirFlag = `--dir ${path.resolve(dirArg)}`;

  // Try local install.sh first (when running from the repo itself)
  const localScript = path.join(__dirname, '..', 'install.sh');
  if (fs.existsSync(localScript)) {
    console.log('[forge] Using local install.sh');
    execSync(`bash "${localScript}" ${dirFlag} ${stackFlag}`, { stdio: 'inherit' });
    return;
  }

  // Remote install
  const hasCurl = commandExists('curl');
  const hasWget = commandExists('wget');

  if (!hasCurl && !hasWget) {
    console.error('[forge] Error: curl or wget is required');
    process.exit(1);
  }

  const fetchCmd = hasCurl
    ? `curl -fsSL ${INSTALL_SCRIPT_URL}`
    : `wget -qO- ${INSTALL_SCRIPT_URL}`;

  execSync(`${fetchCmd} | bash -s -- ${dirFlag} ${stackFlag}`, { stdio: 'inherit' });
}

function commandExists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function printHelp() {
  console.log(`
forge — God-level Claude Code engineering standards

Usage:
  npx forge init              Install into current directory
  npx forge init --dir PATH   Install into specified directory
  npx forge init --stack X    Force stack (python|node|mobile|data|go|rust)
  npx forge update            Re-install (upgrade to latest standards)

What gets installed:
  CLAUDE.md                   God-level engineering standards (auto-detected stack)
  .claude/settings.json       Pre-approved permissions + hooks
  .claude/commands/           11 slash commands (/commit /ship /review /fix /context
                               /design /arch /perf /security /data /refactor)
  .claudeignore               Exclude noise from Claude context

After install:
  Start \`claude\` in your project directory. Claude will follow the standards.
`);
}

switch (command) {
  case 'init':
  case 'update':
    runInstall();
    break;
  case 'help':
  case '--help':
  case '-h':
    printHelp();
    break;
  default:
    console.error(`[forge] Unknown command: ${command}`);
    printHelp();
    process.exit(1);
}
