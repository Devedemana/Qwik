# Static Images

This directory is served at `GET /images/*` by the Express backend.

## Structure

```
public/images/
  cafeterias/     ← cafeteria banner/cover photos
    munchies.jpg
    hallmark.jpg
    the-spot.jpg
  menu/           ← individual food item photos
    stir-fried-chicken.jpg
    prawn-fried-rice.jpg
    indomie-special.jpg
    grilled-tilapia.jpg
    jollof-rice.jpg
    fresh-juice.jpg
    kelewele.jpg
    waakye.jpg
    meat-pie.jpg
```

## Usage

- **Development:** drop images here, they are served from `http://localhost:3001/images/...`
- **Production:** set `IMAGE_BASE_URL=https://your-cdn.com` in your `.env.production`
  file. The seed script and any upload logic will use this base URL automatically.

## Recommended formats

- JPEG for photos (`.jpg`), 800×600px, optimised to < 200 KB
- PNG for logos/icons with transparency
