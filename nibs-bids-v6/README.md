# NIBS-BIDS proposal v.6.2 (Scalable Structure for Non-Invasive Brain Stimulation)

### This document presents a concise overview of our proposed scalable structure for organizing **non-invasive brain stimulation (NIBS)** data in BIDS. 

### It is designed to precede and accompany real-life examples and comparative demonstrations.


## 1. NIBS as a Dedicated `datatype`

* All data related to non-invasive brain stimulation is stored under a dedicated `nibs/` folder.
* This folder is treated as a standalone BIDS `datatype`, similar in role to `eeg/`, `pet/`, or `motion/`.
* This design allows coherent grouping of stimulation parameters, spatial data, and metadata.

### Template:

```
sub-<label>/
└── [ses-<label>/]
    └── nibs/
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>]_coordsystem.json
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.tsv
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.json
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.tsv
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.json
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_events.tsv
        └── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_events.json
```

### Scalable File Naming Convention

The following files are used to organize stimulation-related data:

- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.tsv`
- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.json`

  * Contains stimulation protocol, intensity and timings parameters + metadata.

- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.tsv` 
- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.json` 

  * Contains 3D coordinates of stimulation points (entry, target, etc.), coil spatial orientation, and electric field vectors + metadata.	
  * Equivalent to similar `*_electrodes.tsv or _optodes.tsv`.
  
- `sub-<label>_task-<label>[_stimsys-<label>]_coordsystem.json` 

  * Describes the coordinate system used in the stimulation session.
  * Equivalent to the former `*_coordsystem.json`.
  
## 2. Supported Stimulation Modalities

* The structure supports multiple types of NIBS techniques:

  * Transcranial Magnetic Stimulation (**TMS**)
  
  * Transcranial Electrical Stimulation (**TES**, e.g., tDCS, tACS)
  
  * Transcranial Ultrasound Stimulation (**TUS**)
  
  * Peripheral Nerve Stimulation (**PNS**) -> under development
  
  
## 3. Modality-Specific Suffix via `stimsys`

* To distinguish between different stimulation systems, we introduce the suffix `stimsys` (kind of analogous to `tracksys` in the `/motion` datatype).
* The `stimsys` suffix can take values like `tms`, `tes`, `tus` or `pns`.

The `stimsys-<label>` entity can be used as a key-value pair to label `*_nibs.tsv` and `*_nibs.json` files. 
It can also be used to label `*_markers.tsv`; `*_markers.json` or `*_coordsystem.json` files when they belong to a specific stimulation system.
This entity corresponds to the `StimulationSystem` metadata field in a `*_nibs.json` file. `stimsys-<label>` entity is a concise string whereas `StimulationSystem` may be longer and more human readable.


## 4. Internal NIBS File Linking

This section defines linkage keys used **within the NIBS datatype** to connect tabular stimulation records (`*_nibs.tsv`) to (i) structured stimulation/coil metadata (`*_nibs.json`) and (ii) spatial target definitions (`*_markers.tsv` and `*_coordsystem.json`). 
Links to time-locked annotations (via `*_events.tsv`) are described in the synchronization section.

| Source file    |  Key (in source)  | Target file     | Target object / meaning  																			|
|----------------|-------------------|-----------------|----------------------------------------------------------------------------------------------------|
| `*_nibs.tsv`   | `coil_id`         | `*_nibs.json`   | References `CoilSet` entries (`CoilID`) describing the coil used. 									|
| `*_nibs.tsv`   | `stim_id`         | `*_nibs.json`   | References `StimulusSet` entries (`StimID`) describing the stimulation instance configuration used.|
| `*_nibs.tsv`   | `target_id`       | `*_markers.tsv` | References spatial target definitions (with coordinate context in `*_coordsystem.json`). 			|

### Linking keys

#### `coil_id` → `CoilID` (`CoilSet` in `*_nibs.json`)
- `coil_id` in `*_nibs.tsv` MUST reference a `CoilID` defined in the `CoilSet` section of `*_nibs.json`.
- `CoilID` values MUST be unique within a given `*_nibs.json`.
- The same `coil_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same coil definition applies.

#### `stim_id` → `StimID` (`StimulusSet` in `*_nibs.json`)
- `stim_id` in `*_nibs.tsv` MUST reference a `StimID` defined in the `StimulusSet` section of `*_nibs.json`.
- `StimID` values MUST be unique within a given `*_nibs.json`.
- The same `stim_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same stimulation configuration/pattern applies.

#### `target_id` (spatial targets in `*_markers.tsv`)

- `target_id` is the identifier of a stimulation target at the **stimulation level**. A target MAY be a single spatial point (e.g., typical TMS) or a **composite/multi-point target** (e.g., TES electrode pair, TUS target with entry points).
- `target_id` in `*_nibs.tsv` MUST reference `target_id` values in `*_markers.tsv`.
-  The coordinate context for targets is defined in `*_coordsystem.json`.

### Composite (multi-point) targets in `*_markers.tsv` (multi-contact modalities)

Some modalities (e.g., TES, TUS) require multiple spatial points to describe one stimulation target. In such cases, `*_markers.tsv` MAY contain multiple rows with the same `target_id` to represent all points belonging to that composite target.

- When multiple rows share the same `target_id`, `*_markers.tsv` MUST include an additional column (e.g., `target_part`) to disambiguate points within that target.
- The pair (`target_id`, `target_part`) MUST be unique within `*_markers.tsv`.
- `target_part` values SHOULD start at 1 and increment monotonically (1..N) for all points belonging to a given `target_id`.
- A modality-specific role column MAY be used to label points within a composite target (e.g., `anode`/`cathode` for TES, `target`/`entry` for TUS).

For TMS, `target_id` typically references a single spatial point; in this case `target_part` is usually not required.


### Synchronizing NIBS Data Across Modalities (`*_events.tsv`)

#### Core idea

`*_events.tsv` is used to time-lock NIBS stimulation information to data recorded in the same session and/or across modalities. 

In the NIBS datatype, synchronization is performed using a dedicated event identifier (`event_id`) that links time-locked annotations in `*_events.tsv` to stimulation records in `*_nibs.tsv`.

#### Linking keys

##### `event_id`

- **Definition:** `event_id` identifies a single **logical stimulation event** (i.e., one initiated stimulation execution that completes as a whole).
- **File usage:**
  - `*_nibs.tsv`: `event_id` is REQUIRED for each logical stimulation event record.
  - `*_events.tsv`: `event_id` MAY be included to reference the corresponding stimulation event(s) described in `*_nibs.tsv`.
- **Uniqueness and scope:** `event_id` MUST be unique within a single `*_nibs.tsv` file (i.e., within the recording/session scope of that file).

##### `event_part` (optional)

Some logical stimulation events cannot be represented as a single row in `*_nibs.tsv` (e.g., when a complex protocol must be split into multiple configuration segments). In such cases, multiple rows MAY share the same `event_id`.

- **Definition:** `event_part` is an index that disambiguates multiple `*_nibs.tsv` rows belonging to the same `event_id`.
- **File usage:**
  - `*_nibs.tsv`: `event_part` is OPTIONAL, but MUST be present when more than one row shares the same `event_id`.
  - `*_events.tsv`: `event_part` is not required and is typically omitted.
- **Uniqueness constraint:** For any given `event_id`, `event_part` MUST be unique across all rows sharing that `event_id`.
- **Recommended convention:** `event_part` values SHOULD start at 1 and increment monotonically (1..N) for all rows belonging to the same `event_id`.

#### Notes on other identifiers

- `stim_id` links `*_nibs.tsv` to stimulation configuration metadata in `*_nibs.json` and is not used for synchronization.
- `target_id` links `*_nibs.tsv` to spatial targets in `*_markers.tsv` and MUST NOT be duplicated in `*_events.tsv`.

#### File-linking overview 

```
                ┌──────────────────────────┐
                │        *_nibs.json       │
                │  CoilSet:    CoilID ...  │
                │  StimulusSet: StimID ... │
                └─────────────┬────────────┘
                              │
                    coil_id → CoilID
                    stim_id → StimID
                              │
┌─────────────────────────────▼─────────────────────────────┐
│                        *_nibs.tsv                         │
│  (logical stimulation events; may be split into parts)    │
│  Required:  event_id                                      │
│  Optional:  event_part (only if multiple rows share event)│
│  Links:     coil_id, stim_id, target_id                   │
│  Count:     stim_count (NOT for synchronization)          │
└─────────────┬───────────────────────────────┬─────────────┘
              │                               │
           target_id                        event_id
              │                               │
              ▼                               ▼
┌──────────────────────────┐        ┌────────────────────────┐
│       *_markers.tsv      │        │       *_events.tsv     │
│  target_id  target_part  │        │  onset/duration/...    │
│  (target_id can repeat;  │        │  MAY include event_id  │
│   (target_id,target_part)│        │  (time-locking)        │
│   unique)                │        │  MUST NOT include      │
└─────────────┬────────────┘        │  target_id             │
              │                     └────────────────────────┘
              ▼
┌──────────────────────────┐
│    *_coordsystem.json    │
│ (coordinate context for  │
│  markers/targets)        │
└──────────────────────────┘
```

Read it like this:

- `*_nibs.tsv` describes what was executed (logical stimulation events and, if needed, their event_parts), and links to configuration (`*_nibs.json`) and space (`*_markers.tsv`).

- `*_events.tsv` describes when it happened (time-locking) via `event_id`.

- `*_markers.tsv` + `*_coordsystem.json` describe where it happened; composite targets are represented by multiple marker rows sharing `target_id`, disambiguated by `target_part`.


# Detailed overview of data structure

### non-invasive-brain-stimulation-v6.2.md
