#!/bin/bash
# Claude Code status line: model + reasoning effort/thinking budget,
# plus context/5h/7d usage progress bars.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown model"')
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking_enabled=$(echo "$input" | jq -r '.thinking.enabled // false')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Build a compact progress bar: 10 chars wide
make_bar() {
  local pct="$1"
  local width=10
  local filled=$(echo "$pct $width" | awk '{printf "%d", ($1/100)*$2 + 0.5}')
  local empty=$(( width - filled ))
  local bar=""
  for i in $(seq 1 $filled); do bar="${bar}#"; done
  for i in $(seq 1 $empty); do bar="${bar}-"; done
  echo "$bar"
}

# Model name (dim cyan)
printf "\033[36m%s\033[0m" "$model"

# Reasoning effort / thinking budget (dim yellow), if applicable
if [ -n "$effort" ]; then
  printf " \033[33m[effort:%s]\033[0m" "$effort"
elif [ "$thinking_enabled" = "true" ]; then
  printf " \033[33m[thinking]\033[0m"
fi

# Context window usage
if [ -n "$used_pct" ]; then
  bar=$(make_bar "$used_pct")
  used_int=$(printf "%.0f" "$used_pct")
  printf "  ctx \033[33m[%s]\033[0m %s%%" "$bar" "$used_int"
fi

# 5-hour rate limit
if [ -n "$five_pct" ]; then
  bar=$(make_bar "$five_pct")
  five_int=$(printf "%.0f" "$five_pct")
  printf "  5h \033[35m[%s]\033[0m %s%%" "$bar" "$five_int"
fi

# 7-day rate limit
if [ -n "$week_pct" ]; then
  bar=$(make_bar "$week_pct")
  week_int=$(printf "%.0f" "$week_pct")
  printf "  7d \033[35m[%s]\033[0m %s%%" "$bar" "$week_int"
fi

printf "\n"
