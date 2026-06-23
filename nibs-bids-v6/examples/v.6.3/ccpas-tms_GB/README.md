# ccPAS double-coil — two encodings, by triggering

The same cortico-cortical paired associative stimulation protocol (a PMv pulse, then an M1 pulse 8 ms
later; 100 pairs at 0.2 Hz), written two ways. Which one to use depends on how the pulses were triggered:

- **coil1-coil2/** — one trigger (on the conditioning pulse). One `nibs.tsv` row with
  `nibs_element_id = Coil_1|Coil_2`; the 8 ms to the test pulse is encoded by `pattern1`. The timeline
  has a single onset per pair.
- **two-rows/** — a trigger on both pulses. Two `nibs.tsv` rows (one per coil), no `pattern`; the 8 ms
  intra-pair interval is the onset offset between the two rows in `*_events.tsv` (PMv at 0 s, M1 at
  0.008 s).

The earlier `double_coil` compound-element encoding was dropped: with a single compound
`nibs_element_id`, it is not clear what the `|`-separated intensities refer to.

Intensities (PMv 90% rMT = 45 %MSO; M1 1 mV = 58 %MSO) and positions (PMv_L = Coil_1, M1_L = Coil_2)
are identical in both.
