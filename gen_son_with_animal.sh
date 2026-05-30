#!/bin/zsh
# Regenerate the 4 activity images so they all feature Lim Meng together
# with the matching sea creature. Uses gpt-image-2 /v1/images/edits with
# the two son reference photos to keep his face consistent.
set -uo pipefail

KEY="$(cat ~/.openai/api_key)"
OUT="${0:A:h}/img"
mkdir -p "$OUT"

REF_SON_1="/Users/mac/Downloads/IMG_0723.jpeg"
REF_SON_2="/Users/mac/Downloads/Screenshot_20260530_080745.jpg"

STYLE="soft pastel watercolour children's picture-book illustration, friendly kawaii style for a 2-year-old, very soft circular vignette of pale aqua and seafoam green fading to white at the edges, warm cheerful colours, soft glow, no text or letters anywhere."

BOY="a chubby happy 2-year-old Taiwanese baby boy with short black bowl-cut hair, round rosy cheeks, big dark eyes and a bright smile (use the boy reference photos for his face / hair / skin tone)"

prompts=(
  "dolphin_school|Adorable scene: $BOY walking happily to school holding the flipper of a cheerful round cartoon baby dolphin friend; the boy wears a small red school backpack; the dolphin carries its own tiny blue school bag. They are stepping together along a bright morning sidewalk with cherry blossoms drifting around. $STYLE"
  "turtle_dinner|Adorable scene: $BOY and a tiny adorable round cartoon baby green sea turtle sitting together at a small low wooden table, both wearing colourful bibs, eating from small white bowls of warm rice — the boy holding a spoon, the turtle holding chopsticks clumsily, both with big happy giggling faces. $STYLE"
  "whale_bath|Adorable scene: $BOY and a small adorable round cartoon baby blue whale sharing a cosy round white bathtub full of soap bubbles, both grinning brightly. The whale has a gentle water spout coming from its blowhole like a tiny fountain. A yellow rubber duck floats nearby. The boy wears a small white towel cap. $STYLE"
  "octopus_sleep|Adorable scene: $BOY snuggled in a small cosy bed under a fluffy cloud-like white blanket, sleeping peacefully with closed eyes and a small smile, hugging a small round cartoon pink baby octopus that is also asleep with its tentacles draped gently around him like a soft hug. Tiny stars and a few Z's float in the air, a warm bedside nightlight glows. $STYLE"
)

generate_one() {
  local name="$1" prompt="$2"
  print -- "→ generating $name ..."
  local resp
  resp=$(curl -sS -X POST https://api.openai.com/v1/images/edits \
    -H "Authorization: Bearer $KEY" \
    -F "model=gpt-image-2" \
    -F "image[]=@$REF_SON_1" \
    -F "image[]=@$REF_SON_2" \
    -F "prompt=$prompt" \
    -F "size=1024x1024" \
    -F "quality=medium" \
    -F "n=1" \
    --max-time 300)
  if print -r -- "$resp" | grep -q '"error"'; then
    print -r -- "✗ $name: $(print -r -- "$resp" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error",{}).get("message","unknown"))')"
    return 1
  fi
  local png="$OUT/${name}.png"
  print -r -- "$resp" | python3 -c 'import json,sys,base64,pathlib; pathlib.Path(sys.argv[1]).write_bytes(base64.b64decode(json.load(sys.stdin)["data"][0]["b64_json"]))' "$png"
  # Compress: 800px JPEG quality 85
  local jpg="$OUT/${name}.jpg"
  sips -s format jpeg -s formatOptions 85 -Z 800 "$png" --out "$jpg" >/dev/null
  rm "$png"
  print -- "✓ $name → $(du -h "$jpg" | cut -f1)"
}

if [ $# -gt 0 ]; then
  filter=("$@")
  selected=()
  for entry in "${prompts[@]}"; do
    nm=${entry%%|*}
    for w in "${filter[@]}"; do
      if [[ "$nm" == *"$w"* ]]; then selected+=("$entry"); break; fi
    done
  done
  prompts=("${selected[@]}")
fi

print -- "Generating ${#prompts[@]} image(s) in parallel via gpt-image-2 /v1/images/edits..."
pids=()
for entry in "${prompts[@]}"; do
  name=${entry%%|*}
  prompt=${entry##*|}
  generate_one "$name" "$prompt" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
print -- "Done."
ls -la "$OUT"/*.jpg
