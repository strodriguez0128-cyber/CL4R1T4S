# Debugging `npm test` Failures for Create React App on WSL2

This guide documents a reproducible workflow for diagnosing and fixing `npm test` failures in a Create React App (CRA) project when running on Ubuntu 22.04 inside WSL2. The scenario mirrors an environment where the project lives on the Windows-mounted filesystem (`/mnt/c/...`), `npm install` previously failed with `EACCES`, and subsequent test runs report `sh: 1: react-scripts: not found`.

## 1. Understand the Failure

When `npm test` prints `sh: 1: react-scripts: not found`, the `react-scripts` binary is missing from `node_modules/.bin`. In CRA projects, this almost always indicates that the dependency install step did not complete. In our case the root cause is an `EACCES` error that prevented `npm install` from writing to `node_modules` and npm's cache on the Windows-mounted drive.

Key symptoms:

* `npm install` fails with `EACCES: permission denied, mkdir ...`.
* `node_modules` is absent or incomplete.
* `npm test` fails immediately because it cannot spawn `react-scripts`.

## 2. Collect Diagnostics

Run the following commands from WSL2 and save the output for reference:

```bash
cd /mnt/c/Users/SKEAI/welcome-to-docker
pwd                          # confirm the project directory
ls -l package.json           # ensure package.json exists
grep -n 'react-scripts' package.json
ls -ld node_modules          # presence & permissions of node_modules
ls node_modules/react-scripts  # verify dependency contents (if folder exists)
npm config list
npm test -- --verbose
```

If any command fails, note the full error text. In particular, confirm whether `react-scripts` is listed in `package.json` (usually under `dependencies`).

## 3. Move the Project to the Linux Filesystem

`npm` works more reliably on the native ext4 filesystem mounted at `/home/<user>`. Copy the project there and reset the install:

```bash
cp -r /mnt/c/Users/SKEAI/welcome-to-docker ~/welcome-to-docker-local
cd ~/welcome-to-docker-local
chmod -R u+w .
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

*If `cp` reports that the source path does not exist, double-check the directory name or mount point. Use `ls /mnt/c/Users` to list available users and locate the project folder.*

Once installation succeeds, verify:

```bash
ls node_modules/react-scripts
npm ls react-scripts
```

## 4. Configure npm to Avoid Future Permission Errors

To keep using the original Windows-mounted project path, reconfigure npm to store global binaries and cache within your home directory:

```bash
mkdir -p ~/.npm-global ~/.npm/_cacache
npm config set prefix ~/.npm-global
npm config set cache ~/.npm/_cacache
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Close any editors (e.g., VS Code Remote-WSL) that might lock files, then re-run `npm install` inside the project. If permissions remain problematic on `/mnt/c`, continue working from the copied project under `~/welcome-to-docker-local`.

## 5. Alternative: Use a Node Docker Container

If filesystem permissions continue to block progress, run installs within an official Node Docker image:

```bash
cd /mnt/c/Users/SKEAI/welcome-to-docker
docker run --rm -it -v $(pwd):/app -w /app node:22 npm install
docker run --rm -it -v $(pwd):/app -w /app node:22 npm test -- --watchAll=false
```

Docker writes files as `root`, so reset ownership afterwards if necessary:

```bash
sudo chown -R $USER:$USER node_modules package-lock.json
```

## 6. Validate Scripts and Tests

After dependencies install successfully:

1. Confirm the npm scripts:
   ```bash
   node -p "require('./package.json').scripts"
   ```
   Ensure there is a `"test": "react-scripts test"` entry.
2. Discover tests:
   ```bash
   find src -name '*.test.js' -o -name '*.spec.js'
   ```
3. Run the suite:
   ```bash
   npm test -- --watchAll=false
   ```

A clean run verifies that the earlier JSX fix (e.g., converting `class` to `className` in `src/App.js`) does not introduce regressions.

## 7. Capture Logs When Issues Persist

If problems remain, gather detailed logs for deeper analysis:

```bash
npm install --verbose 2>&1 | tee npm-install.log
npm test -- --verbose 2>&1 | tee npm-test.log
```

Share the logs along with the outputs of:

```bash
ls -ld . node_modules package.json
grep -n 'react-scripts' package.json
find src -name '*.test.js' -o -name '*.spec.js'
```

These diagnostics make it possible to distinguish between dependency, configuration, and test-level failures.

## 8. Summary Checklist

- [ ] Confirm `package.json` contains `react-scripts`.
- [ ] Run installs from the Linux filesystem or Docker to bypass `/mnt/c` permission issues.
- [ ] Reconfigure npm cache/prefix to user-owned directories.
- [ ] Verify `node_modules/react-scripts` exists and `npm ls react-scripts` reports a version.
- [ ] Run `npm test -- --watchAll=false` and ensure the suite passes or reports actionable failures.

Following this workflow restores the test runner and provides a reliable baseline for future development on WSL2.
