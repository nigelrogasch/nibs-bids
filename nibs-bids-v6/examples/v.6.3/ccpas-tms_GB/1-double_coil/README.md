# Example data set: ccPAS double-coil TMS (GB working copy)

Single-subject cortico-cortical paired associative stimulation (ccPAS) in the proposed NIBS-BIDS v6.3
structure (2026-06-16 decisions). Two coils stimulate two cortical sites with a fixed intra-pair
interval; the pair repeats. Delivered offline (no concurrent recording). This example exercises the
double-coil case, the `pattern` description of the pair, and the spatial description in `markers.tsv`.

## Protocol
- Pair: a pulse over left ventral premotor cortex (PMv), then a pulse over left M1, 8 ms later.
- 100 pairs at 0.2 Hz (one pair every 5 s); 200 pulses total; ~500 s.
- PMv pulse at 90% rMT (45 %MSO); M1 pulse at the 1 mV intensity (58 %MSO). rMT = 50 %MSO.

## How the double coil is represented
- One `nibs.tsv` row. `element_id = double_coil`, expanded in `nibs.json` `ElementSet` as a `coil_pair`
  with two sub-coils. Sub-coil order maps to the pulse order in `pattern1` and to the order of
  `position_id`: pulse 1 -> PMv coil -> `PMv_L`; pulse 2 -> M1 coil -> `M1_L`.
- The pair is a `pattern1` of 2 pulses at the 8 ms interval; the two coil intensities are in
  `pattern1_intensity` (`stimulus_intensity = n/a`). `pattern2` repeats the pair 100 times.
- `events.tsv` carries one trigger for the pair, with `position_id = PMv_L|M1_L`.
- Equivalent form: `element_id = coil_PMv|coil_M1` with two separate `ElementSet` entries. Independent
  stimulators would be `stimulator_id = stim_1|stim_2` (here a single stimulator is used for brevity).

## Files
- `nibs/*_nibs.tsv` / `.json`: parameters, `ElementSet` (double_coil), `IntensitySet`.
- `nibs/*_markers.tsv` / `.json` + `*_coordsystem.json`: the two positions and their coordinate system.
- `nibs/*_events.tsv` / `.json`: standalone timeline (`event_id` -> `nibs.tsv`, `position_id` -> `markers.tsv`).
- `scans.tsv` lists `nibs.tsv`, marking an offline stimulation block.
