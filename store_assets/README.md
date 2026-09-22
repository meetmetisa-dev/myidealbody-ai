# Google Play graphic assets

These graphics extend the existing MyIdealBody AI leaf mark and color palette. They are prepared for the current development beta and make no claim that production photo recognition is live.

## Ready-to-upload files

| File | Purpose | Dimensions | PNG color type | Size | Play limit |
| --- | --- | ---: | --- | ---: | ---: |
| `play-icon-512.png` | Store listing app icon | 512 × 512 px | 8-bit/channel RGBA (32-bit, alpha channel present) | 16,885 bytes | 1,048,576 bytes |
| `feature-graphic-1024x500.png` | Store listing feature graphic | 1024 × 500 px | 8-bit/channel RGB (24-bit, no alpha) | 49,250 bytes | 15,728,640 bytes |

SHA-256 checksums:

```text
4c60ca67f4ea5a68e6ac4566ae7c16beb689e5c3460c48d9c356a302f940c89a  play-icon-512.png
365ab7a39242daac2eb35a4aec474aa233bc3bb9ebced29a129164abedb3dfb3  feature-graphic-1024x500.png
```

## Editable sources

- `play-icon-source.svg` is full-bleed and square. It has no manually rounded outer corners and no baked outer shadow; Google Play can apply the device mask. The leaf artwork stays near the center so common icon masks do not cut it off.
- `feature-graphic-source.svg` is a purpose-built brand graphic, not an app screenshot. Critical copy remains in the left safe area (approximately x=74–580 and y=79–405), away from the canvas edges. The raster export is flattened and contains no alpha channel.

The icon's alpha channel is fully opaque in this export. Keeping the RGBA color type satisfies the 32-bit PNG format while the full-bleed background avoids unintended transparent corners.

## Re-export

The PNGs were rasterized from the SVG sources with Sharp at their exact target sizes, with PNG palette conversion disabled. Preserve RGBA for the icon and flatten/remove alpha for the feature graphic.

After any source edit, validate at least:

```text
play-icon-512.png:              512 × 512, RGBA, <= 1 MiB
feature-graphic-1024x500.png:  1024 × 500, RGB,  <= 15 MiB
```

Google Play specifications: [Add preview assets to showcase your app](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-GB).

## Still required for a Play listing

No app screenshots were invented for this asset set. Capture real screenshots from the final release build after production behavior, disclosures, and copy are stable. A feature graphic is not a substitute for the required phone screenshots.
