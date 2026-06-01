#!/bin/zsh
# Convert each activity image into a 2x2 four-panel comic strip showing the
# four sequential steps (prep → done). One image per activity, generated as
# a single 2x2 composite so the boy + animal stay consistent across panels.
set -uo pipefail
setopt no_nomatch

KEY="$(cat ~/.openai/api_key)"
OUT="${0:A:h}/img"
mkdir -p "$OUT"

REF_SON_1="/Users/mac/Downloads/IMG_0723.jpeg"
REF_SON_2="/Users/mac/Downloads/Screenshot_20260530_080745.jpg"
REF_SHELF="/Users/mac/Downloads/SCR-20260530-hyiq.png"
REF_STEP_1="/Users/mac/Downloads/SCR-20260530-hsxb.png"
REF_STEP_2="/Users/mac/Downloads/SCR-20260530-hsob.png"

BOY="a chubby happy 2-year-old Taiwanese baby boy with short black bowl-cut hair, round rosy cheeks, big dark eyes (use the boy reference photos for his face/hair/skin tone) — the SAME boy must appear in all four panels"

STYLE="Soft pastel watercolour children's picture-book illustration, friendly kawaii style for a 2-year-old, warm cheerful colours, soft glow. The four panels are arranged in a 2×2 grid with thin soft white separator lines between them and a soft circular vignette of pale aqua and seafoam green fading to white at the outer edges. The SAME character design (same boy, same animal friend) is preserved in every panel. Absolutely no text, letters, numbers, captions, or speech bubbles anywhere in the image."

LAYOUT="A four-panel comic strip in a 2×2 grid layout. Read order: top-left → top-right → bottom-left → bottom-right."

# Returns the prompt for a given activity name
build_prompt() {
  local name="$1"
  case "$name" in
    dolphin_school)
      print -- "$LAYOUT Topic: a little boy's morning journey to kindergarten with his cartoon baby dolphin friend. Panel 1 (top-left): the boy at home, putting on his small red school backpack, smiling, the cartoon dolphin (with its own tiny blue school bag) waiting beside him at the front door. Panel 2 (top-right): boy and dolphin walking outside hand-in-flipper down a bright sidewalk with cherry blossoms drifting. Panel 3 (bottom-left): boy and dolphin arriving together at the colourful kindergarten gate (yellow gate with rainbow and sun). Panel 4 (bottom-right): boy and dolphin sitting at small classroom desks, smiling at a kind teacher figure. $BOY. The dolphin must be the same friendly grey cartoon baby dolphin in every panel. $STYLE"
      ;;
    turtle_dinner)
      print -- "$LAYOUT Topic: a little boy and his cartoon baby sea turtle friend eating dinner together. Panel 1 (top-left): both walking toward a small low wooden table, each carrying a colourful bib. Panel 2 (top-right): both sitting down at the table with bibs on, white rice bowls placed in front of them. Panel 3 (bottom-left): both joyfully eating — boy with a spoon, turtle holding chopsticks clumsily, big happy mouths. Panel 4 (bottom-right): empty bowls, boy patting his round full belly, turtle giving a satisfied smile, both looking content. $BOY. The turtle must be the same green-shelled cartoon baby sea turtle in every panel. $STYLE"
      ;;
    whale_bath)
      print -- "$LAYOUT Topic: a little boy and his cartoon baby whale friend playing splash bath together in a kiddie pool. The boy wears a yellow long-sleeved rash-guard swimsuit top and matching shorts in every panel. Panel 1 (top-left): boy and cartoon baby blue whale approaching a small bright-blue plastic kiddie pool, a yellow rubber duck waiting nearby. Panel 2 (top-right): both stepping into the pool together, soap bubbles starting to form. Panel 3 (bottom-left): both happily splashing in a pool full of bubbles, whale's blowhole spouts a tiny fountain. Panel 4 (bottom-right): both stepping out of the pool wrapped in fluffy white towels, smiling and clean. $BOY. The whale must be the same blue cartoon baby whale in every panel. $STYLE"
      ;;
    octopus_sleep)
      print -- "$LAYOUT Topic: a little boy and his cartoon baby pink octopus friend's bedtime routine. The boy wears blue striped pyjamas in every panel. Panel 1 (top-left): boy brushing his teeth at a small bathroom mirror, the small pink octopus next to him also brushing with a tiny toothbrush in one tentacle. Panel 2 (top-right): both sitting in bed reading a small picture-book together. Panel 3 (bottom-left): boy lying down under a fluffy cloud-like white blanket, octopus snuggling beside him with tentacles draped gently. Panel 4 (bottom-right): both fast asleep with closed eyes, soft smiles, tiny stars and Z's floating, warm nightlight glow. $BOY. The octopus must be the same round pink cartoon baby octopus in every panel. $STYLE"
      ;;
    penguin_buttwash)
      print -- "$LAYOUT Topic: a little boy wearing a colourful yellow long-sleeved rash-guard swimsuit top and matching shorts, together with his cartoon baby emperor penguin friend, using a child safety step platform during bath time. The step is a tall green dinosaur-themed kids platform with a central post and a curved white armrest (use the step reference photos). Panel 1 (top-left): boy and penguin walking happily into the bright tiled bathroom carrying small towels. Panel 2 (top-right): boy stepping up onto the green dinosaur safety step, gently holding the curved white armrest for balance, penguin standing beside on its own small matching step. Panel 3 (bottom-left): a gentle handheld shower head sprinkles soft water from above — light playful droplets all around — both giggling, fully clothed in swimsuit, splashes everywhere. Panel 4 (bottom-right): both stepping down, fully wrapped in fluffy white hooded bath towels, beaming clean and dry. $BOY. The penguin must be the same black-and-white round cartoon baby emperor penguin in every panel. $STYLE"
      ;;
    crab_tidy)
      print -- "$LAYOUT Topic: a little boy and his cartoon baby red crab friend tidying up his bedroom — putting books and toys back onto a tall white tree-shaped four-tier kids bookshelf with two yellow star toppers and circular cut-out decorations on the side panels (use the bookshelf reference photo). Panel 1 (top-left): messy bedroom floor scattered with plush toys, books, a teddy bear, a starfish plush; boy looking at the mess with a determined cheerful face, crab beside him. Panel 2 (top-right): boy and crab picking up books and toys from the floor — crab's pincers gently holding a colourful storybook. Panel 3 (bottom-left): both placing books and toys neatly onto the tree-shaped bookshelf. Panel 4 (bottom-right): the room now perfectly tidy, the shelf full, boy and crab high-fiving with proud smiles. $BOY. The crab must be the same red cartoon baby crab in every panel. $STYLE"
      ;;
    seal_dress)
      print -- "$LAYOUT Topic: a little boy and his cartoon baby grey seal friend getting dressed together in a cosy morning bedroom. The boy is always wearing pyjamas or layered clothing in every panel — never bare. A wooden basket of folded clothes and an open wardrobe appear. Panel 1 (top-left): boy in blue striped pyjamas standing beside the open wardrobe with the seal (also in pyjamas), both picking out a colourful daytime outfit. Panel 2 (top-right): boy now wearing a bright orange t-shirt over his pyjama bottoms while pulling on a pair of striped shorts; seal already in matching t-shirt and shorts giving a flipper thumbs-up. Panel 3 (bottom-left): boy buttoning up a small blue cardigan jacket over the orange shirt, seal mirroring with its own matching cardigan. Panel 4 (bottom-right): both fully dressed in matching orange t-shirt, striped shorts and blue cardigan, standing proudly side by side, boy with arms raised in triumph, seal raising one flipper. $BOY. The seal must be the same fluffy grey cartoon baby seal in every panel. $STYLE"
      ;;
  esac
}

# Each activity's reference photos: son refs always + activity-specific extras
refs_for() {
  local name="$1"
  print -- "-F image[]=@$REF_SON_1 -F image[]=@$REF_SON_2"
  case "$name" in
    crab_tidy)         print -- " -F image[]=@$REF_SHELF" ;;
    penguin_buttwash)  print -- " -F image[]=@$REF_STEP_1 -F image[]=@$REF_STEP_2" ;;
  esac
}

generate_one() {
  local name="$1"
  local prompt; prompt=$(build_prompt "$name")
  print -- "→ $name"
  local png="$OUT/${name}.png"
  local jpg="$OUT/${name}.jpg"
  local tmpfile="$(mktemp)"
  # Build curl args as an array so brackets don't get globbed by zsh
  local -a args
  args=(-sS -X POST "https://api.openai.com/v1/images/edits"
        -H "Authorization: Bearer $KEY"
        -F "model=gpt-image-2"
        -F "image[]=@${REF_SON_1}"
        -F "image[]=@${REF_SON_2}")
  case "$name" in
    crab_tidy)
      args+=(-F "image[]=@${REF_SHELF}") ;;
    penguin_buttwash)
      args+=(-F "image[]=@${REF_STEP_1}" -F "image[]=@${REF_STEP_2}") ;;
  esac
  args+=(--form-string "prompt=${prompt}"
         -F "size=1024x1024" -F "quality=high" -F "n=1"
         --max-time 420)
  curl "${args[@]}" > "$tmpfile"
  if grep -q '"error"' "$tmpfile"; then
    print -- "✗ $name: $(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error",{}).get("message","unknown"))' "$tmpfile")"
    rm -f "$tmpfile"
    return 1
  fi
  python3 -c 'import json,sys,base64,pathlib; pathlib.Path(sys.argv[2]).write_bytes(base64.b64decode(json.load(open(sys.argv[1]))["data"][0]["b64_json"]))' "$tmpfile" "$png"
  rm -f "$tmpfile"
  sips -s format jpeg -s formatOptions 88 -Z 1024 "$png" --out "$jpg" >/dev/null
  rm "$png"
  print -- "✓ $name → $(du -h "$jpg" | cut -f1)"
}

all=(dolphin_school turtle_dinner whale_bath octopus_sleep penguin_buttwash crab_tidy seal_dress)

if [ $# -gt 0 ]; then
  names=("$@")
else
  names=("${all[@]}")
fi

print -- "Generating ${#names[@]} comic(s) via gpt-image-2 (quality=high)..."
pids=()
for name in "${names[@]}"; do
  generate_one "$name" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
print -- "Done."
