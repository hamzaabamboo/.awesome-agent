import math, random, struct, sys, wave

SR = 44100
FPS = 30
N = int(SR * 20.0)
BEAT = 12
EIGHTH = BEAT / 2
BAR = BEAT * 4
KEY = 2
THEME = 36
VERSE = THEME + BAR * 2
PRE = VERSE + BAR * 4
CHORUS = PRE + BAR * 2
FINAL = CHORUS + BAR * 2
random.seed(3)

drums = [0.0] * N
music = [0.0] * N
voice = [0.0] * N
duck = [1.0] * N


def at(frame):
    return int(frame / FPS * SR)


def add(bus, start, samples, gain):
    for i, s in enumerate(samples):
        j = start + i
        if 0 <= j < N:
            bus[j] += s * gain


def hz(semi):
    return 261.63 * 2 ** ((semi + KEY) / 12)


def saw(t, f):
    return ((f * t) % 1.0) * 2 - 1


def kick():
    out, ph = [], 0.0
    for i in range(int(SR * 0.28)):
        t = i / SR
        ph += 2 * math.pi * (50 + 150 * math.exp(-t * 45)) / SR
        out.append(math.tanh(math.sin(ph) * math.exp(-t * 10) * 2))
    return out


def noise_hit(length, decay, tone=0.0, tf=200):
    out, prev = [], 0.0
    for i in range(int(SR * length)):
        t = i / SR
        n = random.uniform(-1, 1)
        hp = n - prev
        prev = n
        out.append((hp * (1 - tone) + math.sin(2 * math.pi * tf * t) * tone) * math.exp(-t * decay))
    return out


def clap():
    out = []
    for i in range(int(SR * 0.2)):
        t = i / SR
        e = sum(math.exp(-(t - d) * 50) for d in (0, 0.008, 0.017) if t >= d)
        out.append(random.uniform(-1, 1) * e * 0.5)
    return out


def orch_hit(notes, length=0.8):
    freqs = [hz(n) * d for n in notes for d in (0.996, 1.004)]
    out, lp = [], 0.0
    for i in range(int(SR * length)):
        t = i / SR
        s = sum(saw(t, f) for f in freqs) / len(freqs)
        lp += (s - lp) * (0.45 * math.exp(-t * 5) + 0.04)
        out.append(lp * math.exp(-t * 4) + random.uniform(-1, 1) * math.exp(-t * 45) * 0.3)
    return out


def pad(notes, length, cutoff=0.06):
    freqs = [hz(n) * d for n in notes for d in (0.997, 1.003)]
    offs = [random.random() for _ in freqs]
    out, lp = [], 0.0
    for i in range(int(SR * length)):
        t = i / SR
        s = sum(((f * t + o) % 1.0) * 2 - 1 for f, o in zip(freqs, offs)) / len(freqs)
        lp += (s - lp) * cutoff
        out.append(lp * min(1, t / 0.12) * min(1, (length - t) / 0.06))
    return out


def piano(notes, length):
    out = []
    for i in range(int(SR * length)):
        t = i / SR
        s = sum(math.sin(2 * math.pi * hz(n) * t) + 0.4 * math.sin(4 * math.pi * hz(n) * t) * math.exp(-t * 6) for n in notes) / len(notes)
        out.append(s * math.exp(-t * 3) * min(1, t * 400) * min(1, (length - t) * 30))
    return out


def stab(notes, length=0.14):
    freqs = [hz(n) * d for n in notes for d in (0.995, 1.005)]
    out = []
    for i in range(int(SR * length)):
        t = i / SR
        out.append(sum(saw(t, f) for f in freqs) / len(freqs) * math.exp(-t * 14) * min(1, t * 500))
    return out


def bass(semi, length):
    f = hz(semi)
    out = []
    for i in range(int(SR * length)):
        t = i / SR
        s = math.sin(2 * math.pi * f * t) + 0.25 * saw(t, f)
        out.append(math.tanh(s * 1.4) * math.exp(-t * 4) * min(1, t * 300) * min(1, (length - t) * 60))
    return out


def lead(semi, length, bright=0.5):
    f = hz(semi)
    out, lp = [], 0.0
    for i in range(int(SR * length)):
        t = i / SR
        vib = 1 + 0.006 * math.sin(2 * math.pi * 5.2 * t) * min(1, max(0, t - 0.12) * 4)
        raw = saw(t, f * vib) * 0.6 + saw(t, f * vib * 1.004) * 0.4
        lp += (raw - lp) * (0.12 + 0.25 * bright)
        s = lp * 0.8 + math.sin(2 * math.pi * f * vib * t) * 0.5
        out.append(s * min(1, t * 80) * min(1, (length - t) * 25))
    return out


C, G, AM, EM, F, DM, G7 = [0, 4, 7], [-5, -1, 2], [-3, 0, 4], [-8, -5, -1], [-7, -3, 0], [-10, -7, -3], [-5, -1, 2, 5]
HOOK = [(0, 16, 1), (1, 16, 1), (2, 14, 1), (3, 12, 1), (4, 14, 1), (5, 16, 1), (6, 19, 2),
        (8, 16, 1), (9, 14, 1), (10, 12, 1), (11, 14, 1), (12, 16, 3), (15, 12, 1)]
VERSE_MEL = [(0, 7, 2), (2, 9, 1), (3, 12, 1), (4, 11, 2), (6, 7, 2),
             (8, 9, 2), (10, 12, 1), (11, 11, 1), (12, 7, 4),
             (16, 5, 2), (18, 9, 1), (19, 12, 1), (20, 12, 2), (22, 7, 2),
             (24, 9, 2), (26, 5, 1), (27, 4, 1), (28, 2, 2), (30, 7, 2)]
PRE_MEL = [(0, 9, 1), (1, 12, 1), (2, 14, 2), (4, 12, 1), (5, 14, 1), (6, 16, 2),
           (8, 14, 1), (9, 16, 1), (10, 17, 2), (12, 19, 4)]

THEME_CH = [F, G, EM, AM]
VERSE_CH = [C, G, AM, EM, F, C, DM, G]
PRE_CH = [F, G, G7, G7]
CHORUS_CH = [F, G, EM, AM]


def melody(start, notes, gain, octave=0, bright=0.5):
    for step, semi, dur in notes:
        add(voice, at(start + step * EIGHTH), lead(semi + octave, dur * EIGHTH / FPS * 0.97, bright), gain)


def chords(start, prog, style):
    for n, ch in enumerate(prog):
        f = start + n * BEAT * 2
        length = BEAT * 2 / FPS
        base = min(ch) - 12
        if style in ('full', 'pre'):
            add(music, at(f), pad([x + 12 for x in ch], length, 0.05 if style == 'pre' else 0.07), 0.22)
        if style == 'verse':
            add(music, at(f), piano([x + 12 for x in ch], length), 0.28)
            add(music, at(f + BEAT), piano([x + 12 for x in ch], length / 2), 0.18)
        for e in range(4):
            g = f + e * EIGHTH
            if style == 'verse':
                if e % 2 == 0:
                    add(music, at(g), bass(base - 12, BEAT / FPS), 0.45)
            else:
                add(music, at(g), bass(base - 12 + (12 if e % 2 else 0), EIGHTH / FPS), 0.42)
                if style == 'full' and e % 2 == 1:
                    add(music, at(g), stab([x + 12 for x in ch]), 0.2)


K, CL = kick(), clap()
HAT = noise_hit(0.05, 140)
OHAT = noise_hit(0.14, 28)
SNARE = noise_hit(0.14, 26, 0.3, 190)

add(drums, at(0), orch_hit([-12, 0, 4, 7]), 0.5)
add(drums, at(6), orch_hit([-10, 2, 5, 9]), 0.5)
add(drums, at(12), orch_hit([-8, 4, 7, 11]), 0.55)
add(music, at(14), pad([-5, -1, 2, 5, 7], (THEME - 14) / FPS, 0.03), 0.3)
for k in range(8):
    add(drums, at(20 + k * 2), SNARE, 0.1 + k * 0.05)

chords(THEME, THEME_CH, 'full')
melody(THEME, HOOK, 0.2, 12, 0.7)
add(drums, at(THEME), orch_hit([-7, 5, 9, 12]), 0.45)

chords(VERSE, VERSE_CH, 'verse')
melody(VERSE, VERSE_MEL, 0.22, 12, 0.35)

chords(PRE, PRE_CH, 'pre')
melody(PRE, PRE_MEL, 0.22, 12, 0.5)
for k in range(8):
    add(drums, at(PRE + BAR + BEAT * 2 + k * EIGHTH / 2), SNARE, 0.12 + k * 0.06)

chords(CHORUS, CHORUS_CH, 'full')
melody(CHORUS, HOOK, 0.22, 12, 0.75)
melody(CHORUS, HOOK, 0.08, 24, 0.75)
add(drums, at(CHORUS), orch_hit([-7, 5, 9, 12]), 0.5)

for f in range(THEME, FINAL, BEAT):
    in_verse = VERSE <= f < PRE
    add(drums, at(f), K, 0.95 if not in_verse else 0.8)
    for i in range(int(SR * 0.16)):
        j = at(f) + i
        if j < N:
            duck[j] = min(duck[j], 0.45 + 0.55 * (i / (SR * 0.16)) ** 1.3)
    beat_i = (f - THEME) // BEAT
    if beat_i % 2 == 1 and not (in_verse and f < VERSE + BAR * 2):
        add(drums, at(f), CL, 0.5)
    add(drums, at(f + EIGHTH), OHAT if not in_verse else HAT, 0.1 if not in_verse else 0.12)
    add(drums, at(f), HAT, 0.05)

add(drums, at(FINAL), K, 1.0)
add(drums, at(FINAL), orch_hit([-12, 0, 4, 7, 12]), 0.55)
add(music, at(FINAL), pad([0, 4, 7, 12, 16], 2.3, 0.08), 0.35)
add(music, at(FINAL), bass(-24, 2.0), 0.5)
melody(FINAL, [(0, 19, 1), (1, 21, 1), (2, 24, 8)], 0.2, 0, 0.7)

delay = int(SR * EIGHTH * 3 / FPS)
for i in range(delay, N):
    voice[i] += voice[i - delay] * 0.28

mix = [d + m * k + v * (0.75 + 0.25 * k) for d, m, v, k in zip(drums, music, voice, duck)]
fade = at(575)
for i in range(fade, N):
    mix[i] *= max(0.0, 1 - (i - fade) / (N - fade))

peak = max(abs(s) for s in mix)
with wave.open(sys.argv[1] if len(sys.argv) > 1 else 'beat.wav', 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(b''.join(struct.pack('<h', int(math.tanh(s / peak * 1.5) / math.tanh(1.5) * 30000)) for s in mix))
