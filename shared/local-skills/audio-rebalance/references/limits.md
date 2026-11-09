# Limits and alternatives

## Separate causes before replacing models

- Low volume: compare both channels and representative vocal-active regions. A gain change raises noise too. Center averaging can conceal a larger peak in one stereo channel.
- Bad balance: change stem gains. Turning music down is often preferable to aggressively amplifying a noisy microphone.
- Generated clipping: check the rendered candidate, not only the source. Preserve headroom and reject an overloaded export.
- Muffling or intermittent rattling: compare original mix, separated vocal without denoising, and denoised vocal at the same vocal level. This localizes whether damage starts in separation or enhancement.

Successful inference, a 48 kHz output, or a 24-bit container does not prove preserved harmonics or intelligibility. Higher output bit depth cannot restore information a separator removed.

## Denoising is optional

The accepted basic pipeline was Sony MIMO separation plus gain adjustment, without a denoiser. GTCRN at 16 kHz and a custom spectral mask dulled that recording; DPDFNet8 at 48 kHz still produced an objectionable result. Those observations concern that source, not universal model rankings.

DeepFilterNet3, ClearerVoice/MossFormer2_SE_48K, DPDFNet8 48k, RNNoise, and aTENNuate were run locally as alternatives. aTENNuate's published package operated at 16 kHz; it is not a full-band comparison. RNNoise introduced a measured 20 ms delay in that runtime, which needed compensation. Other versions may differ: measure alignment rather than assuming a fixed delay.

Use native model output when evaluating a denoiser. Custom masking, high-frequency cuts, automatic normalization and changing the music bed confound model comparisons. Full-band speech models may still suppress singing, breaths, consonants or weak voices. Without clean ground truth, quiet-window energy and spectral changes are not SNR, PESQ, intelligibility, or quality verdicts.

## Backing vocals and live microphones

Sony MIMO's two sources are vocals and accompaniment. Both live singers and recorded backing voices can enter vocals. The model does not know which microphone or person the user intends.

A pretrained backing-vocal extractor such as UVR-BVE-4B_SN-44100-1 can be evaluated as a second pass on the vocal stem. Its backing estimate is not a verified live/recorded identity label. Listen to both estimated components. If using subtraction, preserve mixture consistency by retaining `input_vocals - backing_estimate`; independently exported model components may not reconstruct the original exactly. Trim or explicitly account for any output-length difference before remixing.

Karaoke/lead models can remove nearly all of a weak vocal input. Do not compensate by blindly amplifying the residue or claim the physical live voice was found. Same-singer studio and live voices may be especially hard to distinguish acoustically. Reference-conditioned target voice extraction or audiovisual/lip-conditioned extraction needs an actual target reference and suitable model; a generic role label is not equivalent.

SAM Audio checkpoints were gated when checked. Recheck existing local copies and normal credential lookup before declaring access unavailable. A task-specific Hugging Face cache can hide credentials in the normal cache. Use an approved secret mechanism if access is genuinely required; never upload private recordings to a public demo or accept account terms implicitly.

## Runtime and export details

- A large Mel-RoFormer GPU run caused severe memory/disk pressure on a 16 GiB Apple Silicon machine. The bundled small Sony CPU model avoids that path. Use bounded threads and short validation clips before larger models.
- Some audio-separator soundfile exporters flattened stereo or cast unscaled float samples into integers. Validate channel count, duration and amplitude. Prefer direct float stem writes; distinguish this export defect from actual recording bit depth.
- Encoder delay and container edits matter. Preserve the source video stream when muxing, compare its compressed stream hash, and check decoded AAC against the processed WAV. Account for small trailing frame/packet rounding explicitly.
- Private source media, expiring URLs, user chat and machine-specific paths do not belong in a shared skill. Store only reusable technical choices and local task-owned output metadata.

## Primary implementations

- Sony MIMO: https://github.com/SonyResearch/mimo-audio-separation
- DeepFilterNet: https://github.com/Rikorose/DeepFilterNet
- ClearerVoice: https://github.com/modelscope/ClearerVoice-Studio
- DPDFNet: https://github.com/ceva-ip/DPDFNet
- RNNoise: https://github.com/xiph/rnnoise
- aTENNuate package: https://pypi.org/project/attenuate/
- SAM Audio: https://github.com/facebookresearch/sam-audio
