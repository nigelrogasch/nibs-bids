
NOTES 20260616

- in the tsv: intensity_reference with rMT|1mV|e-fild and intensity_scaling 0.8|1|absolute which could be 80% rMT | 100% 1mV | absolute efield (no scaling no method)
- remove rMT from tsv, in the json we will have "value: XX" describing rMT
- ThresholdSet: change to IntensitySet
- what we can do now:
  describe the temporal aspect of the stimulation (derived with nibs.tsv)
  describe the spatial aspect (markers.tsv)
- nail down double coil (ccPAS cortical, temporal and spatial)

- postions: instead of target_id we will have position_id (more appropriate, not describing a target). We describe it in the events.tsv in the exact same way we use for event_id.
- even for experiments in which technically there is no event, like beh + TMS + beh, the events.tsv will live in the nibs folder. scans.tsv will have beh.tsv, nibs.tsv (this indientify an offline stimulation), beh.tsv
- idea: tool describing pulse sequence could laso describe the higher oreder of "events" i.e., acq sequence, recording sequence (scans.tsv), session sequence (session.tsv) ...
  


> [!IMPORTANT]
> ## Notes — reading intensities and the `|` delimiter
>
> The `|` (pipe) delimiter is used in several columns, and **its meaning depends on which column it is in**:
>
> - **Across repeats, over time** → `pattern1_intensity` (and any `pattern<n>_*` vector).
>   The values are successive stimuli in the pattern, in order, and the number of values
>   MUST equal `pattern1_count`.
>   **When the intensity changes between pulses, set `stimulus_intensity = n/a` and put the
>   per-pulse values in `pattern1_intensity`.** This is the paired-pulse SICI case:
>   `35|50` = conditioning pulse at 35, then test pulse at 50.
>
> - **Across elements, in space (same instant)** → `stimulus_intensity` (and `element_id`, `target_id`).
>   Here `|` would mean several elements (electrodes/coils) firing simultaneously — one value per
>   element, in the same order as `element_id` (for tES the values MUST sum to 0).
>   **This is NOT used in this example**, because single-coil TMS delivers through one element.
>
> **In one line:** a `|` in `pattern1_intensity` means *different pulses in time*; a `|` in
> `stimulus_intensity` means *different elements in space*. Never put a time-varying vector in
> `stimulus_intensity`.
>
> Any column that uses `|` MUST declare its delimiter in the `*_nibs.json` sidecar.

# Example data set: motor TMS-EMG (SICI) — GB working copy

This data set is a working copy (`_GB`) of the `motor-tms-emg` example, formatted using the
proposed **NIBS-BIDS v6.3** structure with the v6.3 working decisions applied:
all stimulus parameters live in `*_nibs.tsv`, and threshold methods are described via a
`ThresholdSet` block in `*_nibs.json`.

## Experiment details
TMS-EMG data from a single individual. One protocol acquisition is provided: **SICI**
(short-interval intracortical inhibition), which interleaves single test pulses (`spTMS`) and
paired conditioning–test pulses (`SICI`, 2 ms inter-stimulus interval). TMS is delivered over
left primary motor cortex; EMG is recorded from the right first dorsal interosseous muscle.
Intensities are set relative to the resting motor threshold (RMT = 45 % maximum stimulator output).

## What this example demonstrates
- The base stimulus described entirely in `*_nibs.tsv` (shape, first inflection, intensity, duration).
- Repetition described parametrically with `pattern1_*` (the paired pulse) instead of extra rows.
- Per-pulse intensity via the `|` delimiter in `pattern1_intensity` (see Notes above).
- Threshold values in `*_nibs.tsv` (`threshold_id`, `threshold_reference_intensity`) with the method
  described once in `ThresholdSet` in `*_nibs.json`.
- Concurrent EMG: the timeline lives in `emg/*_events.tsv`, linked from `*_nibs.json` via `IntendedFor`.

## Notes on files
The EMG data file (`*_emg.mat`) is an empty placeholder, included for demonstration only, and does
not correspond to a defined BIDS data type.
