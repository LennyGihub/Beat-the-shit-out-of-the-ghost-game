"""The Void Knight's breathing through his mask: an ORIGINAL sound, synthesised (not taken from any film).
It imitates a breath through a scuba-style regulator, not a man's breath:
  INHALE "SUUUUUUU" (~3.3 s): a high, whistling mechanical hiss through the demand valve (no vowel-like low
    resonances), brightening as it goes, cut off sharply when the valve shuts;
  EXHALE "SOOOOUUUU" (~3.75 s): deep and buzzing, the exhaust valve rattling (pulsed noise), a low rumble under it;
  a clunk as the valve opens, a tick before the exhale, and the metallic echo of a helmet around everything.
  python3 tools/audio/knight_breath.py [out_dir]   -> knight_breath.wav + spectrogram.png
The WAV is kept in the game-art repo (audio/knight_breath.wav); upload it as an Audio asset and put its id in
Shared/Sounds KnightBreath (speed = 1: the breath is already slow).
"""
import sys, os, wave
import numpy as np

SR = 44100
OUT = sys.argv[1] if len(sys.argv) > 1 else "."
rng = np.random.default_rng(11)
N_FFT, HOP = 2048, 256
freqs = np.fft.rfftfreq(N_FFT, 1 / SR)

def peaks(spec):
    e = np.zeros_like(freqs)
    for c, bw, g in spec:
        e += g / (1 + ((freqs - c) / (bw / 2)) ** 2)
    return e
def hipass(fc, p=4): return 1 / (1 + (fc / np.maximum(freqs, 1)) ** p)
def lopass(fc, p=4): return 1 / (1 + (freqs / fc) ** p)

# INHALE: air hissing in through the valve: high, narrow resonances (the whistle of the regulator)
INHALE = (peaks([(2100, 150, 1.0), (3300, 260, 0.7), (5200, 650, 0.35), (1500, 120, 0.25)]) + 0.01) * hipass(1200) * lopass(8000)
# EXHALE: pushed out through the exhaust: deep, a low rumble, no high hiss
EXHALE = (peaks([(180, 80, 0.55), (420, 120, 1.0), (780, 160, 0.8), (1250, 260, 0.4), (2100, 420, 0.12)]) + 0.004) * hipass(90) * lopass(3200)

IN0, IN1 = 0.06, 3.4
EX0, EX1 = 3.85, 7.6
T = 8.6
n = int(T * SR)
t = np.arange(n) / SR
def env(a, b, att, rel):
    up = np.clip((t - a) / att, 0, 1); down = np.clip((b - t) / rel, 0, 1)
    return (up * up * (3 - 2 * up)) * down
e_in = env(IN0, IN1, 0.28, 0.1) * (0.8 + 0.2 * np.clip((t - IN0) / (IN1 - IN0), 0, 1))
e_ex = env(EX0, EX1, 0.2, 0.32) * (1.0 - 0.15 * np.clip((t - EX0) / (EX1 - EX0), 0, 1))

out = np.zeros(n + N_FFT)
win = np.hanning(N_FFT)
for start in range(0, n, HOP):
    mid = min(n - 1, start + N_FFT // 2)
    wi, we = e_in[mid], e_ex[mid]
    if wi + we < 1e-4:
        continue
    ki = np.clip((t[mid] - IN0) / (IN1 - IN0), 0, 1)
    ke = np.clip((t[mid] - EX0) / (EX1 - EX0), 0, 1)
    inh = np.interp(freqs / (1 + 0.07 * ki), freqs, INHALE)  # the hiss rises as the lungs fill
    exh = np.interp(freqs * (1 + 0.1 * ke), freqs, EXHALE)   # the exhale sinks as it empties
    mag = np.sqrt(wi * inh + we * exh) * (wi + we)
    frame = np.fft.irfft(mag * np.exp(1j * rng.uniform(0, 2 * np.pi, len(freqs))), N_FFT) * win
    out[start:start + N_FFT] += frame
y = out[:n]
# loudness of each breath evened out (the hiss is quieter than the rumble in raw energy)
def norm(mask, target):
    s = np.std(y[mask]); return target / s if s > 0 else 1
y_in = y * (e_in > 0.02) * norm((t > 1) & (t < 3), 1.0)
y_ex = y * (e_ex > 0.02) * norm((t > 4.5) & (t < 7), 1.1)
# the exhaust valve rattles: pulsed noise (a buzz), a lighter flutter on the inhale
rattle = 0.3 + 0.7 * (0.5 + 0.5 * np.sin(2 * np.pi * 37 * t)) ** 4
flutter = 1 + 0.07 * np.sin(2 * np.pi * 13 * t)
y = y_in * flutter + y_ex * rattle
# the regulator's whistle in the inhale: a thin steady tone riding the hiss
y += 0.12 * np.sin(2 * np.pi * 2100 * (1 + 0.07 * np.clip((t - IN0) / (IN1 - IN0), 0, 1)) * t) * e_in
# valves: a low clunk as the inhale opens, a dry tick before the exhale
def thump(at, f0, dur, amp):
    i0 = int(at * SR); L = int(dur * SR); k = np.arange(L) / SR
    s = (np.sin(2 * np.pi * f0 * k) * np.exp(-k / (dur / 4)) + rng.normal(0, 0.6, L) * np.exp(-k / 0.002)) * amp
    y[i0:i0 + L] += s[: max(0, min(L, n - i0))]
thump(IN0 - 0.02, 110, 0.09, 1.4)
thump(EX0 - 0.08, 900, 0.03, 0.8)
# the helmet: two short metallic combs and a few early reflections
h = np.zeros(int(0.03 * SR)); h[0] = 1
for d, g in ((0.0021, 0.5), (0.0047, 0.3)):
    di = int(d * SR)
    for k2 in range(1, 7):
        if di * k2 < len(h): h[di * k2] += g ** k2
for d, g in ((0.007, 0.25), (0.011, 0.18), (0.017, 0.12)):
    h[int(d * SR)] += g
y = np.convolve(y, h)[:n]
y /= np.max(np.abs(y)) / 0.92
with wave.open(os.path.join(OUT, "knight_breath.wav"), "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((y * 32767).astype(np.int16).tobytes())
# a spectrogram (0-10 kHz) to check the shape by eye
from PIL import Image
S = [np.abs(np.fft.rfft(y[i:i + 1024] * np.hanning(1024)))[:240] for i in range(0, n - 1024, 256)]
S = 20 * np.log10(np.array(S).T + 1e-6); S = np.clip((S - S.max() + 50) / 50, 0, 1)
Image.fromarray((S[::-1] * 255).astype(np.uint8)).resize((1000, 300)).save(os.path.join(OUT, "spectrogram.png"))
def bands(a, b):
    seg = y[int(a * SR):int(b * SR)]
    sp = np.abs(np.fft.rfft(seg * np.hanning(len(seg)))) ** 2; f = np.fft.rfftfreq(len(seg), 1 / SR)
    return " ".join(f"{lo}-{hi}:{10 * np.log10(sp[(f >= lo) & (f < hi)].mean() + 1e-12):.0f}" for lo, hi in
                    ((80, 300), (300, 700), (700, 1300), (1300, 2500), (2500, 4500), (4500, 9000)))
print(f"knight_breath.wav {T}s | inhale dB {bands(1, 3)} | exhale dB {bands(4.5, 7)}")
