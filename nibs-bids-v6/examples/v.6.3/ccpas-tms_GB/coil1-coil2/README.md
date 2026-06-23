# ccPAS — nibs_element_id = Coil_1|Coil_2 (single trigger)

Use when only the conditioning pulse is triggered. One `nibs.tsv` row: the two coils are a
`|`-delimited `nibs_element_id` (`Coil_1|Coil_2`) with two ordinary `ElementSet` entries, aligned to
the two pulses of `pattern1` (`Coil_1` fires first, `Coil_2` 8 ms later). One onset per pair in
`*_events.tsv`. See the parent folder README.
