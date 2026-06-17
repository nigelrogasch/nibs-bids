# Example data set: tDCS with fMRI before and after (GB working copy)

Single-subject offline tDCS study in the proposed NIBS-BIDS v6.3 structure (2026-06-16 decisions).
Resting-state fMRI is acquired before and after a single tDCS block: fMRI -> tDCS -> fMRI. tDCS is
offline (not concurrent with the fMRI). This example exercises the simultaneous-electrode case.

## Protocol
- Anodal tDCS, anode over left M1 (C3), cathode over right supraorbital (Fp2).
- 2 mA for 20 min (1200 s), 10 s ramp up / down. Shape: Rectangle.
- Two resting-state fMRI runs (`acq-pre`, `acq-post`) bracket the stimulation.

## Points this example demonstrates
- **Simultaneous electrodes**: `element_id = anode|cathode`, `stimulus_intensity = 2|-2` (mA). The `|`
  here means two elements active at the same instant (space, not time); the values sum to 0 (tES rule).
- **Absolute intensity**: `intensity_reference = absolute`, `intensity_scaling = absolute`. No reference
  method, so no `IntensitySet` is needed.
- **Offline rule**: tDCS is not concurrent with a recording, so its `events.tsv` lives in `nibs/`, and
  `scans.tsv` lists the two `bold.nii.gz` runs and the `nibs.tsv` in time order (fMRI, tDCS, fMRI); the
  `nibs.tsv` entry marks the offline stimulation block.
- **Shape parameters in the TSV**: `ramp_up` / `ramp_down` are columns (not hidden in JSON `Levels`).
- **Positions**: `position_id = C3|Fp2` (one per electrode, aligned to `element_id`) -> `markers.tsv`.

## Files
- `func/*_bold.nii.gz` / `.json`: resting-state fMRI (empty placeholder volumes).
- `nibs/*_nibs.tsv` / `.json`: stimulation parameters, `ElementSet` (two electrodes with roles).
- `nibs/*_markers.tsv` / `.json`: electrode positions.
- `nibs/*_events.tsv` / `.json`: standalone tDCS timeline (`event_id`, `position_id`).
