#!/bin/zsh
# Generate cute kid-friendly voice clips via OpenAI gpt-4o-mini-tts.
set -uo pipefail

KEY="$(cat ~/.openai/api_key)"
OUT="${0:A:h}/audio"
mkdir -p "$OUT"

VOICE="nova"     # younger, peppy, kid-friendly female voice
INSTRUCTION="Speak with a warm, cheerful, slightly higher-pitched voice — like a kind preschool teacher or a children's TV show host reading to a 2-year-old. Use gentle natural pauses, lots of warmth, and a sing-song lilt. Sound excited but soft, never harsh."

clips=(
  "school_zh|林盟，現在是上學時間！"
  "school_en|Lim Meng, it's school time!"
  "dinner_zh|林盟，現在是吃飯時間！"
  "dinner_en|Lim Meng, it's dinner time!"
  "bath_zh|林盟，現在是洗澡時間！"
  "bath_en|Lim Meng, it's bath time!"
  "sleep_zh|林盟，現在是睡覺時間囉！"
  "sleep_en|Lim Meng, it's sleep time."
  "buttwash_zh|林盟，現在是洗屁股時間！"
  "buttwash_en|Lim Meng, it's bottom-washing time!"
)

generate_one() {
  local name="$1" text="$2"
  local body
  body=$(python3 -c 'import json,sys; print(json.dumps({"model":"gpt-4o-mini-tts","input":sys.argv[1],"voice":sys.argv[2],"instructions":sys.argv[3],"response_format":"mp3"}))' "$text" "$VOICE" "$INSTRUCTION")
  curl -sS -X POST https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    --max-time 90 \
    -d "$body" \
    -o "$OUT/$name.mp3"
  local size
  size=$(stat -f%z "$OUT/$name.mp3" 2>/dev/null || echo 0)
  if [ "$size" -lt 1000 ]; then
    print -r -- "✗ $name: body ${size}b → $(cat "$OUT/$name.mp3" | head -c 300)"
    return 1
  fi
  print -r -- "✓ $name: $((size / 1024)) KB"
}

if [ $# -gt 0 ]; then
  filter=("$@")
  selected=()
  for entry in "${clips[@]}"; do
    nm=${entry%%|*}
    for w in "${filter[@]}"; do
      if [[ "$nm" == *"$w"* ]]; then selected+=("$entry"); break; fi
    done
  done
  clips=("${selected[@]}")
fi

print -- "Generating ${#clips[@]} clip(s) in parallel via gpt-4o-mini-tts (voice=$VOICE)..."
pids=()
for entry in "${clips[@]}"; do
  name=${entry%%|*}
  text=${entry##*|}
  generate_one "$name" "$text" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
print -- "Done."
ls -la "$OUT"/ 2>/dev/null
