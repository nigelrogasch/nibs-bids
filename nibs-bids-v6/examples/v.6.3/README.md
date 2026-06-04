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

## Events.tsv and events.json

## NIBS.tsv

### General fields

| Field | Type | Description |
|---|---|---|
| `event_id` | string | Identifier of a stimulation event with unique stimulation parameters. May describe a single stimulus, or repeating stimuli with fixed intervals including with nested structures. Used for linkage to time-locked annotations in `*_events.tsv`. MUST be unique within a given `*_nibs.tsv` file. |
| `nibs_type` | string | String identifying the type of stimulation modality (`TMS` \| `tES` \| 'TUS' \| 'PNS') |
| `stimulator_id` | string | Short human-readable label for the stimulation device which generates the stimulus waveform. Links to `StimulatorID` within the `StimulatorSet` field in `nibs.json` for additional details on the stimulator device. |
| `element_id` | string | Short human-readable label for the stimulation element which delivers stimulation (e.g., coil, electrode, transducer). Links to `ElementID` within the `ElementSet` field in `nibs.json` for additional details on the stimulation element. Multiple elements (e.g., multiple electrodes for tES) can be described by separating each electrode with a `\|` delimiter (e.g., elec1 \| elec2)  |

