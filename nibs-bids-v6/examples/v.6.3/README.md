# NIBS-BIDS proposal v6.3 (Scalable Structure for Non-Invasive Brain Stimulation)

> **Status:** Draft. This document merges the v6.2 specification with the decisions taken for v6.3.
> It supersedes v6.2 wherever the two differ. Sections that are unchanged in substance from v6.2
> (spatial files, coordinate systems, device hardware blocks) are retained and only re-keyed to the
> new identifiers where needed.

This document describes a scalable structure for organizing **non-invasive brain stimulation (NIBS)**
data in BIDS. It covers Transcranial Magnetic Stimulation (**TMS**), Transcranial Electrical
Stimulation (**TES**, e.g. tDCS, tACS, tRNS, tPCS), Transcranial Ultrasound Stimulation (**TUS**),
and Peripheral Nerve Stimulation (**PNS**).

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
| Multi-element events | Multiple rows indexed by `event_part` | A single row using the **`|` delimiter** in `element_id`, `stimulus_intensity`, `target_id` |
| Numeric typing | many `integer` fields | **`number`** (decimals allowed: 0.5 ms, 1.5 mA, 0.1 Hz) |
| Dose | Applied vs received discussed | Stores **applied** dose only; received/in-tissue E-field is left to modelling (e.g. SimNIBS) |

---

## NIBS as a dedicated `datatype`

All NIBS data is stored under a dedicated `nibs/` folder, treated as a standalone BIDS `datatype`
(peer to `eeg/`, `pet/`, `motion/`). Modality (TMS/TES/TUS/PNS) is recorded in the `nibs_type`
column rather than in the filename.

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

Optional files: `*_headshape.<ext>` and `*_photo.<ext>` (see "Optional files").

---

## Core files and the linking model

| File | Role |
|---|---|
| `*_nibs.tsv` | Central table. **One row per unique stimulation parameter set** ("event type"). Holds the actual parameter values. |
| `*_nibs.json` | Sidecar. Column descriptions/units/levels **and** device metadata (`StimulatorSet`, `ElementSet`, `NavigationSystem`). |
| `*_markers.tsv` (+ `.json`) | Spatial targets (one point/contact per row). |
| `*_coordsystem.json` | Coordinate system, fiducials, landmarks. |
| `*_events.tsv` (+ `.json`) | Primary timeline (`onset`, `duration`, `event_id`) for synchronization. |

Linking identifiers:

- **`event_id`** — links a row of `*_nibs.tsv` to one or more onsets in `*_events.tsv`. A parameter
  set is defined once in `*_nibs.tsv` and can be referenced many times in `*_events.tsv`.
  `event_id` MUST be unique within a `*_nibs.tsv` file.
- **`element_id`** — links to `ElementSet.ElementID` in `*_nibs.json`. Multiple simultaneous elements
  (e.g. tES electrodes, multi-coil) are listed in one cell separated by `|`.
- **`stimulator_id`** — links to `StimulatorSet.StimulatorID` in `*_nibs.json`.
- **`target_id`** — links to a row in `*_markers.tsv` (spatial location). May be delimited with `|`
  to give one target per element, in the same order as `element_id`.

**Delimiter rule.** Whenever `|` is used in a column, the delimiter MUST be declared for that column
in `*_nibs.json`, e.g. `{"element_id": {"Delimiter": "|"}}`.

**Synchronization** across modalities (EEG, MEG, fMRI, EMG, behaviour) is performed **only** via
`event_id` and the shared `*_events.tsv` timeline. When NIBS is concurrent with another recorded
modality, the timeline may live with that modality's `*_events.tsv`; `*_nibs.json` then points to it
with `IntendedFor`.

---

## `*_nibs.tsv` — stimulation parameters

Each row represents one **logical stimulation event type** with a unique set of parameters.
A row may describe a single stimulus, or repeating/nested stimuli described parametrically with
the `pattern<index>_*` fields. All fields are OPTIONAL unless stated; numeric fields are typed
`number` (decimals allowed). Units for every numeric column MUST be declared in `*_nibs.json`.

### General fields

| Field | Type | Description |
|---|---|---|
| `event_id` | string | Identifier of a stimulation event type with unique parameters. May describe a single stimulus or repeating/nested stimuli. Used for linkage to `*_events.tsv`. MUST be unique within the file. |
| `nibs_type` | string | Stimulation modality: `TMS` \| `tES` \| `TUS` \| `PNS`. (PNS uses whichever physical technology applies; the stimulated nerve is described via `target_*` in `*_markers.tsv`.) |
| `stimulator_id` | string | Label of the device that generates the stimulus waveform. Links to `StimulatorSet.StimulatorID` in `*_nibs.json`. |
| `element_id` | string | Label of the element that delivers stimulation (coil/electrode/transducer). Links to `ElementSet.ElementID`. Multiple elements separated by `\|` (e.g. `elec_1\|elec_2`); declare the delimiter in `*_nibs.json`. |
| `target_id` | string | Spatial target(s) for this event. Links to `target_id` in `*_markers.tsv`. May be delimited with `\|`, one per element, in the same order as `element_id`. |

### Stimulus fields (the base unit)

| Field | Type | Description |
|---|---|---|
| `stimulus_shape` | string | Shape of the base stimulus: `Monophasic` \| `Biphasic` \| `Rectangle` \| `Sinusoid` \| `Noise` \| custom. Shape-specific parameters are stored in `*_nibs.json` under `Levels` (see below). |
| `stimulus_intensity` | number | Amplitude of the base stimulus. Units are modality-dependent and declared in `*_nibs.json` (e.g. `% Maximum Stimulator Output` for TMS, `mA` for TES). Where multiple elements are given in `element_id`, one value per element separated by `\|` (e.g. `1\|-1`). For `tES`, the delimited values MUST sum to 0. Set to `n/a` when per-stimulus intensities are instead given in `pattern1_intensity` (see "Changing intensity"). |
| `stimulus_duration` | number | Duration of the base stimulus (time during which contiguous non-zero current/energy is delivered). Units declared in `*_nibs.json`. |

Shape-specific parameters live in the JSON sidecar under `stimulus_shape.Levels`, for example a
10 Hz sinusoid:

```json
"stimulus_shape": { "Levels": { "Sinusoid": { "Frequency": 10 } } }
```

Recognised key/value pairs include: `Frequency` (Hz), `RampUpDuration` (s), `RampDownDuration` (s),
`Offset` (mA), `NoiseType` (e.g. "Pink noise"), `Window` (e.g. "Tukey"), `StartingPhase` (deg).

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

Two distinct uses of a delimited intensity vector:

1. **Across elements (same instant):** `stimulus_intensity = 1|-1` — one value per `element_id`
   (the spatial split between, e.g., anode/cathode). For `tES` the values MUST sum to 0.
2. **Across repeats (over time):** when the intensity differs between successive stimuli within a
   layer, set `stimulus_intensity = n/a` and give the vector in `pattern1_intensity` (length =
   `pattern1_count`). The canonical case is paired-pulse TMS (e.g. SICI: conditioning then test).

### Dosing and threshold fields (carried from v6.2)

These OPTIONAL fields support threshold-based dosing. They apply per row and are typed `number`
unless noted.

| Field | Type | Description |
|---|---|---|
| `threshold_type` | string | Reference endpoint for dosing (e.g. `resting_motor`, `active_motor`, `phosphene`, `sensation`, `pain`, custom). |
| `threshold_reference_intensity` | number | Device-output value corresponding to the threshold (e.g. %MSO for TMS, mA/V for TES). |
| `threshold_intensity` | number | Stimulation intensity expressed relative to the threshold (e.g. 110 = 110% of threshold). Expressed in the same scale as the base intensity used in the row. |
| `threshold_criterion` | string | Criterion defining the threshold (e.g. "1 mV MEP", "visible twitch", "perceptible phosphene"). |
| `threshold_algorithm` | string | Estimation procedure (e.g. "5/10", "PEST", staircase, custom). |
| `threshold_measurement_method` | string | Modality used to assess the response (e.g. EMG MEP, visual report, behavioural). |

If a `pattern<index>_intensity` vector is given relative to threshold, `threshold_intensity` SHOULD be
omitted to avoid double-specification. When both a base intensity and a threshold-relative intensity
are present they MUST be numerically consistent with `threshold_reference_intensity`.

### Derived / measured fields (carried from v6.2)

Reported or computed by the device/navigation system; not experimenter-set. All OPTIONAL.

**Common**

| Field | Type | Description |
|---|---|---|
| `stimulus_count` | number | Counter of deliveries of the same parameter set to the same target within the file. Counting only — MUST NOT be used for synchronization. |
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
| `motor_response` | number | Procedure-level motor-response summary (e.g. for threshold setting); not an EMG waveform. |
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

## `*_nibs.json` — sidecar

A standard BIDS JSON sidecar that (a) describes each `*_nibs.tsv` column (`LongName`, `Description`,
`Units`, `Levels`, `Delimiter`), and (b) carries structured device and context metadata. Numeric
columns SHOULD be documented as `number`.

Top-level descriptive fields:

- `NIBSDescription` — free-text summary of the protocol.
- `ConcurrentModalities` — array of concurrently recorded modalities (e.g. `["eeg"]`, `["emg"]`, `["none"]`).
- `IntendedFor` — BIDS URI to the `*_events.tsv` (or recording) the stimulation is time-locked to.
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
| `ElementType` | string | `coil` \| `electrode` \| `transducer`. |
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

## `*_markers.tsv` — spatial targets (carried from v6.2)

One spatial point/contact **per row**, identified by `target_id` and referenced from `*_nibs.tsv`.
Multi-point constructs (HD-tES montages, multi-coil, multi-focus TUS) are represented as multiple
rows; the corresponding `*_nibs.tsv` row references them via a `|`-delimited `target_id`, ordered to
match `element_id`. `target_group` MAY group related rows for organization only (never for linkage or
synchronization). Coordinate frame/units are defined in `*_coordsystem.json`. Numeric fields typed
`number`.

| Field | Type | Description |
|---|---|---|
| `target_id` | string | Identifier of a single point/contact (one row). MUST be unique within the file. |
| `target_group` | string | (Optional) Organizational grouping label. MUST NOT be used for linkage/sync. |
| `target_label` | string | (Optional) Standardized label (e.g. 10–20 `C3`, `F3`; site labels `M1_hand`, `DLPFC`). |
| `target_description` | string | (Optional) Free-text rationale/landmark description. |
| `target_x` / `target_y` / `target_z` | number | Target point (TMS cortical target; TUS acoustic focus). |
| `entry_x` / `entry_y` / `entry_z` | number | Entry point (TES scalp electrode position; TUS beam entry). |
| `peeling_depth` | number | (Optional) Depth from cortical surface / entry to target. |
| `coil_x` / `coil_y` / `coil_z` | number | (TMS) Coil origin location. |
| `normal_x` / `normal_y` / `normal_z` | number | Coil/transducer normal vector. |
| `direction_x` / `direction_y` / `direction_z` | number | (TMS) Coil direction vector. |
| `beam_x` / `beam_y` / `beam_z` | number | (TUS) Beam-propagation direction vector. |
| `transducer_x` / `transducer_y` / `transducer_z` | number | (TUS) Transducer centre. |
| `coil_transform` / `transducer_transform` | array[number] | (Optional) 4×4 affine pose matrix. |
| `electric_field_max_x` / `_y` / `_z` | number | (Optional) Location of maximum E-field. |

Field ordering follows function: identification (`target_id`), position (`target_*`, `entry_*`,
`peeling_depth`, `coil_*`/`transducer_*`), orientation/pose (`normal_*`, `direction_*`, `beam_*`,
`*_transform`), then optional E-field location. Basic datasets may include only `target_*`/`entry_*`;
advanced datasets add full pose and field modelling.

A `*_markers.json` sidecar MAY describe these columns (units, descriptions).

---

## `*_coordsystem.json` — coordinate metadata (carried from v6.2)

Specifies the coordinate system, units, fiducials and anatomical landmarks in which target/marker
positions are expressed. REQUIRED for navigated TMS/TES/TUS datasets. Key fields:
`NIBSCoordinateSystem`, `NIBSCoordinateUnits`, `NIBSCoordinateSystemDescription`, `IntendedFor`
(path to the anatomical reference), `FiducialsCoordinates`/`FiducialsCoordinateSystem`/`…Units`,
`AnatomicalLandmarkCoordinates`/`…System`/`…Units`/`…Description`, `HeadMeasurements`,
`DigitizedHeadPoints`(+`Number`/`Units`/`Description`), and `AnatomicalLandmarkRmsDeviation`.
TUS datasets MAY add transducer-pose fields: `TransducerCoordinates`/`…Units`/`…Description`,
`TransducerCoordinatesDescription`, and `TransducerRmsDeviation`(+`Units`/`Description`).
(Definitions unchanged from v6.2.)

---

## `*_events.tsv` / `*_events.json` — timeline

The primary experimental timeline used for synchronization across modalities.

| Field | Type | Description |
|---|---|---|
| `onset` | number | Onset of the event (s). |
| `duration` | number | Duration of the event (s); `n/a` if not applicable. May be derived from the `*_nibs.tsv` pattern fields. |
| `event_id` | string | References the matching `event_id` in `*_nibs.tsv`. |

A standalone NIBS session keeps `*_events.tsv` in `nibs/`. When NIBS is concurrent with another
recorded modality (e.g. EMG), the timeline lives with that modality's `*_events.tsv`, and
`*_nibs.json` references it via `IntendedFor`. `event_id` is the sole cross-modality linkage key.

---

## Optional files

- `*_headshape.<ext>` — digitized head points (e.g. `sub-01_..._acq-HEAD_headshape.pos`), supplementing
  the `DigitizedHeadPoints*` fields in `*_coordsystem.json`.
- `*_photo.<ext>` (`.jpg`/`.png`/`.tif`) — photos of landmarks/fiducials; crop/blur to remove
  identifying features before sharing. `acq-<label>` distinguishes multiple photos.

---

## Appendix A — Worked examples

Examples use the v6.3 column model. Units are declared in each `*_nibs.json`
(here: TMS intensity = %MSO, TMS duration = µs, pattern frequency = Hz, pattern duration = s;
TES intensity = mA, TES duration = min).

### A.1 Intermittent theta-burst TMS (nested patterns)

3 pulses at 50 Hz (burst), bursts at 5 Hz for 2 s (= 10 bursts/train), 20 trains every 10 s →
**600 pulses, 200 s**.

```
event_id  nibs_type  stimulator_id  element_id  stimulus_shape  stimulus_intensity  stimulus_duration  pattern1_frequency  pattern1_count  pattern2_frequency  pattern2_duration  pattern3_count  pattern3_duration
itbs      TMS        Magstim        Coil_1      Biphasic        50                  200                50                  3               5                   2                  20              200
```

- pattern1 (burst): `count=3`, `frequency=50` → 3 pulses at 50 Hz.
- pattern2 (train): `frequency=5`, `duration=2` → bursts at 5 Hz for 2 s (count = 10, derived).
- pattern3 (sequence): `count=20`, `duration=200` → 20 trains; interval = 200/20 = 10 s (8 s off per 2 s on).

### A.2 Single- and paired-pulse TMS (SICI) — changing intensity across repeats

Single pulse at 50 %MSO; SICI = 2 pulses, 2 ms ISI, conditioning 35 % then test 50 %.

```
event_id  nibs_type  stimulator_id  element_id  stimulus_shape  stimulus_intensity  stimulus_duration  pattern1_count  pattern1_interval  pattern1_intensity
spTMS     TMS        Magstim        Coil_1      Monophasic      50                  200                n/a             n/a                n/a
SICI      TMS        Magstim        Coil_1      Monophasic      n/a                 200                2               2                  35|50
```

`*_events.tsv` then lists the onsets of `spTMS`/`SICI` interleaved across the session.

### A.3 tDCS — multi-element, single row

2 mA, two sponge electrodes, 10 min, 30 s ramps. `element_id`, `stimulus_intensity` and (optionally)
`target_id` are `|`-delimited and aligned.

```
event_id  nibs_type  stimulator_id  element_id      stimulus_shape  stimulus_intensity  stimulus_duration
tdcs      tES        Soterix        elec_1|elec_2   Rectangle       1|-1                10
```

JSON: `"stimulus_shape": {"Levels": {"Rectangle": {"RampUp": 30, "RampDown": 30}}}`,
`"stimulus_intensity": {"Units": "mA", "Delimiter": "|"}`, `"element_id": {"Delimiter": "|"}`.
(For HD montages, e.g. 1 anode + 4 returns, list 5 `element_id`s and 5 intensities such as
`2|-0.5|-0.5|-0.5|-0.5`, still summing to 0.)

### A.4 tACS — sinusoidal

10 Hz, 1 mA peak per electrode, 10 min.

```
event_id  nibs_type  stimulator_id  element_id      stimulus_shape  stimulus_intensity  stimulus_duration
tacs      tES        Soterix        elec_1|elec_2   Sinusoid        1|-1                10
```

JSON: `"stimulus_shape": {"Levels": {"Sinusoid": {"Frequency": 10}}}`.

### A.5 tRNS — band-limited noise

```
event_id  nibs_type  stimulator_id  element_id      stimulus_shape  stimulus_intensity  stimulus_duration
trns      tES        Soterix        elec_1|elec_2   Noise           1|-1                10
```

JSON: `"stimulus_shape": {"Levels": {"Noise": {"NoiseType": "white", "Frequency": [100, 640]}}}`
(declare the band and any update rate as needed).

### A.6 TUS — pulsed, single focus

Carrier 500 kHz; 5 pulses of 200 µs at 1 ms PRI (one stimulation instance), targeting one focus.
The within-instance pulse train is `pattern1`; the focus is a `target_id` in `*_markers.tsv`;
`ElementType = transducer` describes the device.

```
event_id  nibs_type  stimulator_id  element_id  stimulus_shape  stimulus_intensity  stimulus_duration  pattern1_count  pattern1_interval  target_id
tus       TUS        ExampleTUS     tx_1        Sinusoid        <Isppa>             200                5               1                  target_01
```

Multi-focus beam steering is represented with a `|`-delimited `target_id` (one focus per delivery),
ordered as stimulated; the order can also be made explicit in the JSON.

---

## Appendix B — Migration notes (v6.2 → v6.3)

- Remove the `stimsys-<label>` filename entity; add the `nibs_type` column.
- Replace `coil_id`/`electrode_id`/`transducer_id` with `stimulator_id` + `element_id`; fold
  `CoilSet`/`ElectrodeSet`/`TransducerSet` into one `ElementSet` (`ElementType`).
- Replace per-pulse/`StimulusSet` parameters and the `pulse`/`train`/`repeat` timing with the base
  `stimulus_*` fields plus `pattern<index>_*` layers.
- Replace multi-row `event_part` events with single rows using `|`-delimited `element_id` /
  `stimulus_intensity` / `target_id`.
- Type numeric fields as `number` (not `integer`); declare units per column in `*_nibs.json`.
- Spatial (`*_markers.tsv`, `*_coordsystem.json`) and dosing/threshold/derived fields are retained;
  only their linkage keys change (`target_id`; `|` delimiters).
