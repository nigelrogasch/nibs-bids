# ccPAS double-coil — three encodings of the same experiment

The same cortico-cortical paired associative stimulation protocol (a PMv pulse, then an M1 pulse 8 ms
later; 100 pairs at 0.2 Hz), written three ways. They differ only in how the two coils appear in
`*_nibs.tsv`:

- **1-double_coil/** — `element_id = double_coil`: one row; one compound element expanded in
  `ElementSet` as a `coil_pair` of two sub-coils. Most compact; needs a compound element type.
- **2-coil1-coil2/** — `element_id = Coil_1|Coil_2`: one row; two ordinary elements delimited with `|`,
  aligned to the two pulses of `pattern1`. Reuses the delimiter; no new element type.
- **3-two-rows/** — two rows, one per coil (`ccPAS_PMv`, `ccPAS_M1`): each coil is an ordinary
  single-coil event; the 8 ms pairing is the onset offset between the two rows in `*_events.tsv`.
  Most explicit and delimiter-free; the pair structure moves from `nibs.tsv` into the timeline.

Intensities (PMv 90% rMT = 45 %MSO; M1 1 mV = 58 %MSO) and positions (PMv_L, M1_L) are identical in
all three.
