#!/usr/bin/env bash
set -u
ROOT="${1:-$(pwd)}"
cd "$ROOT" 2>/dev/null || { echo "Cannot cd into $ROOT" >&2; exit 1; }

printf '# Project detection\n'
printf -- '- Workspace: %s\n' "$(pwd)"
printf -- '- Time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"

printf '\n## Detected files\n'
for f in pyproject.toml requirements.txt setup.py uv.lock poetry.lock Pipfile package.json pnpm-lock.yaml yarn.lock package-lock.json tsconfig.json Cargo.toml go.mod pom.xml build.gradle gradlew CMakeLists.txt Makefile renv.lock DESCRIPTION; do
  [ -e "$f" ] && printf -- '- %s\n' "$f"
done

printf '\n## Suggested validation commands\n'
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then
  echo '- Python detected:'
  echo '  - python -m compileall .'
  [ -d tests ] && echo '  - pytest'
  [ -f pyproject.toml ] && grep -q 'ruff' pyproject.toml 2>/dev/null && echo '  - ruff check .'
  [ -f pyproject.toml ] && grep -q 'mypy' pyproject.toml 2>/dev/null && echo '  - mypy .'
fi
if [ -f package.json ]; then
  echo '- Node/JS/TS detected:'
  if command -v node >/dev/null 2>&1; then node -e "const p=require('./package.json'); for (const [k,v] of Object.entries(p.scripts||{})) console.log('  - npm run '+k+'  # '+v)" 2>/dev/null || true; fi
  [ -f pnpm-lock.yaml ] && echo '  - pnpm install && pnpm test'
  [ -f yarn.lock ] && echo '  - yarn install && yarn test'
  [ -f package-lock.json ] && echo '  - npm ci && npm test'
fi
[ -f Cargo.toml ] && printf -- '- Rust detected:\n  - cargo test\n  - cargo clippy\n'
[ -f go.mod ] && printf -- '- Go detected:\n  - go test ./...\n'
[ -f pom.xml ] && printf -- '- Maven detected:\n  - mvn test\n'
[ -f gradlew ] && printf -- '- Gradle wrapper detected:\n  - ./gradlew test\n'
[ -f CMakeLists.txt ] && printf -- '- CMake detected:\n  - cmake -S . -B build\n  - cmake --build build\n'
[ -f Makefile ] && printf -- '- Makefile detected:\n  - make test  # if target exists\n'

printf '\n## Notes\n- This script is read-only and only suggests commands.\n- Ask before installing dependencies or changing lockfiles.\n'
