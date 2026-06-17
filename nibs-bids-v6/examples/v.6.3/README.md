# NIBS-BIDS proposal v6.3

> This is a draft. It merges the v6.2 specification with the decisions taken for v6.3 and supersedes
> v6.2 wherever the two differ. Sections that are unchanged in substance from v6.2, such as the spatial
> files, coordinate systems and device hardware blocks, are retained and only re-keyed to the new
> identifiers where needed.

This document describes a scalable structure for organizing **non-invasive brain stimulation (NIBS)**
data in BIDS. It covers Transcranial Magnetic Stimulation (**TMS**), Transcranial Electrical
Stimulation (**TES**, e.g. tDCS, tACS, tRNS, tPCS), Transcranial Ultrasound Stimulation (**TUS**),
and Peripheral Nerve Stimulation (**PNS**).

---

## What this specification records

This specification records the stimulation that was delivered, meaning the device settings that the experimenter controls and that determine the electromagnetic energy put into the head. Following Peterchev et al. (2012), the stimulation dose is the full set of device parameters that shape the field generated in the body. It includes the shape, size, position and electrical properties of the coil, electrodes or transducer, together with the waveform that drives them, namely its shape, amplitude, duration, polarity and frequency, and the way single stimuli are grouped and repeated over time. This delivered dose is defined by what is applied and controlled, independently of how the brain or body responds to it.

The dose that actually reaches the tissue is a separate quantity. It depends on the delivered dose and on individual anatomy, such as scalp and skull thickness and tissue conductivity, so it cannot be read directly from the device settings and has to be estimated with a model, for example SimNIBS for TMS and TES. That estimation is not part of this specification for now, but it is expected to be added in the future, most likely as a BIDS derivative. The fields here describe the delivered dose, from which the field in tissue can be modelled when the participant anatomy is known.

The guiding principle is reproducibility. The fields below aim to capture enough about the stimulation that another group could reproduce the delivered dose from the dataset alone (Peterchev et al., 2012).

---

## What changed from v6.2

v6.3 resolves the two open framework issues ([#2413](https://github.com/bids-standard/bids-specification/issues/2413),
[#2414](https://github.com/bids-standard/bids-specification/issues/2414)) and simplifies the model:

| Area | v6.2 | v6.3 |
|---|---|---|
| Parameter framework (#2413) | Modality-specific parameter sets | **Unified** across modalities; the base unit is a modality-neutral **`stimulus`** (not "pulse") |
| Timing hierarchy (#2414) | `pulse` → `train` → `repeat` (modality terms) | Generic, infinitely-nestable **`pattern<index>`** layers |
| Modality in filename | `stimsys-<label>` entity | Dropped; modality is the **`nibs_type`** column in `*_nibs.tsv` |
| Device hardware | `CoilSet` / `ElectrodeSet` / `TransducerSet` | Unified **`ElementSet`** (`ElementType`: coil/electrode/transducer) + **`StimulatorSet`** (the waveform generator) |
| Device id columns | `coil_id` / `electrode_id` / `transducer_id` | `stimulator_id` + `element_id` |
| Multi-element events | Multiple rows indexed by `event_part` | A single row using the **`|` delimiter** in `element_id`, `stimulus_intensity`, and `position_id` (in `*_events.tsv`) |
| Numeric typing | many `integer` fields | **`number`** (decimals allowed: 0.5 ms, 1.5 mA, 0.1 Hz) |
| Dose | Applied vs received discussed | Stores **applied** dose only; received/in-tissue E-field is left to modelling (e.g. SimNIBS) |

### Revisions agreed 2026-06-16

The following refinements were agreed after the initial v6.3 draft and are applied throughout this
document:

- **Intensity.** `stimulus_intensity` is retained as the delivered amplitude. Two columns record how it
  was set: `intensity_reference` (a closed vocabulary: `rMT`, `aMT`, `1mV`, `e-field`, `absolute`) and
  `intensity_scaling` (a number, or `absolute`). The earlier `threshold_*` fields are removed, and
  `threshold_intensity` is dropped as derivable.
- **`IntensitySet`.** The reference *value* (e.g. an rMT of 50 %MSO) moves out of the table into a JSON
  `IntensitySet` block (renamed from the earlier `ThresholdSet`), one entry per reference, since it is
  constant within a file.
- **Positions.** `target_id` is renamed `position_id` and moves into `*_events.tsv` alongside `event_id`:
  `event_id` references `*_nibs.tsv`, `position_id` references `*_markers.tsv`. The spatial columns are
  renamed `target_*` / `coil_*` → `position_*`.
- **Shape parameters in the table.** Shape-specific parameters (e.g. `first_inflection`,
  `ramp_up` / `ramp_down`, `frequency`, `starting_phase`) are `*_nibs.tsv` columns rather than nested in
  JSON `Levels`; `Levels` returns to plain value→description strings.
- **Offline stimulation.** When stimulation is not concurrent with a recording, `*_events.tsv` is placed
  in `nibs/` and the `*_nibs.tsv` is listed in `scans.tsv` between the surrounding recordings.
- **Compound elements.** A multi-coil / multi-electrode element may be given as a single compound
  `element_id` expanded in `ElementSet`, or as a `|`-delimited list of element ids.

---

## NIBS as a dedicated `datatype`

All NIBS data is stored under a dedicated `nibs/` folder and is treated as a standalone BIDS `datatype`, even though NIBS by itself does not produce a neuroimaging or neurophysiological recording. Modality (TMS, TES, TUS or PNS) is recorded in the `nibs_type` column rather than in the filename.

The reason for a dedicated folder is practical. Describing a NIBS experiment requires a large amount of metadata, and keeping it in its own folder collects that information in one place and makes it immediately clear that a given session or scan involved brain stimulation. An earlier approach added NIBS parameters to the JSON and TSV files of other modalities, which proved suboptimal because the stimulation parameters were hard to find once mixed in with unrelated fields. Non-invasive brain stimulation is also one of the main modalities used in neuroimaging and neurophysiology research, so giving it its own clearly labelled place in the structure, on equal footing with the recording datatypes, reflects how it is actually used.

### Template

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

`*_events.tsv` is placed in `nibs/` when the stimulation is standalone or offline; when NIBS is
concurrent with a recording, the timeline lives with that recording instead (see "Timeline").
Optional files: `*_headshape.<ext>` and `*_photo.<ext>` (see "Optional files").

---

## Core files and the linking model

| File | Role |
|---|---|
| `*_nibs.tsv` | Central table. **One row per unique stimulation parameter set** ("event type"). Holds the actual parameter values. |
| `*_nibs.json` | Sidecar. Column descriptions/units/levels **and** structured metadata (`StimulatorSet`, `ElementSet`, `IntensitySet`, `NavigationSystem`). |
| `*_markers.tsv` (+ `.json`) | Spatial positions (one point/contact per row), referenced by `position_id` from `*_events.tsv`. |
| `*_coordsystem.json` | Coordinate system, fiducials, landmarks. |
| `*_events.tsv` (+ `.json`) | Primary timeline (`onset`, `duration`, `event_id`, `position_id`) for synchronization. |

The TSV and JSON files play different roles. The `*_nibs.tsv` table carries the values that can change from one protocol to the next, while the `*_nibs.json` sidecar carries the things that are fixed or descriptive, such as what each column means, the unit of every numeric column, and the full description of the devices. Units are always stated in the sidecar and are never assumed from the numbers in the table.

Linking identifiers connect the files.

- `event_id` connects a row of `*_nibs.tsv` to one or more onsets in `*_events.tsv`. A parameter
  set is defined once in `*_nibs.tsv` and can be referenced many times in `*_events.tsv`.
  `event_id` MUST be unique within a `*_nibs.tsv` file.
- `position_id` connects a row of `*_events.tsv` to one or more rows of `*_markers.tsv` (spatial
  location). May be `|`-delimited, one position per element, in the same order as `element_id`.
- `element_id` connects to `ElementSet.ElementID` in `*_nibs.json`. Multiple simultaneous elements
  (e.g. tES electrodes, multi-coil) are listed in one cell separated by `|`, or given as one
  compound element.
- `stimulator_id` connects to `StimulatorSet.StimulatorID` in `*_nibs.json`.
- `intensity_reference` connects to `IntensitySet.IntensityID` in `*_nibs.json`.

**Delimiter rule.** Whenever `|` is used in a column, the delimiter MUST be declared for that column
in `*_nibs.json`, e.g. `{"element_id": {"Delimiter": "|"}}`.

**Synchronization** across modalities (EEG, MEG, fMRI, EMG, behaviour) is performed via `event_id`
(and, for location, `position_id`) and the shared `*_events.tsv` timeline. When NIBS is concurrent
with another recorded modality, the timeline lives with that modality's `*_events.tsv`; `*_nibs.json`
then points to it with `IntendedFor`. When NIBS is offline, the timeline lives in `nibs/` (see "Timeline").

### How `*_events.tsv` and `*_nibs.tsv` relate

`*_nibs.tsv` is a catalogue of stimulation protocols. Each row defines one complete protocol and is named by its `event_id`, which is unique within the file. `*_events.tsv` is the timeline of what happened during the session, and it refers back to those protocols by `event_id`. A given `event_id` therefore appears once in `*_nibs.tsv`, as a single row for a single protocol, and usually many times in `*_events.tsv`, once for every time that protocol was delivered, each with its own `onset`.

`*_markers.tsv` is, in the same way, a catalogue of positions, one per row, named by `position_id`. `*_events.tsv` refers to positions by `position_id` exactly as it refers to protocols by `event_id`. To read the data, take a row of `*_events.tsv` and follow its `event_id` to the parameters in `*_nibs.tsv` and its `position_id` to the location(s) in `*_markers.tsv`.

---

## `*_nibs.tsv` (stimulation parameters)

Each row represents one **logical stimulation event type** with a unique set of parameters.
A row may describe a single stimulus, or repeating/nested stimuli described parametrically with
the `pattern<index>_*` fields. All fields are OPTIONAL unless stated; numeric fields are typed
`number` (decimals allowed). Units for every numeric column MUST be declared in `*_nibs.json`.

One row holds a complete protocol, however long or repetitive it is. Rather than writing one row for every delivered stimulus, repetition over time is described with the `pattern<index>` fields, which record how the base stimulus is grouped and repeated. A single pulse, a paired pulse, a theta burst train and a twenty minute tACS block are each a single row. This keeps the table compact and makes the structure of a protocol explicit instead of leaving it implicit in a long list of timestamps.

### General fields

| Field | Type | Description |
|---|---|---|
| `event_id` | string | Identifier of a stimulation event type with unique parameters. May describe a single stimulus or repeating/nested stimuli. Used for linkage to `*_events.tsv`. MUST be unique within the file. |
| `nibs_type` | string | Stimulation modality: `TMS` \| `tES` \| `TUS` \| `PNS`. (PNS uses whichever physical technology applies; the stimulated nerve is described via `position_*` in `*_markers.tsv`.) |
| `stimulator_id` | string | Label of the device that generates the stimulus waveform. Links to `StimulatorSet.StimulatorID` in `*_nibs.json`. |
| `element_id` | string | Label of the element that delivers stimulation (coil/electrode/transducer). Links to `ElementSet.ElementID`. Multiple elements separated by `\|` (e.g. `elec_1\|elec_2`), or a single compound element; declare the delimiter in `*_nibs.json`. |

The spatial target is no longer a `*_nibs.tsv` column; it is given as `position_id` in `*_events.tsv`
(see "Timeline"), so the same protocol delivered at different positions does not need a new row.

### Stimulus fields (the base unit)

| Field | Type | Description |
|---|---|---|
| `stimulus_shape` | string | Shape of the base stimulus, taken from the closed vocabulary in the "Stimulus shape vocabulary" table below. Shape-specific parameters are given as their own `*_nibs.tsv` columns. |
| `stimulus_intensity` | number | Delivered amplitude of the base stimulus. Units are modality-dependent and declared in `*_nibs.json` (e.g. `% Maximum Stimulator Output` for TMS, `mA` for TES). Where multiple elements are given in `element_id`, one value per element separated by `\|` (e.g. `1\|-1`). For `tES`, the delimited values MUST sum to 0. Set to `n/a` when per-stimulus intensities are instead given in `pattern1_intensity` (see "Changing intensity"). How the amplitude was chosen is recorded in `intensity_reference` / `intensity_scaling`. |
| `stimulus_duration` | number | Duration of the base stimulus (time during which contiguous non-zero current/energy is delivered). Units declared in `*_nibs.json`. |

### Stimulus shape vocabulary

`stimulus_shape` uses a closed vocabulary, a fixed set of allowed values rather than free text. The allowed values, and the modality each applies to, are listed below. `Custom` is available for any waveform not covered and requires a free-text description.

| `nibs_type` | Allowed `stimulus_shape` |
|---|---|
| TMS | `Monophasic`, `Biphasic`, `Halfsine` |
| TES | `Rectangle`, `Sinusoid`, `Noise` |
| TUS | `Sinusoid` |
| any | `Custom` |

Each shape's parameters are given as their own `*_nibs.tsv` columns. `Levels` in the sidecar holds only the value→description text for `stimulus_shape`, following the normal BIDS convention.

| Shape | Parameter columns in `*_nibs.tsv` |
|---|---|
| `Monophasic`, `Biphasic`, `Halfsine` | `first_inflection` (`rising` or `descending`), the direction of the first deflection of the induced current. This corresponds to the normal or reverse current-direction setting on the stimulator. |
| `Rectangle` | `ramp_up` and `ramp_down` (s), the durations of the linear ramps at the start and end of the block. |
| `Sinusoid` | `frequency` (Hz for tACS, carrier frequency for TUS), `starting_phase` (degrees), and an optional `offset` that adds a constant (DC) component. |
| `Noise` | `noise_type` (`white`, `pink` or other), `frequency_low` and `frequency_high` (Hz) bounding the randomized band, and an optional `distribution` (for example `gaussian`). |
| `Custom` | `stimulus_description` (free text), for any waveform not listed above. |

A 10 Hz tACS sinusoid is therefore one `*_nibs.tsv` row carrying `stimulus_shape = Sinusoid`,
`frequency = 10`, `starting_phase = 0`.

Shape-parameter columns are only needed for the shapes a dataset actually uses, so the table can stay
narrow. For anti-phase or phase-shifted tACS, `starting_phase` may be a `|`-delimited vector aligned
with `element_id`.

The vocabulary is kept closed partly so that these terms can map onto HED (Hierarchical Event Descriptors), the controlled annotation system used in BIDS (see the HED appendix in the BIDS specification and issue #2384). Because full NIBS protocols are too variable to standardize directly, the aim is to align only the basic building blocks, such as the stimulus waveform and similar low-level terms, so they can be tagged consistently and searched across datasets, possibly through a small partnered HED library schema.

### Repeating and nested stimuli (`pattern<index>_*`)

Repetition is described by stacked **pattern layers**. `pattern1` repeats the base stimulus;
`pattern2` repeats `pattern1`; in general `pattern<index>` repeats `pattern<index-1>`. The scheme
nests to arbitrary depth without new field names.

For each layer `<index>`:

| Field | Type | Description |
|---|---|---|
| `pattern<index>_count` | number | Number of `pattern<index-1>` units in one `pattern<index>` (for `pattern1`, the number of base stimuli). |
| `pattern<index>_interval` | number | Onset-to-onset interval between consecutive `pattern<index-1>` units. Units declared in `*_nibs.json`. |
| `pattern<index>_frequency` | number | Repetition frequency = 1 / `pattern<index>_interval` (in s). Provide `interval` **or** `frequency`. |
| `pattern<index>_duration` | number | Total duration of the layer, including the interval after the final unit. |
| `pattern<index>_intensity` | number | Per-unit intensities when intensity changes across units in the layer; values separated by `\|`, length MUST equal `pattern<index>_count`. When used at `pattern1`, set `stimulus_intensity = n/a`. |

**Consistency rules** (evaluated with all times in **seconds**):

- `pattern<index>_frequency = 1 / pattern<index>_interval`.
- `pattern<index>_duration = pattern<index>_count × pattern<index>_interval`.
- A layer SHOULD provide `count` plus one of {`interval`, `frequency`}; `duration` is then derivable.
  Any two of {`count`, `interval`/`frequency`, `duration`} are sufficient and the third can be derived.

> **Note on units.** Per-column units are free and declared in the JSON, but the two equations above
> assume seconds. Tools converting between layers should normalise to seconds first.

### Changing intensity across repeats vs across elements

A delimited intensity vector is used in two distinct ways:

1. **Across elements at the same instant.** `stimulus_intensity = 1|-1` gives one value per `element_id`
   (the spatial split between, e.g., anode/cathode). For `tES` the values MUST sum to 0.
2. **Across repeats over time.** When the intensity differs between successive stimuli within a
   layer, set `stimulus_intensity = n/a` and give the vector in `pattern1_intensity` (length =
   `pattern1_count`). The canonical case is paired-pulse TMS (e.g. SICI: conditioning then test).

A pair of elements that fire **sequentially** rather than simultaneously (e.g. the two coils of a
double-coil ccPAS pair, separated by a few milliseconds) is case 2, not case 1: it is modelled as a
`pattern1` of two stimuli at the intra-pair interval, with the two element intensities in
`pattern1_intensity` and the element order given by the compound `element_id` (see `ElementSet`).

### Intensity reference and scaling

`stimulus_intensity` (or `pattern<index>_intensity`) holds the amplitude actually delivered. Two
OPTIONAL columns record how that amplitude was chosen; both may be `|`-delimited and are aligned to the
intensity values they describe.

| Field | Type | Description |
|---|---|---|
| `intensity_reference` | string | Anchor used to set the intensity. Closed vocabulary: `rMT`, `aMT`, `1mV`, `e-field`, `absolute`. Links to `IntensitySet.IntensityID` in `*_nibs.json`. `absolute` denotes a directly specified value (no reference). |
| `intensity_scaling` | number \| string | Multiplier applied to the reference value (e.g. `0.8` = 80% of the reference), or `absolute` for a directly specified value. |

The reference's measured value (e.g. an rMT of 50 %MSO) is not stored per row; it is given once in the
`IntensitySet` block of `*_nibs.json`. The delivered amplitude therefore equals
`IntensitySet.Value × intensity_scaling`, except where `intensity_scaling = absolute`.

When different pulses or elements use different references, `intensity_reference` and `intensity_scaling`
are `|`-delimited and aligned to the intensity vector. Example (paired-pulse SICI, conditioning dosed by
rMT, test dosed to a 1 mV target): `pattern1_intensity = 35|58`, `intensity_reference = rMT|1mV`,
`intensity_scaling = 0.7|1`.

### Derived / measured fields (carried from v6.2)

Reported or computed by the device/navigation system; not experimenter-set. All OPTIONAL.

**Common**

| Field | Type | Description |
|---|---|---|
| `stimulus_count` | number | Counter of deliveries of the same parameter set to the same position within the file. Counting only, and it MUST NOT be used for synchronization. |
| `stimulus_validation` | string | Whether delivery/positioning was verified (`verified`, `observed`, `not_verified`, `unknown`). |
| `subject_feedback` | string | Participant-reported perception/discomfort. |
| `status` / `status_description` | string | Data-quality flags for the row/channel. |
| `timestamp` | string | ISO 8601 time the stimulation occurred/was logged. |
| `intended_for` | string | BIDS URI to an associated recorded data file (per-row alternative to the JSON `IntendedFor`). |

**TMS-specific (electric field & motor response)**

| Field | Type | Description |
|---|---|---|
| `electric_field_target` / `electric_field_max` | number | E-field at the target / peak, as reported or modelled (not a tissue-current measurement). |
| `electric_field_units` | string | Units for the above (recommended `V/m`). |
| `electric_field_model_name` / `electric_field_model_version` | string | Source model/system for the E-field values. |
| `motor_response` | number | Procedure-level motor-response summary (e.g. for reference-intensity setting); not an EMG waveform. |
| `latency` | number | Device/procedure-reported delay between stimulus and detected response. |
| `response_channel_name` / `_type` / `_reference` / `_status` / `_status_description` | string | Description of the channel used to derive the response. |

**TES-specific**

| Field | Type | Description |
|---|---|---|
| `contact_impedance` | number | Measured contact impedance for the element (units declared; e.g. Ω, kΩ). |
| `measured_current_intensity` / `measured_voltage_intensity` | number | Device-reported delivered amplitude. |
| `current_statistics` | string | Device summary statistics for delivered current. |

**TUS-specific (acoustic dose & safety)**

| Field | Type | Description |
|---|---|---|
| `measured_peak_negative_pressure` | number | Estimated/measured peak negative pressure. |
| `spatial_peak_pulse_average_intensity` | number | ISPPA for the delivered stimulation. |
| `spatial_peak_temporal_average_intensity` | number | ISPTA for the delivered stimulation. |
| `mechanical_index` | number | Mechanical Index (MI). |
| `thermal_index` | number | Thermal Index (TI). |

---

## `*_nibs.json` (sidecar)

A standard BIDS JSON sidecar that (a) describes each `*_nibs.tsv` column (`LongName`, `Description`,
`Units`, `Levels`, `Delimiter`), and (b) carries structured device, intensity and context metadata.
Numeric columns SHOULD be documented as `number`.

Top-level descriptive fields:

- `NIBSDescription`, a free-text summary of the protocol.
- `ConcurrentModalities`, an array of concurrently recorded modalities (e.g. `["eeg"]`, `["emg"]`, `["none"]`).
- `IntendedFor`, a BIDS URI (or array of URIs) to the `*_events.tsv` (or recording) the stimulation is time-locked to.
- Task/institution/device context: `TaskName`, `TaskDescription`, `Instructions`,
  `InstitutionName`, `InstitutionAddress`, `InstitutionalDepartmentName`.

### `StimulatorSet`

Describes the device(s) that generate the stimulus waveform. Referenced from `stimulator_id`.

| Field | Type | Description |
|---|---|---|
| `StimulatorID` | string | Unique id, referenced from `stimulator_id`. |
| `Manufacturer` | string | Manufacturer name. |
| `ManufacturerModelName` | string | Model name/number. |
| `ManufacturerSerialNumber` | string | Serial number. |
| `SoftwareVersion` | string | (Optional) Control-software version. |

### `ElementSet`

Array of the elements that deliver stimulation, unifying the v6.2 `CoilSet`/`ElectrodeSet`/
`TransducerSet`. Each entry is referenced from `element_id` via `ElementID`. `ElementType` selects
which type-specific properties apply.

Common fields:

| Field | Type | Description |
|---|---|---|
| `ElementID` | string | Unique id, referenced from `element_id`. |
| `ElementType` | string | `coil` \| `electrode` \| `transducer` \| compound (e.g. `coil_pair`). |
| `ModelName` | string | Model name/number. |
| `SerialNumber` | string | Serial number. |

`ElementType = coil` (TMS) adds: `CoilShape` (e.g. figure-of-eight, circular), `CoilCooling`
(air/liquid/passive), `CoilDiameter` `{Value,Units,Description}`, `MagneticFieldPeak`,
`MagneticFieldPenetrationDepth`, `MagneticFieldGradient`.

`ElementType = electrode` (TES) adds: `ElectrodeRole` (REQUIRED: `anode`/`cathode`/`return`/`ground`/`other`),
`Shape`, `Dimensions`/`ElectrodeArea`/`ElectrodeSize`, `Thickness`, `Material`, `ElectrodeContactMedium`
(gel/saline/paste/dry), `ElectrodePreparation`.

`ElementType = transducer` (TUS) adds: `TransducerType` (single-element/phased-array/planar/custom),
`FocusType`, `CarrierFrequency`, `FocalDepth`, `ApertureDiameter`, `MaxPeakNegativePressure`,
`MaxMechanicalIndex`, `TransducerContactMedium`; and for phased arrays `NumberOfElements`,
`ElementPitch`, `ArrayGeometry`. Object-valued fields use `{Value, Units, Description}`.

**Compound elements.** Two or more physical elements that act together (e.g. the two coils of a
double-coil ccPAS montage) MAY be given as a single compound `element_id` with a compound `ElementType`
(such as `coil_pair`) and a nested array of sub-elements; the sub-element order maps to the pulse order
in `pattern1` and to the order of `position_id`. Equivalently, the elements MAY be listed as a
`|`-delimited `element_id` (e.g. `coil_1|coil_2`) with one `ElementSet` entry each.

### `IntensitySet`

Describes each intensity reference named in `intensity_reference` (renamed from the earlier
`ThresholdSet`). One entry per reference.

| Field | Type | Description |
|---|---|---|
| `IntensityID` | string | Unique id, referenced from `intensity_reference`. |
| `Value` | number | Measured value of the reference (e.g. the rMT). |
| `Units` | string | Units of `Value` (e.g. `% Maximum Stimulator Output`, `mA`). |
| `Type` | string | Reference endpoint, e.g. `resting_motor`, `active_motor`, `phosphene`, `sensation`, `pain`. |
| `Criterion` | string | Criterion defining the reference (e.g. "1 mV MEP", "visible twitch", "perceptible phosphene"). |
| `Algorithm` | string | Estimation procedure (e.g. "5/10", "PEST", staircase, custom). |
| `MeasurementMethod` | string | Modality used to assess the response (e.g. EMG MEP, visual report, behavioural). |

`absolute` is a reserved `intensity_reference` value for directly specified intensities and needs no
`IntensitySet` entry.

### `NavigationSystem`

(Optional; RECOMMENDED when navigation/tracking/robotic positioning is used.)

| Field | Type | Description |
|---|---|---|
| `Navigation` | boolean | Whether a navigation/tracking/positioning system was used. |
| `NavigationHardwareType` | string | e.g. `optical_tracking`, `robot`, `cobot`, `mechanical_arm`. |
| `NavigationModelName` | string | Vendor/model. |
| `NavigationSoftwareVersion` | string | Software version. |
| `NavigationHardwareSerialNumber` | string | Serial/identifier. |
| `NavigationNotes` | string | Setup notes (camera type, calibration, etc.). |

---

## `*_markers.tsv` (spatial positions, carried from v6.2)

One spatial point/contact **per row**, identified by `position_id` and referenced from `position_id`
in `*_events.tsv`. Multi-point constructs (HD-tES montages, multi-coil, multi-focus TUS) are
represented as multiple rows; the corresponding `*_events.tsv` row references them via a `|`-delimited
`position_id`, ordered to match `element_id`. `position_group` MAY group related rows for organization
only (never for linkage or synchronization). Coordinate frame/units are defined in `*_coordsystem.json`.
Numeric fields typed `number`.

| Field | Type | Description |
|---|---|---|
| `position_id` | string | Identifier of a single point/contact (one row). MUST be unique within the file. |
| `position_group` | string | (Optional) Organizational grouping label. MUST NOT be used for linkage/sync. |
| `position_label` | string | (Optional) Standardi