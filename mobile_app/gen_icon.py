from PIL import Image, ImageDraw, ImageFont
import os, math

# Brand colours
BG       = (139, 58, 16)     # #8B3A10  rust/dark-brown
GOLD     = (255, 215, 0)     # #FFD700  gold
WHITE    = (255, 255, 255)

def make_icon(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── rounded-square background ──────────────────────────────────────────
    radius = size // 5
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=BG)

    # ── bold "Q" centred ───────────────────────────────────────────────────
    # Try to load a bold font; fall back to default if not present
    font = None
    font_size = int(size * 0.58)
    for path in [
        "C:/Windows/Fonts/arialbd.ttf",
        "C:/Windows/Fonts/Arial_Bold.ttf",
        "C:/Windows/Fonts/verdanab.ttf",
    ]:
        if os.path.exists(path):
            try:
                font = ImageFont.truetype(path, font_size)
                break
            except Exception:
                pass
    if font is None:
        font = ImageFont.load_default()

    letter = "Q"
    bbox = draw.textbbox((0, 0), letter, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = (size - tw) / 2 - bbox[0]
    ty = (size - th) / 2 - bbox[1] - size * 0.04   # slight upward nudge

    # shadow
    shadow_offset = max(2, size // 80)
    draw.text((tx + shadow_offset, ty + shadow_offset), letter, font=font,
              fill=(80, 20, 0, 180))
    # main letter
    draw.text((tx, ty), letter, font=font, fill=GOLD)

    # ── speed-slash accent (lightning feel) ────────────────────────────────
    lw = max(2, size // 40)
    x1 = int(size * 0.60)
    y1 = int(size * 0.62)
    x2 = int(size * 0.80)
    y2 = int(size * 0.80)
    draw.line([(x1, y1), (x2, y2)], fill=GOLD, width=lw)

    return img

sizes = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}

base = r"android/app/src/main/res"
for folder, px in sizes.items():
    path = os.path.join(base, folder, "ic_launcher.png")
    icon = make_icon(px)
    icon.save(path)
    print(f"  wrote {path}  ({px}x{px})")

print("Done.")
