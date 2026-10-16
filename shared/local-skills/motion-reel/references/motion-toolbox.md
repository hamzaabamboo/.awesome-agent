# Motion toolbox (Remotion, proven patterns)

Every snippet is a pure function of the frame number. Frames are at 30 fps; a 150 BPM beat is exactly 12 frames, which keeps every cut and hit on integers. Pick a BPM whose beat is a whole number of frames at your fps (30 fps: 150 BPM = 12, 120 BPM = 15, 180 BPM = 10).

## Contents
1. Springs and multi-target tracks
2. Beat grid, hits and the "post" layer (punch, shake, flash)
3. Kinetic type: slam, masked reveal, word pop, sub wipe
4. Real UI shots: crop, frame, fly-in, overlays on exact coordinates
5. Sorter/product mechanics as motion: duel pick, rank climb, gauge sweep, self-sorting bars
6. Background marquee wall that never jumps
7. Transitions: slab wipe, whip, hard cut on the beat
8. Motion blur

## 1. Springs and tracks

```tsx
type Cfg = { damping?: number; stiffness?: number; mass?: number };
const sp = (frame: number, delay: number, { damping = 12, stiffness = 200, mass = 0.7 }: Cfg = {}) =>
  spring({ frame: frame - delay, fps: 30, config: { damping, stiffness, mass } });

const track = (frame: number, keys: [number, number][], cfg?: Cfg) => {
  let v = keys[0][1];
  for (let i = 1; i < keys.length; i++) v += (keys[i][1] - keys[i - 1][1]) * sp(frame, keys[i][0], cfg);
  return v;
};
```

Feel presets: slams on type `damping 12, stiffness 260, mass 0.6` (small overshoot); cards `13 / 170 / 0.8`; stickers `9 / 300 / 0.6` (visible bounce); UI settle `14–20 / 120–180`.

## 2. Beat grid and the post layer

```tsx
const BEAT = 12, DROP = 36;
export const SCENES = [0, 96, 192, 288, 372, 444, 516, 600];
const KICKS = Array.from({ length: (SCENES[6] - DROP) / BEAT }, (_, i) => DROP + i * BEAT);
const HITS = [DROP, ...SCENES.slice(1, -1)];
const since = (f: number, hits: number[]) => hits.reduce((d, h) => (h <= f ? Math.min(d, f - h) : d), Infinity);

const d = since(frame, HITS), k = since(frame, KICKS);
const amp = 10 * Math.exp(-d / 2.5);
const shakeX = (hash(frame) - 0.5) * 2 * amp;
const scale = 1 + 0.035 * Math.exp(-d / 4) + 0.008 * Math.exp(-k / 3);
const flash = d < 3 ? 0.3 * Math.exp(-d / 1.1) : 0;
```

Wrap the scenes (not the background wall) in `translate(shake) scale(scale)`. Put the flash as a `mixBlendMode: 'screen'` layer in the accent colour. Keep shake ≤ 10 px and the flash ≤ 0.35: stronger reads as mush in a contact sheet and made a viewer ask for it to be dialled down.

## 3. Kinetic type

```tsx
const Slam = ({ frame, delay, from = 1.9, children }) => {
  if (frame < delay) return null;
  const s = sp(frame, delay, { damping: 12, stiffness: 260, mass: 0.6 });
  const ca = interpolate(frame - delay, [0, 6], [6, 0], clamp);
  return <div style={{ transform: `scale(${interpolate(s, [0, 1], [from, 1])})`, transformOrigin: 'left center',
    textShadow: ca > 0.3 ? `${-ca}px 0 #3ee0ff, ${ca}px 0 #ff5cbe` : undefined }}>{children}</div>;
};
```

- Headlines: one display face (Anton worked), 130–190 px at 1080p, lines slam 5 frames apart, last line in the accent.
- Chromatic split only during the first 6 frames of a slam. Permanent chroma looks cheap.
- Kicker above each headline: mono face, a filled `NEW` chip + `01 / FEATURE NAME`, slides in from the left.
- Sub line: UI face 32–38 px, muted colour, revealed with `clipPath: inset(0 ${100 - w}% 0 0)` rather than a fade.
- Anton lowercase-free, ~0.45 em per glyph: budget line width as `chars × 0.45 × size` and keep it clear of the UI column.

## 4. Real UI shots

Capture from the running product (see SKILL.md). Crop in physical pixels with ffmpeg first, then place:

```tsx
const Shot = ({ src, width, height, imgWidth, imgHeight, offsetY = 0, children }) => (
  <div style={{ width, height: height ?? (imgHeight * width) / imgWidth, overflow: 'hidden', borderRadius: 24,
    boxShadow: `0 40px 120px #000c, 0 0 0 4px ${PINK}`, position: 'relative' }}>
    <Img src={staticFile(`ui/${src}`)} style={{ position: 'absolute', top: offsetY, width, maxWidth: 'none' }} />
    {children}
  </div>
);
```

- Overlay coordinates (pick rings, ripples, cursor targets) = `(capturePx − cropOffsetPx) × displayWidth / cropWidthPx`. A ring built from the wrong crop offset landed half a card low and was spotted immediately; render a still of every overlay before the full render.
- Tall pages: stack two captures with `ffmpeg vstack` and pan `offsetY` with `Easing.inOut(Easing.cubic)`.
- Cut awkward lines (sample-size disclaimers, stale badges) by cropping and `vstack`-ing the kept bands. Never edit pixels to change what the product says.
- Cursor: an SVG arrow travelling with `inOut(cubic)`, a 5-frame 0.8 scale on click, a ring ripple from the click point.

## 5. Product mechanics as motion

Take the product's own verb and animate it abstractly, then resolve into the real UI.

- **Duel / pick**: two cards rise in, the winner gets a 6 px accent ring + 1.08 scale on the beat, a huge `←` or `→` flashes on the chosen side, the loser drops with rotation.
- **Rank climb**: rows at `top + pos * ROW`, where `pos = track(frame, keysFromStates)`. Build the states with one bubble pass per beat from a shuffled start to the real final order, so items visibly climb; glow rows that moved up on that beat. Use real names and real numbers, then cross-fade into the real leaderboard capture.
- **Gauge sweep**: SVG circle with `strokeDasharray` sweeping to the real value while the number counts up, pop on arrival, then the real compare card.
- **Self-sorting bars**: coloured bars (brand/character colours, icon on top) appear shuffled on the drop and spring into ascending order with a per-rank stagger. It reads as "sorting" instantly.

## 6. Marquee wall that never jumps

```tsx
const offset = frame * 2.5 * (r % 2 ? 1 : -1);
const shift = Math.floor(offset / CELL);
const x = offset - shift * CELL - CELL;
// tile c shows content index (c - shift)
src={staticFile(`icons/${ICONS[Math.floor(hash(r * 31 + (c - shift) * 7) * ICONS.length)]}.png`)}
```

Wrapping the offset with `%` while keeping `content[c]` fixed makes every tile swap icons at the wrap point: the wall visibly jumps. Index content by `c − shift`. Drive it from the global frame, render one wall for the whole film (not one per scene), keep it outside the shake/punch transform, and pulse only its opacity on kicks.

## 7. Transitions

- Hard cuts on the beat are the default (pdoom ENGINE: "Most cuts should be hard cuts on downbeats").
- Slab wipe: a skewed full-height colour block crossing the frame in 12 frames centred on the cut, colour cycling per cut.

```tsx
const p = interpolate(frame, [c - 6, c + 6], [0, 1], clamp);
const x = interpolate(Easing.inOut(Easing.cubic)(p), [0, 1], [-2900, 2900]);
<AbsoluteFill style={{ transform: `translateX(${x}px) skewX(-18deg)` }}>
  <div style={{ position: 'absolute', left: -300, top: -100, width: 2600, height: 1300, background: color }} />
</AbsoluteFill>
```

- Hero cards fly in on springs with 10–14° rotation settling to a slight tilt.

## 8. Motion blur

`@remotion/motion-blur` `<CameraMotionBlur samples={6} shutterAngle={200}>` around the whole picture. It turns slams and whips into streaks. Budget: render time scales with samples; half-scale drafts (`--scale=0.5`) for every critique round, full resolution once.
