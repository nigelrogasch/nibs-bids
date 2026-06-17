# Notes — 2026-06-16 (meeting with Nigel)

Decisions from the 2026-06-16 meeting and subsequent clarification. These replace the earlier
`ThresholdSet` / `threshold_*` fields. The general structure is considered settled; the ccPAS
double-coil case is treated as an edge case and is not a prerequisite for the general model.

## Intensity fields
- `stimulus_intensity` is retained as the delivered amplitude. `intensity_reference` and
  `intensity_scaling` record how that amplitude was set.
- `intensity_reference` (TSV): closed vocabulary, e.g. `rMT`, `aMT`, `1mV`, `e-field`, `absolute`.
- `intensity_scaling` (TSV): a number (e.g. `0.8`) or `absolute` (value given directly, no scaling).
- Both may be `|`-delimited and are aligned position-by-position, e.g.
  `intensity_reference = rMT|1mV|e-field` with `intensity_scaling = 0.8|1|absolute`.
- The reference value is not stored in the TSV. It is given in the JSON `IntensitySet` entry as
  `Value` (e.g. rMT = 50 %MSO), since it is constant within a file.
- `absolute` may appear as an `intensity_reference` value as well as an `intensity_scaling` value.
- When intensity varies between pulses, the per-pulse values are in `pattern1_intensity` and
  `stimulus_intensity` is `n/a` (unchanged from SICI).

## IntensitySet (JSON)
- `ThresholdSet` is renamed `IntensitySet`. Each entry: `IntensityID`, `Value`, `Units`, and method
  fields (`Type`, `Criterion`, `Algorithm`, `MeasurementMethod`). Referenced by `intensity_reference`.

## Temporal and spatial description
- Temporal structure is given by `nibs.tsv` (`stimulus_*`, `pattern<n>_*`).
- Spatial structure is given by `markers.tsv`.

## Positions
- `target_id` is renamed `position_id`.
- `position_id` is placed in `events.tsv` alongside `event_id`: `event_id` references `nibs.tsv`,
  `position_id` references `markers.tsv`.
- `position_id` may be `|`-delimited, one position per element.
- Spatial columns in `markers.tsv` are renamed `target_*` / `coil_*` -> `position_*`.

## Offline / behavioural experiments
- When stimulation is not concurrent with a recording (e.g. beh, TMS, beh), `events.tsv` is placed in
  `nibs/`. `scans.tsv` lists `beh.tsv`, `nibs.tsv`, `beh.tsv`; the `nibs.tsv` entry denotes an offline
  stimulation block.

## ccPAS (double coil)
- Modelled as SICI: one `nibs.tsv` row, `pattern1` of 2 pulses at the intra-pair interval, the two coil
  intensities in `pattern1_intensity`, `stimulus_intensity = n/a`.
- `element_id = double_coil`, expanded in the JSON `ElementSet`; `coil_1|coil_2` is an equivalent form.
- `events.tsv` carries one trigger per pair.
- `position_id` references two positions (one per coil), `|`-delimited.

## Tool (future)
- A description of a pulse sequence could be extended to higher-order sequences: acquisition order,
  recording order (`scans.tsv`), session order (`sessions.tsv`).

Status: applied to the `_GB` examples on 2026-06-16.

---

> [!IMPORTANT]
> ## Delimiter `|` — meaning by column
>
> - `pattern<n>_intensity`: successive stimuli over time (in order); the number of values equals
>   `pattern<n>_count`. When intensity changes between pulses, `stimulus_intensity = n/a` and the
>   per-pulse values go here. SICI: `35|58` = conditioning then test. Two coils fired sequentially
>   (e.g. ccPAS) are also a time vector and go here, not in `stimulus_intensity`.
> - `stimulus_intensity`, `element_id`, `position_id`: multiple elements at the same instant (e.g.
>   simultaneous tES electrodes; for tES the values sum to 0). `stimulus_intensity` is always the
>   delivered amplitude; `intensity_reference` / `intensity_scaling` describe how it was set.
> - Any column using `|` declares its delimiter in the `*_nibs.json` sidecar.

# Example data set: motor TMS-EMG (SICI) — GB working copy

Working copy (`_GB`) of the `motor-tms-emg` example in the proposed NIBS-BIDS v6.3 structure with the
2026-06-16 decisions applied: stimulus parameters in `*_nibs.tsv`, intensity references described in an
`IntensitySet` block in `*_nibs.json`, and positions in `*_markers.tsv` referenced from `*_events.tsv`.

## Experiment details
TMS-EMG data from a single individual. One acquisition: SICI (short-interval intracortical inhibition),
interleaving single test pulses (`spTMS`) and paired conditioning-test pulses (`SICI`, 2 ms ISI). TMS over
left primary motor cortex; EMG from the right first dorsal interosseous. Resting motor threshold
rMT = 50 %MSO; the test pulse intensity (`1mV`) = 58 %MSO. Conditioning pulse = 70% rMT (35 %MSO).

## Files
- `nibs/*_nibs.tsv` / `.json`: stimulation parameters and `IntensitySet`.
- `nibs/*_markers.tsv` / `.json`: stimulation position(s).
- `emg/*_events.tsv` / `.json`: timeline (`event_id` -> `nibs.tsv`, `position_id` -> `markers.tsv`).
- `emg/*_emg.mat`: empty placeholder, demonstration only.
