#!/bin/zsh
# Generate the manual-only "洗屁股 / Butt Wash" illustration using OpenAI
# gpt-image-2 with reference images (son + step platform).
set -uo pipefail

KEY="$(cat ~/.openai/api_key)"
OUT="${0:A:h}/img"
mkdir -p "$OUT"

REF_SON_1="/Users/mac/Downloads/IMG_0723.jpeg"
REF_SON_2="/Users/mac/Downloads/Screenshot_20260530_080745.jpg"
REF_STEP_1="/Users/mac/Downloads/SCR-20260530-hsxb.png"
REF_STEP_2="/Users/mac/Downloads/SCR-20260530-hsob.png"

PROMPT="Adorable round cartoon scene for a 2-year-old's clock app: a chubby happy Taiwanese baby boy with short black bowl-cut hair, round rosy cheeks and big dark eyes (use the boy reference photos for his face/hair/skin tone), smiling brightly. He is standing on a green dinosaur-themed kids bathroom safety step — a tall platform with a central post and a curved white armrest he is gently holding onto for balance (use the step product reference). Next to him stands a small adorable round cartoon baby emperor penguin, smiling along, on its own matching tiny step. Behind them, a gentle handheld shower head sprays soft water onto both of their bottoms (no nudity beyond a cartoon back/diaper view — keep it innocent like a children's picture book). Both have big happy giggling faces. Soft pastel watercolour children's picture-book illustration, kawaii style, soft circular vignette of pale aqua and seafoam green fading to white at the edges, warm cheerful colours, soft glow, no text or letters anywhere."

OUTFILE="$OUT/penguin_buttwash.png"

print -- "Calling gpt-image-2 /v1/images/edits with 4 reference images..."
resp=$(curl -sS -X POST https://api.openai.com/v1/images/edits \
  -H "Authorization: Bearer $KEY" \
  -F "model=gpt-image-2" \
  -F "image[]=@$REF_SON_1" \
  -F "image[]=@$REF_SON_2" \
  -F "image[]=@$REF_STEP_1" \
  -F "image[]=@$REF_STEP_2" \
  -F "prompt=$PROMPT" \
  -F "size=1024x1024" \
  -F "quality=medium" \
  -F "n=1" \
  --max-time 300)

if print -r -- "$resp" | grep -q '"error"'; then
  print -r -- "✗ Error: $(print -r -- "$resp" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error",{}).get("message","unknown"))')"
  exit 1
fi

print -r -- "$resp" | python3 -c 'import json,sys,base64,pathlib; d=json.load(sys.stdin); p=pathlib.Path(sys.argv[1]); p.write_bytes(base64.b64decode(d["data"][0]["b64_json"])); print(f"✓ saved {p}: {p.stat().st_size//1024} KB")' "$OUTFILE"

# Downscale + JPEG
JPG="$OUT/penguin_buttwash.jpg"
sips -s format jpeg -s formatOptions 85 -Z 800 "$OUTFILE" --out "$JPG" >/dev/null
rm "$OUTFILE"
print -- "✓ compressed to $(du -h "$JPG" | cut -f1) at $JPG"
