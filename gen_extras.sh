#!/bin/zsh
# Generate two new manual-only popup illustrations:
#   crab_tidy   — Lim Meng + crab tidying up on the tree-shaped bookshelf
#   seal_dress  — Lim Meng + seal cheerfully getting dressed
set -uo pipefail

KEY="$(cat ~/.openai/api_key)"
OUT="${0:A:h}/img"
mkdir -p "$OUT"

REF_SON_1="/Users/mac/Downloads/IMG_0723.jpeg"
REF_SON_2="/Users/mac/Downloads/Screenshot_20260530_080745.jpg"
REF_SHELF="/Users/mac/Downloads/SCR-20260530-hyiq.png"

STYLE="soft pastel watercolour children's picture-book illustration, friendly kawaii style for a 2-year-old, very soft circular vignette of pale aqua and seafoam green fading to white at the edges, warm cheerful colours, soft glow, no text or letters anywhere."

BOY="a chubby happy 2-year-old Taiwanese baby boy with short black bowl-cut hair, round rosy cheeks, big dark eyes and a bright smile (use the boy reference photos for his face / hair / skin tone)"

# Use 3 refs for the tidy one (son x2 + bookshelf), 2 refs for the dress one (son x2)

gen_tidy() {
  local prompt="Adorable cosy scene: $BOY happily putting picture books back onto a tall white tree-shaped four-tier kids bookshelf (the shelf is shaped like a stylised tree with two yellow star toppers and circular cut-out decorations on the side panels — use the bookshelf reference). A small cheerful round cartoon baby red crab friend stands next to him, helpfully holding a colourful storybook in one of its claws and a small soft toy in the other. A few scattered plush toys and books on the floor are being gathered up. Bright tidy bedroom. $STYLE"
  print -- "→ generating crab_tidy ..."
  local resp
  resp=$(curl -sS -X POST https://api.openai.com/v1/images/edits \
    -H "Authorization: Bearer $KEY" \
    -F "model=gpt-image-2" \
    -F "image[]=@$REF_SON_1" \
    -F "image[]=@$REF_SON_2" \
    -F "image[]=@$REF_SHELF" \
    -F "prompt=$prompt" \
    -F "size=1024x1024" -F "quality=medium" -F "n=1" \
    --max-time 300)
  if print -r -- "$resp" | grep -q '"error"'; then
    print -r -- "✗ crab_tidy: $(print -r -- "$resp" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error",{}).get("message","unknown"))')"
    return 1
  fi
  local png="$OUT/crab_tidy.png"
  print -r -- "$resp" | python3 -c 'import json,sys,base64,pathlib; pathlib.Path(sys.argv[1]).write_bytes(base64.b64decode(json.load(sys.stdin)["data"][0]["b64_json"]))' "$png"
  sips -s format jpeg -s formatOptions 85 -Z 800 "$png" --out "$OUT/crab_tidy.jpg" >/dev/null
  rm "$png"
  print -- "✓ crab_tidy → $(du -h "$OUT/crab_tidy.jpg" | cut -f1)"
}

gen_dress() {
  local prompt="Adorable cheerful morning scene: $BOY standing happily in a cosy bedroom, already wearing a bright orange t-shirt, in the middle of pulling up a colourful pair of striped shorts. Next to him stands a small adorable round cartoon baby seal friend who is fully dressed in a matching orange t-shirt and striped shorts, modelling the outfit with a big proud smile and one flipper raised. A small wooden basket of folded clothes sits nearby. Both have big encouraging happy faces — the seal acts as the role model showing dressing is fun. Soft morning sunlight through a window. $STYLE"
  print -- "→ generating seal_dress ..."
  local resp
  resp=$(curl -sS -X POST https://api.openai.com/v1/images/edits \
    -H "Authorization: Bearer $KEY" \
    -F "model=gpt-image-2" \
    -F "image[]=@$REF_SON_1" \
    -F "image[]=@$REF_SON_2" \
    -F "prompt=$prompt" \
    -F "size=1024x1024" -F "quality=medium" -F "n=1" \
    --max-time 300)
  if print -r -- "$resp" | grep -q '"error"'; then
    print -r -- "✗ seal_dress: $(print -r -- "$resp" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error",{}).get("message","unknown"))')"
    return 1
  fi
  local png="$OUT/seal_dress.png"
  print -r -- "$resp" | python3 -c 'import json,sys,base64,pathlib; pathlib.Path(sys.argv[1]).write_bytes(base64.b64decode(json.load(sys.stdin)["data"][0]["b64_json"]))' "$png"
  sips -s format jpeg -s formatOptions 85 -Z 800 "$png" --out "$OUT/seal_dress.jpg" >/dev/null
  rm "$png"
  print -- "✓ seal_dress → $(du -h "$OUT/seal_dress.jpg" | cut -f1)"
}

if [ $# -gt 0 ]; then
  for w in "$@"; do
    case "$w" in
      tidy|crab) gen_tidy & ;;
      dress|seal) gen_dress & ;;
    esac
  done
else
  gen_tidy &
  gen_dress &
fi
wait
print -- "Done."
