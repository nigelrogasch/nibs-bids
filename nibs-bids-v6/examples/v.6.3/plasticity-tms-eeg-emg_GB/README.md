> [!IMPORTANT]
> ## Notes
>
> **iTBS is one `nibs.tsv` row, built from nested `pattern<index>` layers.** Repetition over time is
> described parametrically, not as one row per pulse:
> - `pattern1` (burst): 3 pulses, 20 ms apart (50 Hz).
> - `pattern2` (train): 10 bursts, 200 ms apart (5 Hz) -> a 2 s train.
> - `pattern3` (protocol): 20 trains, 10000 ms apart (2 s on + 8 s off) -> ~192 s, 600 pulses.
>
> All `pattern<n>_interval` values are onset-to-onset, so the inter-train off period (8 s) is implicit.
> No `pattern<n>_duration` columns are used; duration is derivable from count x interval.
>
> **Intensity.** `stimulus_intensity` is the delivered amplitude. `intensity_reference` and
> `intensity_scaling` record how it was set: the assessment test pulse is 120% rMT (`rMT`, `1.2`);
> iTBS is 80% aMT (`aMT`, `0.8`). Each reference is described once in `IntensitySet` in the matching
> `*_nibs.json` (`IntensityID`, `Value`, method fields).
>
> **Linkage.** `events.tsv` carries `event_id` (-> `nibs.tsv`) and `position_id` (-> `markers.tsv`).
> Assessment events are concurrent and live in `eeg/` and `emg/` (linked from `nibs.json` via
> `IntendedFor`); iTBS is standalone and its events live in `nibs/`.

# Example data set: M1 plasticity — concurrent TMS-EEG-EMG with iTBS (GB working copy)

Single-subject plasticity assessment in the proposed NIBS-BIDS v6.3 structure (2026-06-16 decisions
applied). Concurrent TMS-EEG-EMG is recorded before and after a single iTBS intervention over left M1.

## Experiment details
Three phases are distinguished by the `acq-` label on a single `task-rest`:
- `acq-pre`  — single-pulse TMS to left M1 with concurrent EEG (TEPs) and EMG (MEPs from right FDI).
- `acq-itbs` — intermittent theta-burst stimulation (600 pulses), delivered standalone.
- `acq-post` — repeat of the `acq-pre` assessment, test intensity held fixed.

rMT = 50 %MSO (assessment, 120% -> 60 %MSO); aMT = 40 %MSO (iTBS, 80% -> 32 %MSO).

## Files
- `nibs/*_nibs.tsv` / `.json`: stimulation parameters and `IntensitySet`.
- `nibs/*_markers.tsv` / `.json`: stimulation position(s).
- `eeg/`, `emg/`: concurrent recordings and their `*_events.tsv` (`event_id`, `position_id`).
- `nibs/*_events.tsv`: standalone iTBS timeline.
- `*_eeg.set`, `*_emg.mat`: empty placeholders, demonstration only.
