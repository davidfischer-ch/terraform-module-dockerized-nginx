#!/usr/bin/env sh

# Apply the module against the local Docker daemon, check the site it serves, run its actions on a
# changed and on a broken configuration, then destroy everything. Runs as root: the module creates
# and chowns its directories and writes the site's files. The Docker daemon must see the data
# directory at the same path: set E2E_DATA_DIRECTORY to a directory both share when Terraform runs
# in a container of its own.
#
#   E2E_IMAGE=nginx:1.28.0 sh tests/e2e/run.sh

set -eu

# The data directory: a fresh temporary one, or the one E2E_DATA_DIRECTORY names, absent or empty.
# The cleanup removes only what this run created.
if [ -n "${E2E_DATA_DIRECTORY:-}" ]; then
  DATA_DIRECTORY="${E2E_DATA_DIRECTORY}"
  case "${DATA_DIRECTORY}" in
    /*) ;;
    *)
      echo "FAILED: E2E_DATA_DIRECTORY must be an absolute path" >&2
      exit 1
      ;;
  esac
  if [ -e "${DATA_DIRECTORY}" ] || [ -L "${DATA_DIRECTORY}" ]; then
    if [ -L "${DATA_DIRECTORY}" ] || [ ! -d "${DATA_DIRECTORY}" ] \
      || [ -n "$(ls -A "${DATA_DIRECTORY}")" ]; then
      echo "FAILED: E2E_DATA_DIRECTORY ${DATA_DIRECTORY} is not an empty directory" >&2
      exit 1
    fi
    DATA_DIRECTORY_CREATED=false
  else
    mkdir "${DATA_DIRECTORY}"
    DATA_DIRECTORY_CREATED=true
  fi
else
  DATA_DIRECTORY=$(mktemp -d)
  DATA_DIRECTORY_CREATED=true
fi

cd "$(dirname "$0")"

CONTAINER=nginx-e2e
SITE="${DATA_DIRECTORY}/config/sites-enabled/e2e.conf"

tf() {
  terraform "$@" -input=false -no-color \
    -var "image=${E2E_IMAGE}" -var "data_directory=${DATA_DIRECTORY}"
}

expect() {
  if [ "$2" != "$3" ]; then
    echo "FAILED: ${1}: expected ${3}, got ${2}" >&2
    exit 1
  fi
  echo "ok: ${1}"
}

invoke() {
  echo "==> action ${1}"
  if ! output=$(tf apply -auto-approve "-invoke=module.nginx.action.docker_exec.${1}" 2>&1); then
    echo "${output}" >&2
    echo "FAILED: action ${1}" >&2
    exit 1
  fi
}

invoke_fails() {
  echo "==> action ${1}, expected to fail"
  if tf apply -auto-approve "-invoke=module.nginx.action.docker_exec.${1}" > /dev/null 2>&1; then
    echo "FAILED: action ${1} succeeded" >&2
    exit 1
  fi
  echo "ok: action ${1} fails"
}

page() {
  docker exec "${CONTAINER}" curl -s -H 'Host: nginx-e2e' http://127.0.0.1/
}

# The page once it reads $1, or after 10 seconds: a reload replaces the workers gracefully.
page_after_reload() {
  tries=0
  while [ "$(page)" != "$1" ] && [ "${tries}" -lt 10 ]; do
    tries=$((tries + 1))
    sleep 1
  done
  page
}

container_id() {
  docker inspect -f '{{.Id}}' "${CONTAINER}"
}

# The bind mounts live on the daemon's filesystem, which is not this one under Docker-in-Docker:
# remove them through the daemon too.
cleanup() {
  tf destroy -auto-approve > /dev/null || true
  docker run --rm --entrypoint rm -v "${DATA_DIRECTORY}:/e2e" "${E2E_IMAGE}" \
    -rf /e2e/cache /e2e/config /e2e/logs || true
  [ "${DATA_DIRECTORY_CREATED}" = false ] || rm -rf "${DATA_DIRECTORY}"
}
trap cleanup EXIT

waited=0
until docker info > /dev/null 2>&1; do
  waited=$((waited + 1))
  if [ "${waited}" -ge 300 ]; then
    echo "FAILED: no Docker daemon reachable within 300 seconds" >&2
    exit 1
  fi
  sleep 1
done

terraform init -input=false -no-color > /dev/null
# The module waits for a healthy container: the apply fails when the healthcheck does not pass.
tf apply -auto-approve > /dev/null

expect 'the healthcheck reports the server healthy' \
  "$(docker inspect -f '{{.State.Health.Status}}' "${CONTAINER}")" healthy
expect 'the site is served' "$(page)" served
invoke test

before=$(container_id)
sed -i 's/"served/"reloaded/' "${SITE}"
invoke reload
expect 'reload serves the changed site' "$(page_after_reload reloaded)" reloaded
expect 'reload keeps the container' "$(container_id)" "${before}"

echo 'server {' > "${SITE}"
invoke_fails test
invoke_fails reload
expect 'a broken configuration leaves the running one' "$(page)" reloaded

# The apply writes the site file back, a create that replaces no container: reload loads it.
tf apply -auto-approve > /dev/null
expect 'the apply writes the site back' "$(grep -c '"served' "${SITE}")" 1
invoke reload
expect 'reload serves the site written back' "$(page_after_reload served)" served

status=0
tf plan -detailed-exitcode > /dev/null || status=$?
expect 'the plan is clean after the apply and the actions' "${status}" 0
