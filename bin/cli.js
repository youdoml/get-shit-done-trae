#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const args = process.argv.slice(2);
const command = args[0];

const scriptDir = path.join(__dirname, '..');
const userCwd = process.cwd();
const isWindows = os.platform() === 'win32';

function getScriptPath(scriptName) {
  const scriptPath = path.join(scriptDir, scriptName);

  if (isWindows) {
    const batScript = scriptPath.replace(/\.sh$/, '.bat');
    if (fs.existsSync(batScript)) {
      return batScript;
    }
  }

  return scriptPath;
}

function executeScript(scriptPath) {
  try {
    if (isWindows) {
      // Windows: 在用户当前目录执行脚本
      const installCmd = `cmd /c "cd /d "${userCwd}" && "${scriptPath}""`;
      execSync(installCmd, { stdio: 'inherit', cwd: userCwd });
    } else {
      // Unix系统上使用bash执行脚本
      execSync(`bash "${scriptPath}"`, { stdio: 'inherit', cwd: userCwd });
    }
  } catch (error) {
    console.error('执行失败:', error.message);
    process.exit(1);
  }
}

if (command === 'uninstall' || command === '--uninstall' || command === '-u') {
  const uninstallScript = getScriptPath('uninstall.sh');
  executeScript(uninstallScript);
} else {
  const installScript = getScriptPath('install.sh');
  executeScript(installScript);
}
