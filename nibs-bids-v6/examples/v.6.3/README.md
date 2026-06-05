# NIBS-BIDS proposal v.6.3 (Scalable Structure for Non-Invasive Brain Stimulation)

The following is an updated draft proposal for NIBS-BDS.

### Template:

```
sub-<label>/
└── [ses-<label>/]
    └── nibs/
        ├── sub-<label>[_ses-<label>]_task-<label>_coordsystem.json
        ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_nibs.tsv
        ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_nibs.json
        ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_markers.tsv
        ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_markers.json
        ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.tsv
        └── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_events.json
```

## \*events.tsv

## \*nibs.tsv

### General fields

| Field | Type | Description |
|---|---|---|
| `event_id` | string | Identifier of a stimulation event with unique stimulation parameters. May describe a single stimulus, or repeating stimuli with fixed intervals (can include nested structures). Used for linkage to time-locked annotations in `*_events.tsv`. MUST be unique within a given `*_nibs.tsv` file. |
| `nibs_type` | string | String identifying the type of stimulation modality (`TMS` \| `tES` \| `TUS` \| `PNS`). |
| `stimulator_id` | string | Short human-readable label for the stimulation device which generates the stimulus waveform. Links to `StimulatorID` within the `StimulatorSet` field in `nibs.json` for additional details on the stimulator device. |
| `element_id` | string | Short human-readable label for the stimulation element which delivers stimulation (e.g., coil, electrode, transducer). Links to `ElementID` within the `ElementSet` field in `nibs.json` for additional details on the stimulation element. Multiple elements (e.g., multiple electrodes for tES) can be described by separating each element id with a `\|` delimiter (e.g., `elec1 \| elec2`). Delimiter MUST be described in corresponding `*_nibs.json` file (e.g., `{"element_id": {"Delimiter": "\|"}}`). |

### Stimulus fields

| Field | Type | Description |
|---|---|---|
| `stimulus_shape` | string | String describing the shape of the stimulus (`Monophasic` \| `Biphasic` \| `Rectangle` \| `Sinusoid`\| `Noise`\| custom names). Additional shape information can be stored using key/value pairs in the `.json` file e.g., `"stimulus_shape": { "Levels": {"Sinusoid": { "Frequency": 10 } } },`. Possible key/value pairs include: `Frequency` (integer; Hz; e.g., `"Frequency": 10`), `RampUpDuration` (integer; s; e.g., `"RampUpDuration": 30`); `RampDownDuration` (integer; s; `"RampDownDuration": 30`); `Offset` (integer; mA; e.g., `"Offset": 1`); `NoiseType` (string; e.g., `"NoiseType": "Pink noise"`); `Window` (string; e.g., `"Window": "Tukey"`).|
| `stimulus_intensity` | integer | Integer describing the amplitude of stimulation. Units will vary depending on stimulation modality and MUST be described in accompanying `*_nibs.json` (e.g., for `nibs_type = TMS`; `{"stimulus_intensity": {"Units": "% maximum stimulator output"}}`. Where multiple elements are described in `element_id` (e.g., multiple electrodes for tES), corresponing stimulus intensities for each element SHOULD be described by separating each value with a `\|` delimiter (e.g., `1\|-1` where stimulus intensity is 1 mA and elec1 = anode, elec2 = cathode). Delimiter MUST be described in corresponding `*nibs.json` file (e.g., `{"stimulus_intensity": {"Delimiter": ""\|"}}`). For `tES`, sum of values MUST equal 0.|
| `stimulus_duration` | integer | Integer describing the duration of the stimulus (e.g., time during which contiguous non-zero current is delivered by the stimulator). |

### Repeating stimuli fields

| Field | Type | Description |
|---|---|---|
| `pattern1_count` | integer | Integer describing the number of stimuli in the pattern1.|
| `pattern1_interval` | integer | Integer describing the interval between the start of the first stimulus and the start of the subsequent stimulus in pattern1.|
| `pattern1_frequency` | integer | Integer describing the frequency of the interval between the start of the first stimulus and the start of the subsequent stimulus in pattern1. If `pattern1_interval` is described, `pattern1_frequency` MUST equal 1 divided by `pattern1_interval` (in s).|
| `pattern1_duration` | integer | Integer describing the duration of pattern1 including all stimuli and intervals (including the interval following the final stimulus). If `pattern1_count` and `pattern1_interval`/`pattern1_frequency` are described, `pattern1_duration` (in s) MUST equal `pattern1_count` multiplied by `pattern1_interval` (in s). |
| `pattern1_intensity` | integer | If intensity changes over stimuli in pattern1, the intensity of each stimulus can be described in `pattern1_intensity` and separated by a delimiter. Delimiter MUST be described in corresponding `*_nibs.json` file (e.g., `{"pattern1_intensity`": {"Delimiter": "\|"}}`). Number of values MUST equal `pattern1_count`. `stimulus_intensity` MUST equal `n/a`.|

### Nested repeating stimuli fields

| Field | Type | Description |
|---|---|---|
| `pattern<index>_count` | integer | Integer describing the number of patterns in the pattern<index-1>.|
| `pattern<index>_interval` | integer | Integer describing the interval between the start of the first pattern and the start of the subsequent pattern in pattern<index-1>.|
| `pattern<index>_frequency` | integer | Integer describing the frequency of the interval between the start of the first pattern and the start of the subsequent pattern in pattern<index-1>. If `pattern<index>_interval` is described, `pattern<index>_frequency` MUST equal 1 divided by `pattern<index>_interval` (in s).|
| `pattern<index>_duration` | integer | Integer describing the duration of pattern<index> including all stimuli and intervals (including the interval following the final pattern<index-1>). If `pattern<index>_count` and `pattern<index>_interval`/`pattern<index>_frequency` are described, `pattern<index>_duration` (in s) MUST equal `pattern<index>_count` multiplied by `pattern<index>_interval` (in s). |
| `pattern<index>_intensity` | integer | If intensity changes over patterns in pattern<index>, the intensity of each pattern can be described in `pattern<index>_intensity` and separated by a delimiter. Delimiter MUST be described in corresponding `*_nibs.json` file (e.g., `{"pattern<index>_intensity`": {"Delimiter": "\|"}}`). Number of values MUST equal `pattern<index>_count`. |

