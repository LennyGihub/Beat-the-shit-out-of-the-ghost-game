"""The Void Knight's breathing through his mask: an ORIGINAL sound, synthesised (not taken from any film).
A long hissing mechanical inhale ("SUUUUU") and a long, deeper exhale ("SOOOUUU"): shaped noise through narrow
resonances (the mask's tubes), a regulator rasp (a fast flutter), valve clicks and a short metallic echo.
  python3 tools/audio/knight_breath.py   -> knight_breath.wav + spectrogram.png in the current folder
The WAV is kept in the game-art repo (audio/knight_breath.wav); upload it as an Audio asset and put its id in
Shared/Sounds KnightBreath (speed = 1: the breath is already slow).
"""
import numpy as np, wave
SR = 44100
rng = np.random.default_rng(7)
N_FFT, HOP = 2048, 256
freqs = np.fft.rfftfreq(N_FFT, 1 / SR)

def peaks(spec):
    """sum of resonances: (centre Hz, bandwidth Hz, gain)"""
    e = np.zeros_like(freqs)
    for c, bw, g in spec:
        e += g / (1 + ((freqs - c) / (bw / 2)) ** 2)
    return e

# the two breaths: the inhale is a high, hissing "SUUUU" through the tube; the exhale a deeper, rounder "SOOOUUU"
# narrow resonances = the hollow, pipe-like tone of air through the mask's tubes
INHALE = peaks([(1100, 130, 1.0), (1650, 80, 0.5), (2350, 220, 0.75), (3900, 500, 0.3)]) + 0.006
EXHALE = peaks([(480, 90, 1.0), (930, 140, 0.85), (1450, 200, 0.4), (2500, 380, 0.15)]) + 0.004
# no rumble below 150 Hz, and a steep cut above (inhale 5 kHz, exhale 3 kHz)
hp = 1 / (1 + (150 / np.maximum(freqs, 1)) ** 4)
INHALE *= hp / (1 + (freqs / 5000) ** 4); EXHALE *= hp / (1 + (freqs / 3000) ** 4)

T = 4.6
n = int(T * SR)
t = np.arange(n) / SR
# breath shape over time: 0 = silent, which envelope, and its loudness
IN0, IN1 = 0.05, 1.8
EX0, EX1 = 2.2, 4.25
def env(t, a, b, att, rel):
    e = np.clip((t - a) / att, 0, 1) * np.clip((b - t) / rel, 0, 1)
    return e * e * (3 - 2 * e)
e_in = env(t, IN0, IN1, 0.16, 0.32) * (0.9 + 0.1 * np.clip((t - IN0) / (IN1 - IN0), 0, 1))  # swells a little
e_ex = env(t, EX0, EX1, 0.12, 0.45) * 1.0

# overlap-add synthesis of shaped noise (random phase every frame), a blend of the two spectra by time
out = np.zeros(n + N_FFT)
win = np.hanning(N_FFT)
for start in range(0, n, HOP):
    mid = min(n - 1, start + N_FFT // 2)
    wi, we = e_in[mid], e_ex[mid]
    if wi + we < 1e-4:
        continue
    # the exhale's resonances slide down a little as it goes (the breath running out)
    k = np.clip((t[mid] - EX0) / (EX1 - EX0), 0, 1)
    ex = np.interp(freqs * (1 + 0.12 * k), freqs, EXHALE)
    mag = np.sqrt(wi * INHALE + we * ex) * (wi + we)
    ph = rng.uniform(0, 2 * np.pi, len(freqs))
    frame = np.fft.irfft(mag * np.exp(1j * ph), N_FFT) * win
    out[start:start + N_FFT] += frame
y = out[:n]
# the regulator's rasp: a fast flutter on the loudness, stronger on the exhale
flutter = 1 + 0.16 * np.sin(2 * np.pi * 23 * t) * (e_in > 0.05) + 0.24 * np.sin(2 * np.pi * 19 * t + 1.3) * (e_ex > 0.05)
y *= flutter
# a faint whistle in the inhale (air through the grill)
y += 0.008 * np.sin(2 * np.pi * (1520 + 12 * np.sin(2 * np.pi * 5 * t)) * t) * e_in * np.std(y[(t > 0.5) & (t < 1.5)]) * 25
# valve clicks at the start of each breath
for at in (IN0, EX0 - 0.04):
    i0 = int(at * SR); L = int(0.012 * SR)
    click = rng.normal(0, 1, L) * np.exp(-np.arange(L) / (0.0025 * SR))
    y[i0:i0 + L] += click * np.std(y) * 2.5
# the mask: a short metallic echo inside the helmet (comb, ~2.3 ms) and a second one (~5.1 ms)
h = np.zeros(int(0.03 * SR)); h[0] = 1
for d, g in ((int(0.0023 * SR), 0.45), (int(0.0051 * SR), 0.25)):
    for k2 in range(1, 6):
        if d * k2 < len(h): h[d * k2] += g ** k2
y = np.convolve(y, h)[:n]
y /= np.max(np.abs(y)) / 0.89
pcm = (y * 32767).astype(np.int16)
with wave.open("knight_breath.wav", "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print("wrote knight_breath.wav", f"{T}s")
# spectrogram for a look
from PIL import Image
S = []
for start in range(0, n - 1024, 256):
    S.append(np.abs(np.fft.rfft(y[start:start + 1024] * np.hanning(1024)))[:240])
S = 20 * np.log10(np.array(S).T + 1e-6); S = np.clip((S - S.max() + 45) / 45, 0, 1)
img = Image.fromarray((S[::-1] * 255).astype(np.uint8)).resize((900, 300))
img.save("spectrogram.png"); print("0-10 kHz spectrogram saved")

def band(a, b):
    seg = y[int(a * SR):int(b * SR)]
    sp = np.abs(np.fft.rfft(seg * np.hanning(len(seg)))) ** 2
    f = np.fft.rfftfreq(len(seg), 1 / SR)
    out = []
    for lo, hi in ((100, 300), (300, 600), (600, 1300), (1300, 2000), (2000, 3000), (3000, 5000), (5000, 9000)):
        out.append(f"{lo}-{hi}Hz:{10 * np.log10(sp[(f >= lo) & (f < hi)].mean() + 1e-12):.0f}")
    return " ".join(out)
print("inhale dB:", band(0.5, 1.5)); print("exhale dB:", band(2.6, 3.8))
