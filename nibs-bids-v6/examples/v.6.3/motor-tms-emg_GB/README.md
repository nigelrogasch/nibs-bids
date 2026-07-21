# Example data set: motor TMS-EMG (SICI)

Single- and paired-pulse TMS with concurrent EMG, formatted to the NIBS-BIDS v6.3 structure. One
acquisition interleaves single test pulses (`spTMS`) and paired conditioning-test pulses (`SICI`, 2 ms
inter-stimulus interval). TMS is delivered over left primary motor cortex and EMG is recorded from the
right first dorsal interosseous.

Resting motor threshold (rMT) is 50 % maximum stimulator output and the 1 mV test intensity is 58 %,
both recorded in the `IntensitySet` block of `*_nibs.json`. The conditioning pulse is dosed at 70% rMT
(35 %) and the test pulse at the 1 mV intensity.

## What this example shows

- Two intensity references in one row. The `SICI` row carries `pattern1_intensity = 35|58` with
  `intensity_reference = rMT|1mV` and `intensity_scaling = 0.7|1`, so each pulse records how its
  amplitude was chosen.
- A paired pulse described with `pattern1` rather than two rows, with `stimulus_intensity = n/a`
  because the per-pulse values are in `pattern1_intensity`.
- Placement given without coordinates. `*_markers.tsv` locates the coil by `position_label` (`C3`) and
  `position_description` alone, which is the usual case for non-navigated motor TMS.
- Concurrent EMG. The timeline lives in `emg/*_events.tsv` and `*_nibs.json` points to it through
  `IntendedFor`.

## Files

- `nibs/*_nibs.tsv` and `.json`: temporal parameters, `StimulatorSet`, `ElementSet`, `IntensitySet`.
- `nibs/*_markers.tsv` and `.json`: coil placement.
- `emg/*_events.tsv` and `.json`: timeline (`nibs_event_id`, `nibs_position_id`).
- `emg/*_emg.mat`: empty placeholder, included for demonstration only.
