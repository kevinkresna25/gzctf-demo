#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# Generic Docker Compose Starter (clean & professional logging)
# - Mendukung docker compose v2 & docker-compose v1
# - Otomatis pakai docker-compose.yml (+ override bila ada)
# - Profiles: up all | up <p1> <p2> ...
# - Commands: up, down, status, logs, build, pull, exec, shell,
#             restart, prune, clean, profiles, files, help
# - PROJECT_NAME bisa dioverride via PROJECT_NAME_OVERRIDE
# ============================================================

# ---------- resolve self name (robust untuk dipanggil via bash script.sh) ----------
SELF_PATH="${BASH_SOURCE[0]:-$0}"
SELF="$(basename -- "$SELF_PATH")"

# ---------- terminal colors (disable when not TTY / NO_COLOR) ----------
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  BOLD="$(printf '\033[1m')"; DIM="$(printf '\033[2m')"; RESET="$(printf '\033[0m')"
  C_INFO="$(printf '\033[36m')"    # cyan
  C_OK="$(printf '\033[32m')"      # green
  C_WARN="$(printf '\033[33m')"    # yellow
  C_ERR="$(printf '\033[31m')"     # red
else
  BOLD=""; DIM=""; RESET=""
  C_INFO=""; C_OK=""; C_WARN=""; C_ERR=""
fi

log_info() {  printf "%s[INFO]%s %s\n"  "$C_INFO" "$RESET" "$*"; }
log_ok()   {  printf "%s[ OK ]%s %s\n"  "$C_OK"   "$RESET" "$*"; }
log_warn() {  printf "%s[WARN]%s %s\n"  "$C_WARN" "$RESET" "$*"; }
log_err()  {  printf "%s[ERR ]%s %s\n"  "$C_ERR"  "$RESET" "$*"; }
log_step() {  printf "%s➤%s %s\n"       "$BOLD"   "$RESET" "$*"; }
hint()     {  printf "%s%s%s\n" "$DIM" "$*" "$RESET"; }

trap 'code=$?; [[ $code -ne 0 ]] && log_err "Gagal di baris ${BASH_LINENO[0]} (exit $code)"; exit $code' EXIT

# ---------- detect docker compose ----------
if docker compose version &>/dev/null; then
  DC=(docker compose)
elif docker-compose version &>/dev/null; then
  DC=(docker-compose)
else
  log_err "docker compose tidak ditemukan. Install Docker + Compose."
  exit 1
fi

# ---------- compose files ----------
COMPOSE_FILES=(docker-compose.yml)
[[ -f docker-compose.override.yml ]] && COMPOSE_FILES+=(docker-compose.override.yml)

COMPOSE_ARGS=()
for f in "${COMPOSE_FILES[@]}"; do
  [[ -f "$f" ]] && COMPOSE_ARGS+=(-f "$f")
done

if [[ ${#COMPOSE_ARGS[@]} -eq 0 ]]; then
  log_err "Tidak menemukan docker-compose.yml di direktori ini."
  exit 1
fi

# ---------- project name ----------
sanitize() { echo "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_.-' '-'; }
PROJECT_NAME="${PROJECT_NAME_OVERRIDE:-$(sanitize "$(basename "$PWD")")}"

c() { "${DC[@]}" "${COMPOSE_ARGS[@]}" -p "$PROJECT_NAME" "$@"; }

print_usage() {
  cat <<EOF
USAGE
  ./${SELF} up {all|<profile> [profile...]}   Start dengan profiles
  ./${SELF} down                              Stop & remove containers (orphans dibersihkan)
  ./${SELF} restart [service...]              Restart service tertentu (atau semua)
  ./${SELF} status|ps                         Lihat status container
  ./${SELF} logs [-f] [service]               Tampilkan logs (ikuti -f opsional)
  ./${SELF} build [service...]                Build images
  ./${SELF} pull  [service...]                Pull images
  ./${SELF} exec <service> [cmd...]           Exec perintah dalam container
  ./${SELF} shell <service>                   Masuk shell (bash/sh) container
  ./${SELF} prune                             Down + bersihkan network dangling
  ./${SELF} clean --force                     Down -v + prune volumes/images (destruktif)
  ./${SELF} profiles                          Daftar profiles (jika didukung)
  ./${SELF} files                             Tampilkan compose files yang dipakai
  ./${SELF} help                              Tampilkan bantuan

Contoh
  ./${SELF} up all
  ./${SELF} up api worker
  ./${SELF} logs -f api
  PROJECT_NAME_OVERRIDE=myapp ./${SELF} up all
EOF
}

cmd="${1:-}"
shift || true

# Tanpa argumen: hanya hint singkat (tidak memuntahkan full usage).
if [[ -z "${cmd}" ]]; then
  log_warn "Tidak ada perintah yang diberikan."
  hint "Gunakan: ./${SELF} help   untuk melihat daftar perintah."
  exit 1
fi

case "$cmd" in
  help|-h|--help)
    print_usage
    ;;

  files)
    log_info "Compose files yang digunakan:"
    for f in "${COMPOSE_FILES[@]}"; do echo "  - $f"; done
    ;;

  profiles)
    log_info "Mencari profiles..."
    if PROFILES_RAW="$(c config --profiles 2>/dev/null)"; then
      if [[ -n "$PROFILES_RAW" ]]; then
        echo "$PROFILES_RAW" | awk '{print "  - " $0}'
      else
        hint "Tidak ada profiles yang terdefinisi."
      fi
    else
      hint "Compose ini tidak mendukung 'config --profiles'."
    fi
    ;;

  up)
    if [[ $# -eq 0 ]]; then
      log_warn "Profile belum ditentukan."
      hint "Contoh: ./${SELF} up all   atau   ./${SELF} up api worker"
      exit 1
    fi

    if [[ "$1" == "all" ]]; then
      log_step "Menjalankan semua profile yang tersedia..."
      if PROFILES_RAW="$(c config --profiles 2>/dev/null)"; then
        mapfile -t PROFILES <<<"$PROFILES_RAW"
        if [[ ${#PROFILES[@]} -eq 0 ]]; then
          hint "Tidak ada profiles. Menjalankan semua service yang terdefinisi."
          c up -d --build
        else
          PROFILE_ARGS=()
          for p in "${PROFILES[@]}"; do PROFILE_ARGS+=(--profile "$p"); done
          c "${PROFILE_ARGS[@]}" up -d --build
        fi
      else
        hint "Compose tidak mendukung profiles. Menjalankan semua service."
        c up -d --build
      fi
    else
      PROFILE_ARGS=()
      for p in "$@"; do PROFILE_ARGS+=(--profile "$p"); done
      log_step "Menjalankan profiles: $*"
      c "${PROFILE_ARGS[@]}" up -d --build
    fi

    echo
    c ps
    log_ok "Services aktif."
    ;;

  down)
    log_step "Menghentikan & menghapus containers (orphans dibersihkan)..."
    c down --remove-orphans
    log_ok "Selesai."
    ;;

  restart)
    log_step "Restart ${*:-seluruh} service..."
    c restart "$@" || true
    log_ok "Done."
    ;;

  status|ps)
    log_info "Status container:"
    c ps
    ;;

  logs)
    FOLLOW=
    if [[ "${1:-}" == "-f" ]]; then FOLLOW="-f"; shift; fi
    SERVICE="${1:-}"
    if [[ -n "$SERVICE" ]]; then
      log_info "Logs ($SERVICE) ${FOLLOW:+[follow]}:"
      c logs --tail=200 $FOLLOW "$SERVICE"
    else
      log_info "Logs semua service ${FOLLOW:+[follow]}:"
      c logs --tail=200 $FOLLOW
    fi
    ;;

  build)
    log_step "Build images ${*:+for: $*} ..."
    c build --pull "$@"
    log_ok "Build selesai."
    ;;

  pull)
    log_step "Pull images ${*:+for: $*} ..."
    c pull "$@"
    log_ok "Pull selesai."
    ;;

  exec)
    if [[ $# -lt 1 ]]; then
      log_err "Gunakan: ./${SELF} exec <service> [cmd...]"
      exit 1
    fi
    service="$1"; shift
    log_info "Exec di service '$service'..."
    c exec -it "$service" "${@:-/bin/sh}"
    ;;

  shell)
    if [[ $# -lt 1 ]]; then
      log_err "Gunakan: ./${SELF} shell <service>"
      exit 1
    fi
    svc="$1"
    log_info "Membuka shell di '$svc'..."
    if c exec "$svc" bash -lc 'exit' &>/dev/null; then
      c exec -it "$svc" bash
    else
      c exec -it "$svc" sh
    fi
    ;;

  prune)
    log_step "Down + network prune (dangling)..."
    c down --remove-orphans
    docker network prune -f >/dev/null || true
    log_ok "Bersih."
    ;;

  clean)
    if [[ "${1:-}" != "--force" ]]; then
      log_warn "CLEAN bersifat destruktif: menghapus volumes/images dangling."
      hint "Jalankan lagi dengan: ./${SELF} clean --force"
      exit 1
    fi
    log_step "CLEAN: down -v + prune network/volume/image dangling ..."
    c down -v --remove-orphans || true
    docker network prune -f >/dev/null || true
    docker volume  prune -f >/dev/null || true
    docker image   prune -f >/dev/null || true
    log_ok "Selesai."
    ;;

  *)
    log_err "Perintah tidak dikenal: $cmd"
    hint "Gunakan: ./${SELF} help   untuk daftar perintah."
    exit 1
    ;;
esac