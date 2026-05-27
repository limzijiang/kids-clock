#!/bin/zsh
# Generate sea-creature images via gpt-image-2 (zsh for associative arrays + curl for SSL).
set -uo pipefail

KEY="$(cat ~/.openai/api_key)"
OUT="${0:A:h}/img"
mkdir -p "$OUT"

STYLE="soft pastel watercolor children's picture-book illustration, friendly kawaii style for a 2-year-old, very soft circular vignette of pale aqua and seafoam green fading to white at the edges, warm cheerful colours, soft glow, no text or letters anywhere"

typeset -A PROMPTS
PROMPTS[dolphin_school]="An adorable round cartoon baby dolphin smiling brightly, wearing a small red school backpack on its back, swimming forward eagerly. $STYLE"
PROMPTS[turtle_dinner]="An adorable round cartoon baby green sea turtle holding a small white rice bowl with both flippers, happily about to eat, sitting on a small sandy patch. $STYLE"
PROMPTS[whale_bath]="An adorable round cartoon baby blue whale sitting cosily in a tiny white bathtub, soap bubbles all around it, water spout coming out of its blowhole like a shower, big happy smile. $STYLE"
PROMPTS[octopus_sleep]="An adorable round cartoon baby pink octopus sleeping peacefully with closed eyes and a small smile, wearing a tiny striped nightcap, tucked under a fluffy cloud-like blanket, tiny stars and Z floating around. $STYLE"

generate_one() {
  local name="$1"
  local prompt="${PROMPTS[$name]}"
  local body
  body=$(python3 -c 'import json,sys; print(json.dumps({"model":"gpt-image-2","prompt":sys.argv[1],"size":"1024x1024","quality":"medium","output_format":"png","n":1}))' "$prompt")
  local resp
  resp=$(curl -sS -X POST https://api.openai.com/v1/images/generations \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    --max-time 240 \
    -d "$body")
  if print -r -- "$resp" | grep -q '"error"'; then
    print -r -- "✗ $name: $(print -r -- "$resp" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error",{}).get("message","unknown"))')"
    return 1
  fi
  print -r -- "$resp" | python3 -c 'import json,sys,base64,pathlib; d=json.load(sys.stdin); p=pathlib.Path(sys.argv[1]); p.write_bytes(base64.b64decode(d["data"][0]["b64_json"])); print(f"✓ {sys.argv[2]}: {p.stat().st_size//1024} KB")' "$OUT/$name.png" "$name"
}

if [ $# -gt 0 ]; then
  names=("$@")
else
  names=(dolphin_school turtle_dinner whale_bath octopus_sleep)
fi

print -- "Generating ${#names[@]} image(s) in parallel via gpt-image-2..."
pids=()
for name in "${names[@]}"; do
  generate_one "$name" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
print -- "Done."
ls -la "$OUT"/
