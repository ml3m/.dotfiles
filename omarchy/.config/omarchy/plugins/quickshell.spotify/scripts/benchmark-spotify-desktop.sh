#!/usr/bin/env bash
set -euo pipefail

state=${1:-}
duration=${2:-10}

if [[ -z $state || ! $state =~ ^[A-Za-z0-9._-]+$ || ! $duration =~ ^[0-9]+$ ||
      $duration -lt 2 || $duration -gt 60 ]]; then
  echo "Usage: scripts/benchmark-spotify-desktop.sh <state-label> [seconds: 2-60]" >&2
  exit 2
fi

spotify_pids() {
  local candidate executable

  while IFS= read -r candidate; do
    [[ -n $candidate && -r /proc/$candidate/exe ]] || continue
    executable=$(readlink -f -- "/proc/$candidate/exe" 2>/dev/null || true)
    [[ $executable == /opt/spotify/spotify ]] && printf '%s\n' "$candidate"
  done < <(pgrep -x spotify || true)
}

mapfile -t pids_before < <(spotify_pids)
(( ${#pids_before[@]} > 0 )) || {
  echo "benchmark-spotify-desktop.sh: the official Spotify client is not running" >&2
  exit 1
}

clock_ticks=$(getconf CLK_TCK)

cpu_ticks() {
  local pid=$1
  [[ -r /proc/$pid/stat ]] || { printf '0\n'; return; }
  awk '{ print $14 + $15 }' "/proc/$pid/stat"
}

context_switches() {
  local pid=$1
  [[ -r /proc/$pid/status ]] || { printf '0\n'; return; }
  awk '
    $1 == "voluntary_ctxt_switches:" || $1 == "nonvoluntary_ctxt_switches:" {
      total += $2
    }
    END { print total + 0 }
  ' "/proc/$pid/status"
}

rollup_value() {
  local pid=$1
  local field=$2
  [[ -r /proc/$pid/smaps_rollup ]] || { printf '0\n'; return; }
  awk -v wanted="$field:" \
    '$1 == wanted { print $2; found = 1 } END { if (!found) print 0 }' \
    "/proc/$pid/smaps_rollup"
}

ticks_before=0
switches_before=0
for pid in "${pids_before[@]}"; do
  ticks_before=$((ticks_before + $(cpu_ticks "$pid")))
  switches_before=$((switches_before + $(context_switches "$pid")))
done

start_ns=$(date +%s%N)
sleep "$duration"
end_ns=$(date +%s%N)

mapfile -t pids_after < <(spotify_pids)
if [[ ${pids_before[*]} != "${pids_after[*]}" ]]; then
  echo "benchmark-spotify-desktop.sh: Spotify's process set changed during the sample" >&2
  exit 1
fi

ticks_after=0
switches_after=0
spotify_pss=0
spotify_rss=0
for pid in "${pids_after[@]}"; do
  ticks_after=$((ticks_after + $(cpu_ticks "$pid")))
  switches_after=$((switches_after + $(context_switches "$pid")))
  spotify_pss=$((spotify_pss + $(rollup_value "$pid" Pss)))
  spotify_rss=$((spotify_rss + $(rollup_value "$pid" Rss)))
done

mapfile -t pids_final < <(spotify_pids)
if [[ ${pids_after[*]} != "${pids_final[*]}" ]]; then
  echo "benchmark-spotify-desktop.sh: Spotify's process set changed while memory was read" >&2
  exit 1
fi

elapsed_seconds=$(awk -v start="$start_ns" -v end="$end_ns" \
  'BEGIN { printf "%.6f", (end - start) / 1000000000 }')
cpu_percent=$(awk -v ticks="$((ticks_after - ticks_before))" \
  -v hz="$clock_ticks" -v elapsed="$elapsed_seconds" \
  'BEGIN { printf "%.3f", (ticks / hz) * 100 / elapsed }')
switches_per_second=$(awk -v switches="$((switches_after - switches_before))" \
  -v elapsed="$elapsed_seconds" \
  'BEGIN { printf "%.3f", switches / elapsed }')
pid_list=$(IFS=+; echo "${pids_final[*]}")

printf '%s\n' \
  'state,seconds,spotify_pids,process_count,spotify_pss_kib,spotify_rss_kib,cpu_percent,scheduler_switches_per_second'
printf '%s,%s,%s,%s,%s,%s,%s,%s\n' \
  "$state" "$elapsed_seconds" "$pid_list" "${#pids_final[@]}" \
  "$spotify_pss" "$spotify_rss" "$cpu_percent" "$switches_per_second"
