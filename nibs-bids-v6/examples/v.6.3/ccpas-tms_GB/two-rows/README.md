# ccPAS — two rows, one per coil (trigger on both pulses)

Use when both pulses are triggered. Two `nibs.tsv` rows (`ccPAS_PMv` = Coil_1, `ccPAS_M1` = Coil_2),
each an ordinary single-coil event repeated 100 times. No `pattern` for the pair: the 8 ms intra-pair
interval is the onset offset between the two rows in `*_events.tsv` (PMv at 0 s, M1 at 0.008 s). See
the parent folder README.
