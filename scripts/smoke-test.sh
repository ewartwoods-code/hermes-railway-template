#!/bin/sh
set -eu

smoke_id="$$"
image_name="hermes-railway-template-smoke:${smoke_id}"
container_name="hermes-railway-smoke-${smoke_id}"
volume_name="hermes-railway-smoke-data-${smoke_id}"
smoke_password="smoke-password-${smoke_id}-not-a-real-secret"
smoke_secret="smoke-session-secret-${smoke_id}-not-a-real-secret"

cleanup() {
  docker rm -f "${container_name}" >/dev/null 2>&1 || true
  docker volume rm "${volume_name}" >/dev/null 2>&1 || true
  docker image rm "${image_name}" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

start_container() {
  docker run --detach \
    --name "${container_name}" \
    --publish 127.0.0.1::9119 \
    --volume "${volume_name}:/opt/data" \
    --env HERMES_DASHBOARD_BASIC_AUTH_USERNAME=smoke-admin \
    --env "HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=${smoke_password}" \
    --env "HERMES_DASHBOARD_BASIC_AUTH_SECRET=${smoke_secret}" \
    --entrypoint /opt/hermes/docker/entrypoint-dispatch.sh \
    "${image_name}" gateway run >/dev/null
}

wait_for_health() {
  host_port="$(docker inspect --format '{{(index (index .NetworkSettings.Ports "9119/tcp") 0).HostPort}}' "${container_name}")"
  health_url="http://127.0.0.1:${host_port}/api/health"

  attempt=0
  while [ "${attempt}" -lt 90 ]; do
    if payload="$(curl --fail --silent --show-error --max-time 3 "${health_url}" 2>/dev/null)"; then
      printf '%s' "${payload}" | grep -q '"ok":true'
      printf '%s\n' "${host_port}"
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  docker logs "${container_name}" >&2 || true
  return 1
}

docker build --tag "${image_name}" .
docker volume create "${volume_name}" >/dev/null
start_container
host_port="$(wait_for_health)"

status_payload="$(curl --fail --silent --show-error "http://127.0.0.1:${host_port}/api/status")"
printf '%s' "${status_payload}" | grep -q '"auth_required":true'
printf '%s' "${status_payload}" | grep -q '"basic"'

root_status="$(curl --silent --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:${host_port}/")"
case "${root_status}" in
  302|303|307) ;;
  *)
    printf 'expected an authentication redirect, got HTTP %s\n' "${root_status}" >&2
    exit 1
    ;;
esac

if docker exec "${container_name}" curl --fail --silent --max-time 2 http://127.0.0.1:8642/health >/dev/null 2>&1; then
  printf 'the optional API server unexpectedly accepted traffic on port 8642\n' >&2
  exit 1
fi

docker exec "${container_name}" /command/s6-setuidgid hermes touch /opt/data/template-smoke-sentinel
docker rm -f "${container_name}" >/dev/null
start_container
wait_for_health >/dev/null
docker exec "${container_name}" test -f /opt/data/template-smoke-sentinel

if docker logs "${container_name}" 2>&1 | grep -F "${smoke_password}" >/dev/null; then
  printf 'dashboard password leaked to container logs\n' >&2
  exit 1
fi

printf 'Hermes Railway template smoke test passed.\n'
