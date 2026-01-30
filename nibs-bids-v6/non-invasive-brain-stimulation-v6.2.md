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

### `*_coordsystem.json` — Coordinate Metadata

A _coordsystem.json file is used to specify the fiducials, the location of anatomical landmarks, and the coordinate system and units in which the position of landmarks or TMS stimulation targets is expressed. 
Anatomical landmarks are locations on a research subject such as the nasion (for a detailed definition see the coordinate system appendix).
The _coordsystem.json file is REQUIRED for navigated TMS, TES, TUS stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the TMS, TES, TUS data.


| Field                                           | Type    | Description                                                                                                                                                                                                                                                                     
| ----------------------------------------------- | ------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
| `IntendedFor`                                   | string  | Path to the anatomical file this coordinate system refers to. BIDS-style path. (example: `bids::sub-01/ses-01/anat/sub-01_T1w.nii.gz`)                                                                                                                                          			
| `NIBSCoordinateSystem`						  | string  | Name of the coordinate system used to define the spatial location of stimulation targets. Common values for TUS include: IndividualMRI, MNI152NLin2009cAsym, or CapTrak.																														
| `NIBSCoordinateUnits`							  | string  | Units used to express spatial coordinates in *_markers.tsv. Typically mm (millimeters) for MRI-based spaces.																																												
| `NIBSCoordinateSystemDescription`				  | string  | Free-text description providing details on how the coordinate system was defined. This may include registration methods (e.g., neuronavigation, manual annotation), whether coordinates represent the ultrasound focus or entry point, and how the space aligns with anatomical references.
| `AnatomicalLandmarkCoordinateSystem`            | string  | Defines the coordinate system for the anatomical landmarks. See the Coordinate Systems Appendix for a list of restricted keywords for coordinate systems. If "Other", provide definition of the coordinate system in `AnatomicalLandmarkCoordinateSystemDescription`.           	
| `AnatomicalLandmarkCoordinateSystemUnits`       | string  | Units of the coordinates of Anatomical Landmark Coordinate System. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                              	
| `AnatomicalLandmarkCoordinateSystemDescription` | string  | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail.                                                                                                                          		
| `AnatomicalLandmarkCoordinates`                 | object  | Key-value pairs of the labels and 3-D digitized locations of anatomical landmarks, interpreted following the `AnatomicalLandmarkCoordinateSystem`. Each array MUST contain three numeric values corresponding to x, y, and z axis of the coordinate system in that exact order.			
| `AnatomicalLandmarkCoordinatesDescription`      | string  | `[x, y, z]` coordinates of anatomical landmarks. NAS — nasion, LPA — left preauricular point, RPA — right preauricular point                                                                                                                                                    				
| `HeadMeasurements`							  | object  | Object containing one or more head measurement vectors relevant for 10–20–based navigation. Each value MUST be a numeric array.
| `HeadMeasurementsUnits`						  | string  | Units used for all values stored in HeadMeasurements (e.g., "mm").
| `HeadMeasurementsDescription`					  | string  | Free-form description of how HeadMeasurements were obtained (e.g., tape/geodesic along scalp vs. Euclidean), including any conventions (landmark definitions, repetitions, averaging).
| `DigitizedHeadPoints`                           | string  | Relative path to the file containing the locations of digitized head points collected during the session. (for example, `"sub-01_headshape.pos"`)                                                                                                                               	
| `DigitizedHeadPointsNumber`                     | integer | Number of digitized head points during co-registration.                                                                                                                                                                                                                       		
| `DigitizedHeadPointsDescription`                | string  | Free-form description of digitized points.                                                                                                                                                                                                                                      			
| `DigitizedHeadPointsUnits`                      | string  | Unit type. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                                                                                      		
| `AnatomicalLandmarkRmsDeviation`                | object  | `{"RMS":[],"NAS":[],"LPA":[],"RPA":[]}` — deviation values per landmark                                                                                                                                                                                                         		
| `AnatomicalLandmarkRmsDeviationUnits`           | string  | Unit of RMS deviation values.                                                                                                                                                                                                                                               			
| `AnatomicalLandmarkRmsDeviationDescription`     | string  | Description of how RMS deviation is calculated and for which markers.                                                                                                                                                                                                         		


### TUS-specific transducer coordinate metadata fields (*_coordsystem.json)

These optional fields are recommended for transcranial ultrasound stimulation (TUS) datasets when the spatial position and/or orientation of the ultrasound transducer is known or fixed (e.g., in neuronavigated or modeled setups). 
They complement the standard NIBSCoordinateSystem fields, which typically describe the focus location.
Optional QC metric (in mm) representing the root-mean-square deviation of the ultrasound transducer's actual position and/or orientation from its intended location.
This may be computed from optical tracking, neuronavigation logs, or mechanical fixation assessment.


| Field                                         | Type    | Description                                                          |                                                                                                                                                                                                           
| ----------------------------------------------| ------  | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| `TransducerCoordinateUnits`					| string  | Units of measurement for transducer coordinates (typically mm).|
| `TransducerCoordinateSystemDescription`		| string  | Textual description of how the transducer coordinate system was defined and aligned with anatomy.|
| `TransducerCoordinates`						| object  | Dictionary with spatial coordinates (e.g., X, Y, Z ) and optionally 4×4 affine transformation matrix for transducer orientation.|
| `TransducerCoordinatesDescription`			| string  | Free-text explanation of what the coordinates represent (e.g., transducer center, entry point, beam axis, etc.).|
| `TransducerRmsDeviation`						| string  | Root-mean-square deviation (in millimeters) of the ultrasound transducer’s actual position and/or orientation from the planned or intended placement, typically computed across time or repeated trials.|
| `TransducerRmsDeviationUnits`   				| string  | Units used to express the RMS deviation value. Must be consistent with the spatial coordinate system units (e.g., "mm").|
| `TransducerRmsDeviationDescription`			| string  | Free-text description of how the deviation was calculated, including what was measured (e.g., position, angle), over what time frame, and using which method (e.g., optical tracking, neuronavigation, manual estimate).|

*These fields enable reproducible modeling, visualization, and interpretation of TUS targeting and acoustic beam propagation when precise transducer positioning is known.

### Optional Headshape Files (*_headshape.<extension>)

This file is RECOMMENDED.

3D digitized head points  that describe the head shape and/or EEG electrode locations can be digitized and stored in separate files. 
These files are typically used to improve the accuracy of co-registration between the stimulation target, anatomical data, etc. 

** For example:**

```
sub-<label>/
└── [ses-<label>/]
    └── nibs/
        └── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>]_acq-HEAD_headshape.pos 

```
These files supplement the DigitizedHeadPoints, DigitizedHeadPointsUnits, and DigitizedHeadPointsDescription fields in the corresponding _coordsystem.json file. 
Their inclusion is especially useful when sharing datasets intended for advanced spatial analysis or electric field modeling.

## NIBS: Transcranial Magnetic Stimulation section

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `*_markers.json` )

Stores stimulation target coordinates and optional coil's orientation information. Supports multiple navigation systems (e.g., Localite, Nexstim) via flexible fields. 


| Field | Type | Description |
|---|---|---|
| `target_id` | string | `target_id` identifies a stimulation target at the stimulation level. A target MAY be represented by a single point (one row) or by multiple points (multiple rows) sharing the same `target_id`. |
| `target_part` | integer | (Optional) Index of a point within a composite target sharing the same `target_id`. REQUIRED when a `target_id` corresponds to multiple rows in `*_markers.tsv`; OPTIONAL otherwise. Values SHOULD start at 1 and increment monotonically (1..N). (For typical TMS targets represented by a single point, `target_part` is usually not required.) |
| `target_name` | string | (Optional) Name of the cortical target, anatomical label, or stimulation site (purely human-readable label such as: M1_hand, DLPFC, etc.). |
| `peeling_depth` | number | (Optional) Depth/distance from cortex surface to the target point OR from the entry marker to the target marker. |
| `target_x` | number | X-coordinate of the target point in millimeters. |
| `target_y` | number | Y-coordinate of the target point in millimeters. |
| `target_z` | number | Z-coordinate of the target point in millimeters. |
| `entry_x` | number | X-coordinate of the entry point in millimeters. |
| `entry_y` | number | Y-coordinate of the entry point in millimeters. |
| `entry_z` | number | Z-coordinate of the entry point in millimeters. |
| `coil_transform` | array[number] | (Optional) 4×4 affine transformation matrix for coil positioning (e.g., instrument markers in Localite systems). |
| `coil_x` | number | X component of coil origin location. |
| `coil_y` | number | Y component of coil origin location. |
| `coil_z` | number | Z component of coil origin location. |
| `normal_x` | number | X component of coil normal vector. |
| `normal_y` | number | Y component of coil normal vector. |
| `normal_z` | number | Z component of coil normal vector. |
| `direction_x` | number | X component of coil direction vector. |
| `direction_y` | number | Y component of coil direction vector. |
| `direction_z` | number | Z component of coil direction vector. |
| `electric_field_max_x` | number | (Optional) X-coordinate of the maximum electric-field point. |
| `electric_field_max_y` | number | (Optional) Y-coordinate of the maximum electric-field point. |
| `electric_field_max_z` | number | (Optional) Z-coordinate of the maximum electric-field point. |
| `timestamp` | string | (Optional) Timestamp of the stimulation event in ISO 8601 format. |


* timestamp in _markers.tsv, when present, reflects the time at which spatial data were recorded or updated (e.g., neuronavigation update), not necessarily the time of stimulus delivery.

### Field Ordering Rationale

The `_markers.tsv` file defines the spatial locations and (where applicable) orientation-related metadata for stimulation targets used across NIBS experiments (e.g., TMS, TES, TUS).
When designing this structure, we drew partial inspiration from existing BIDS files such as `*_electrodes.tsv` (eeg), which capture sensor positions.
However, no existing BIDS modality explicitly supports the full specification required for navigated TMS — including stimulation coordinates, coil pose/orientation, and optional electric field estimates — while TES/TUS introduce additional multi-point target constructs (e.g., electrode pairs, entry points).

This makes `_markers.tsv` a novel file type tailored to NIBS needs. Fields are ordered to reflect their functional roles:

- Identification: `target_id` appears first, enabling structured referencing from `*_nibs.tsv`. For composite targets (multiple spatial points describing one stimulation target), `target_part` is used to disambiguate rows sharing the same `target_id`.
- Spatial coordinates: `target_`, `entry_`, and `peeling_depth` describe the position of stimulation-related points in the selected coordinate system (modality-dependent). `coil(x,y,z)` describe the position of the TMS coil in the selected coordinate system.
- Orientation / pose: `normal_` and `direction_` vectors or the transformation matrix `coil_transform` define the coil orientation/pose in 3D space — a critical factor in modeling TMS effects.
- Electric field (optional): `electric_field_max_` defines where the electric field is maximized.

This design is scalable and supports both minimal and advanced use cases: basic datasets can include just the spatial coordinates, while high-resolution multimodal studies can specify full pose/orientation and field modeling parameters when available.

### 1.2 `*_nibs.json` — Sidecar JSON 

The `*_nibs.json` file is a required sidecar accompanying the `*_nibs.tsv` file. 
It serves to describe the columns in the tabular file, define units and levels for categorical variables, and—crucially—provide structured metadata about the stimulation device, task, and context of the experiment.

* Like other BIDS modalities, this JSON file includes:

**Task information**

- `TaskName`, `TaskDescription`, `Instructions`
 
**Institutional context**

- `InstitutionName`, `InstitutionAddress`, `InstitutionalDepartmentName`

**Device metadata**

- `Manufacturer`, `ManufacturersModelName`, `SoftwareVersion`, `DeviceSerialNumber`.

**Additional options**

- `CoilSet`, `StimulusSet`, `StimulationSystem`, `NavigationSystem` 

#### `CoilSet` 

The `*_nibs.json` file introduces a dedicated hardware block called `CoilSet`, which captures detailed physical and electromagnetic parameters of one or more stimulation coils used in the session.

`CoilSet` is an array of coil definitions. Each entry is identified by `CoilID`, which is referenced from `*_nibs.tsv` via `coil_id`.

This structure allows precise modeling, reproducibility, and harmonization of coil-related effects across studies.

| Field | Type | Description |
|---|---:|---|
| `CoilID` | string | Unique identifier for the coil, referenced from `*_nibs.tsv` via `coil_id`. |
| `CoilType` | string | Model/type of the coil (e.g., CB60, Cool-B65). |
| `CoilSerialNumber` | string | Coil serial number. |
| `CoilShape` | string | Geometric shape of the coil windings (e.g., figure-of-eight, circular). |
| `CoilCooling` | string | Cooling method (air, liquid, passive). |
| `CoilDiameter` | object | Coil diameter with units (e.g., `{Value, Units, Description}`). Usually the outer winding diameter. |
| `MagneticFieldPeak` | object | Peak magnetic field at the surface of the coil with units (e.g., `{Value, Units, Description}`). |
| `MagneticFieldPenetrationDepth` | object | Penetration depth at a defined reference level with units (e.g., `{Value, Units, Description}`). |
| `MagneticFieldGradient` | object | Magnetic field gradient with units (e.g., `{Value, Units, Description}`). The definition (spatial vs temporal) SHOULD be specified in `Description`. |


#### `CoilSet` description example

```
"CoilSet": [
  {
    "CoilID": "coil_1",
    "CoilType": "CB60",
    "CoilShape": "figure-of-eight",
    "CoilSerialNumber": "2H54-321",
    "CoilCooling": "air",
    "CoilDiameter": {
      "Value": 75,
      "Units": "mm",
      "Description": "Outer winding diameter"
    },
    "MagneticFieldPeak": {
      "Value": 1.9,
      "Units": "T",
      "Description": "Peak magnetic field at coil surface"
    },
    "MagneticFieldPenetrationDepth": {
      "Value": 18,
      "Units": "mm",
      "Description": "Penetration depth at a defined reference level"
    },
    "MagneticFieldGradient": {
      "Value": 160,
      "Units": "kT/s",
      "Description": "Temporal gradient (dB/dt) measured 20 mm below coil center"
    }
  }
]
```

#### `StimulusSet`

`StimulusSet` defines reusable stimulation configurations referenced from `*_nibs.tsv` via `stim_id`.

It specifies the pulse-count type of a single stimulation instance associated with `stim_id` (e.g., `single`, `paired`, `triple`, `quadruple`, `multi`). 

Each entry describes the stimulation instance in terms of the number of physical pulses it contains and rules for interpreting pulse-specific parameters.

`StimulusSet` does not store trial-specific stimulation values, which remain in `*_nibs.tsv`.

| Field | Type | Description |
|---|---:|---|
| `StimID` | string | Identifier of the stimulation instance or stimulation pattern. Referenced from `*_nibs.tsv` via `stim_id`. Defines how stimulation is delivered, independently of where it is applied. |
| `StimulusType` | string | High-level type describing the number of physical pulses in a single stimulation instance. Allowed values: `single`, `paired`, `triple`, `quadruple`, `multi` (for N>4). |
| `StimulusPulsesNumber` | integer | Number of physical pulses contained in a single stimulation instance defined by `StimID` (e.g., single: 1; paired: 2; triple: 3; quadruple: 4; multi: N). |
| `PulseWaveform` | string | Shape of the stimulation pulse waveform produced by the stimulator (e.g., monophasic, biphasic, custom). Defined per `StimID`. |
| `PulseWidth` | number | (Optional) Duration of a single pulse, measured from pulse onset to pulse offset. Defined per `StimID`. |
| `PulseWidthUnits` | string | Units of `PulseWidth` (e.g., ms, µs). |
| `IntraPulseInterval` | number | (Optional) Within-instance pulse-to-pulse onset spacing (onset-to-onset) for stimulation instances with more than one physical pulse (`StimulusPulsesNumber > 1`). Assumed uniform across consecutive pulses within the instance. |
| `IntraPulseIntervalUnits` | string | Units of `IntraPulseInterval` (e.g., ms, µs). |
| `PulseIntensityScalingType` | string | Defines how pulse-specific intensities are derived from the base intensity specified in `*_nibs.tsv` (e.g., multiplicative, additive). |
| `PulseIntensityScalingVector` | array[number] | Vector of scaling coefficients, ordered by pulse occurrence within the stimulation instance. Length MUST match `StimulusPulsesNumber`. |
| `PulseIntensityScalingReference` | string | Specifies which per-event intensity field in `*_nibs.tsv` is used as the reference for applying `PulseIntensityScalingVector` when pulse-specific intensities differ within an instance. Allowed values: `base`, `threshold`. |
| `PulseIntensityScalingDescription` | string | Free-form description clarifying how scaling is applied and how pulse order is defined for the stimulation instance. |
| `PulseCurrentDirection` | string | Direction of the induced current for the stimulation pulse (e.g., normal, reverse). Interpretation depends on the stimulator/coil and device conventions. Defined per `StimID`. |
| `PulseCurrentDirectionDescription` | string | Free-form description specifying how `PulseCurrentDirection` is defined and interpreted for the given stimulator and coil configuration (e.g., polarity convention, manufacturer definition). |


#### `StimulusSet` description example

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "quadruple",
    "StimulusPulsesNumber": 4,
    "PulseWaveform": "monophasic",
    "PulseWidth": 200,
    "PulseWidthUnits": "µs",
	"IntraPulseInterval": 10,
	"IntraPulseIntervalUnits": "ms",
    "PulseIntensityScalingType": "multiplicative",
    "PulseIntensityScalingVector": [1.0, 1.0, 1.0, 1.1],
    "PulseIntensityScalingReference": "base",
    "PulseIntensityScalingDescription": "Pulse-specific intensities are derived by multiplying the base intensity in *_nibs.tsv by the corresponding scaling coefficient (ordered by pulse occurrence within the instance). Vector length MUST match StimulusPulsesNumber.",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Free-form text description"
  },
  {
    "StimID": "stim_2",
    "StimulusType": "triple",
    "StimulusPulsesNumber": 3,
    "PulseWaveform": "biphasic",
    "PulseWidth": 200,
    "PulseWidthUnits": "µs",
	"IntraPulseInterval": 10,
	"IntraPulseIntervalUnits": "ms",
    "PulseIntensityScalingType": "additive",
    "PulseIntensityScalingVector": [0.0, 0.0, 5.0],
    "PulseIntensityScalingReference": "threshold",
    "PulseIntensityScalingDescription": "Pulse-specific intensities are computed by adding the corresponding offset to the threshold intensity in *_nibs.tsv (ordered by pulse occurrence within the instance). Vector length MUST match StimulusPulsesNumber.",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Free-form text description"
  }
]
```

#### `StimulationSystem`

When the `stimsys-<label>` entity is used in a `*_nibs.*` filename, the corresponding `*_nibs.json` sidecar MUST include `StimulationSystem`.

- **Field name:** `StimulationSystem`
- **Data type:** `string`
- **Requirement level:** REQUIRED if `stimsys-<label>` is present; otherwise OPTIONAL.
- **Definition:** Human-readable description of the stimulation-system class indexed by the `stimsys-<label>` filename entity (e.g., TMS, TES, TUS).
- **Consistency rule:** Within a dataset, the same `stimsys-<label>` MUST map to a consistent `StimulationSystem` description across subjects/sessions.
- **Recommended convention:** `StimulationSystem` SHOULD start with the exact `stimsys` label (filename-friendly), optionally followed by a more descriptive name.

Examples:
- filename entity: `stimsys-tms` → `"StimulationSystem": "tms (Transcranial Magnetic Stimulation)"`
- filename entity: `stimsys-tes` → `"StimulationSystem": "tes (Transcranial Electrical Stimulation)"`

The `*_nibs.json` follows standard BIDS JSON conventions and supports validator compatibility, automated parsing, and provenance tracking across the NIBS datatype.

#### `NavigationSystem`


`NavigationSystem` describes the hardware and software used to guide, track, or control stimulation targeting and coil positioning (e.g., neuronavigation with optical tracking, robotic/cobot positioning, mechanical holders with tracking).

- **Field name:** `NavigationSystem`
- **Data type:** `object`
- **Requirement level:** OPTIONAL (RECOMMENDED when navigation/tracking/robotic positioning is used).

| Field | Type | Description |
|---|---:|---|
| `Navigation` | boolean | Indicates whether a navigation/tracking/positioning system was used during the session. If `true`, the remaining fields SHOULD be provided when known. |
| `NavigationHardwareType` | string | (Optional) Free-form description of the navigation/positioning hardware class (e.g., `optical_tracking`, `robot`, `cobot`, `mechanical_arm`). |
| `NavigationModelName` | string | (Optional) Name/model of the navigation/positioning system (vendor/model or system name). |
| `NavigationSoftwareVersion` | string | (Optional) Version of the navigation/positioning software used (free-form vendor string). |
| `NavigationHardwareSerialNumber` | string | (Optional) Serial number or unique identifier of the navigation/positioning hardware (if available). |
| `NavigationNotes` | string | (Optional) Free-form notes describing relevant setup details (e.g., tracking camera type, robot configuration, calibration procedure). |

Example:

```
"NavigationSystem": {
  "Navigation": true,
  "NavigationHardwareType": "robot",
  "NavigationModelName": "ExampleNav Robot X",
  "NavigationSoftwareVersion": "3.2.1",
  "NavigationHardwareSerialNumber": "RBT-001234",
  "NavigationNotes": "Optical tracking enabled; daily calibration performed before session."
}
```

### 1.3 `*_nibs.tsv` — Stimulation Parameters

* Conceptual definition

Each row in a `*_nibs.tsv` file represents one **logical stimulation event**, defined as one initiated stimulation execution that completes as a whole.

A logical stimulation event corresponds to one delivered execution of a stimulation instance. The stimulation instance structure is defined by the stimulation configuration referenced by `stim_id` (described in `StimulusSet` within `*_nibs.json`). Per-event values (e.g., intensities, timing, or device state) are recorded in the corresponding `*_nibs.tsv` row.

Depending on the paradigm, a stimulation instance may consist of:
- a single delivered pulse,
- a paired- or multi-pulse instance (as defined in `StimulusSet`),
- a device-programmed execution delivering repeated stimulation as a single initiated unit (e.g., a train/burst delivered as one command), when represented as one logical event.

If representing a single logical stimulation event requires more than one stimulation configuration (e.g., changes in `stim_id` within the same initiated execution), it MUST be split across multiple rows (one per configuration segment). Rows belonging to the same logical event MUST share the same `event_id` and MUST be disambiguated using `event_part`.

Logical stimulation events may be delivered:

- manually by the experimenter,

- automatically by the stimulation device,

- or triggered externally (e.g., by experimental software, behavioral tasks, or physiological events).


Repeated deliveries SHOULD be represented by multiple rows when individual events are logged or time-locked. When time-locked annotations are provided in `*_events.tsv`, linkage is performed via `event_id` (not via `stim_id`, `target_id`, or `stim_count`).

This section describes all possible fields that may appear in `*_nibs.tsv` files. Fields are grouped into logical sections based on their functional role and expected variability during an experiment. All fields are optional unless stated otherwise, but some are strongly recommended.

The order and grouping of parameters in `*_nibs.tsv` reflect a hierarchical organization of stimulation metadata, progressing from device and configuration parameters, through event indexing, to spatial targeting and derived measures. This structure supports both manual and automated data acquisition scenarios.


**Stimulator Device & Coil Configuration**

| Field | Type | Description |
|---|---:|---|
| `coil_id` | string | Coil identifier. References `CoilID` entries in `CoilSet` within `*_nibs.json`. |
| `coil_positioning_method` | string | (Optional) Method used to guide coil positioning (free-form). Recommended values include: `manual`, `fixed`, `cobot`, `robot`. |


**Protocol / Event Metadata**

| Field | Type | Description |
|---|---:|---|
| `protocol_name` | string | (Optional) Human-readable protocol label (e.g., SICI, LICI, custom). Intended for readability; MUST NOT be used for machine linkage. |
| `event_id` | string | Identifier of a single logical stimulation event. Used for linkage to time-locked annotations in `*_events.tsv`. MUST be unique within a given `*_nibs.tsv` file. |
| `event_part` | integer | (Optional) Index disambiguating multiple `*_nibs.tsv` rows that belong to the same `event_id` when a single logical event must be split into multiple configuration segments. MUST be present when more than one row shares the same `event_id`. For a given `event_id`, `event_part` MUST be unique. Recommended values are 1..N. |


**Stimulation Configuration Reference**

| Field | Type | Description |
|---|---:|---|
| `stim_id` | string | Identifier of a stimulation configuration/pattern. References `StimID` entries in `StimulusSet` within `*_nibs.json`. |


**Stimulation Timing Parameters** (Nigel suggestion - not finished as of 30/1/02026
| Field | Type | Description |
|---|---:|---|
| `pulse_duration` | number | (Optional) time during which current is passed through the TMS coil (also called `pulse width`). |
| `pulse_count` | number | (Optional) Number of pulses indicated by an event (*I think this definition needs tightening*). |
| `pulse_repetition_interval` | number | (Optional) time from the onset of the first pulse to the onset of the subsequent pulse. This includes pulse duration plus time between pulses. |
| `train_duration` | number | (Optional) Time to complete all pulses in train (including interval following final pulse). |
| `train_count` | number | (Optional) Number of trains indicated by an event. |
| `train_repeition_interval` | number | (Optional) Time from the onset of the first train to the onset of the subsequent train. |
| `repeat_duration` | number | (Optional) Time to complete all trains in repeat (including interval after final train).|
| `repeat_count` | number | (Optional) Number of repeats indicated by an event. |
| `repeat_repeition_interval` | number | (Optional) Time from the onset of the first repeat to the onset of the subsequent repeat. |
| `train_ramp_up` | number | (Optional) Gradual increase of stimulation amplitude applied across successive trains at the beginning of a stimulation block (train-to-train ramping). |
| `train_ramp_up_number` | number | (Optional) Number of initial trains over which the ramp-up is applied. |
| `train_ramp_down` | number | (Optional) Gradual decrease of stimulation amplitude applied across successive trains at the end of a stimulation block (train-to-train ramping). |
| `train_ramp_down_number` | number | (Optional) Number of final trains over which the ramp-down is applied. |
| `stimulation_duration` | number | (Optional) Total wall-clock duration of the stimulation block. |

| Field | Type | Description |
|---|---:|---|
| `inter_trial_interval` | number | (Optional) Time from the onset (start) of one stimulation instance to the onset (start) of the next stimulation instance (start-to-start / onset-to-onset). A stimulation instance corresponds to one logical stimulation event represented by a single row in `*_nibs.tsv` (which may contain a single pulse or a programmed multi-pulse construct). In the special case where each instance contains a single pulse, this corresponds to pulse-to-pulse onset asynchrony. |
| `trial_rate` | number | (Optional) Nominal repetition rate of stimulation instances, defined as the inverse of `inter_trial_interval` when instances are delivered periodically. Expressed in Hz. A stimulation instance corresponds to one row in `*_nibs.tsv`. |
| `burst_stimuli_interval` | number | (Optional) Within-burst onset-to-onset spacing between consecutive stimulation instances within the same burst (start-to-start / onset-to-onset). This parameter describes spacing between repeated stimulation instances using the same stimulation configuration referenced by `stim_id`, regardless of how many pulses each instance contains. |
| `burst_stimuli_number` | number | (Optional) Number of stimulation instances delivered within a single burst. Each instance is delivered using the stimulation configuration referenced by `stim_id`. |
| `burst_stimuli_rate` | number | (Optional) Rate of stimulation instances within a burst, defined as the inverse of `burst_stimuli_interval` when spacing is periodic. Expressed in Hz. If both `burst_stimuli_rate` and `burst_stimuli_interval` are provided, they MUST be mathematically consistent. |
| `train_burst_number` | number | (Optional) Number of bursts delivered within a single stimulation train. |
| `train_burst_rate` | number | (Optional) Burst repetition rate within a stimulation train, defined as the inverse of the onset-to-onset time between consecutive bursts (when periodic). Expressed in Hz. |
| `inter_burst_interval` | number | (Optional) Time from the onset (start) of one burst to the onset (start) of the next burst within the same stimulation train (onset-to-onset). |
| `train_number` | number | (Optional) Total number of trains delivered in the stimulation sequence (count). |
| `inter_train_pulse_interval` | number | (Optional) Time from the onset (start) of the last pulse in one train to the onset (start) of the first pulse in the next train (onset-to-onset across train boundaries). |
| `inter_train_interval_delay` | number | (Optional) Per-train additive offset applied to the nominal `inter_train_pulse_interval`, allowing non-uniform onset-to-onset timing across train boundaries. The effective interval is computed as: `effective interval = inter_train_pulse_interval + inter_train_interval_delay`. |
| `train_ramp_up` | number | (Optional) Gradual increase of stimulation amplitude applied across successive trains at the beginning of a stimulation block (train-to-train ramping). |
| `train_ramp_up_number` | number | (Optional) Number of initial trains over which the ramp-up is applied. |
| `train_ramp_down` | number | (Optional) Gradual decrease of stimulation amplitude applied across successive trains at the end of a stimulation block (train-to-train ramping). |
| `train_ramp_down_number` | number | (Optional) Number of final trains over which the ramp-down is applied. |
| `stimulation_duration` | number | (Optional) Total wall-clock duration of the stimulation block. |
   

**Spatial & Targeting Information**

| Field | Type | Description |
|---|---:|---|
| `target_id` | string | Identifier of a spatial stimulation target (stimulation-level target identifier). Links `*_nibs.tsv` to spatial target definitions in `*_markers.tsv`. |
| `target_name` | string | (Optional) Human-readable name of the cortical target, anatomical label, or stimulation site. |


**Amplitude & Thresholds**

| Field | Type | Description |
|---|---:|---|
| `base_pulse_intensity` | number | Base stimulation intensity expressed in device output units for the session (typically %MSO for TMS). For multi-pulse stimulation instances, pulse-specific intensities MAY be derived from this value as defined by `stim_id` in `StimulusSet`. |
| `threshold_pulse_intensity` | number | Stimulation intensity expressed relative to the threshold defined by `threshold_type`, typically as a percentage of the threshold value (e.g., 110 meaning 110% of threshold). |
| `threshold_type` | string | Type of threshold used as a reference for dosing/normalization (e.g., resting motor threshold, active motor threshold, phosphene threshold, inhibition threshold, pain/discomfort threshold, custom). This field defines what physiological or perceptual endpoint the threshold refers to. |
| `threshold_reference_intensity` | number | Device output value corresponding to the threshold defined by `threshold_type` for the given session/system (typically %MSO for TMS). This value provides the absolute reference used for dosing/normalization. If a different unit is used, it MUST be documented in dataset-level metadata. |
| `threshold_criterion` | string | Criterion used to define the threshold endpoint (e.g., “1 mV MEP”, “0.2 mV MEP”, “visible twitch”, “perceptible phosphene”, “50% inhibition”, custom). |
| `threshold_algorithm` | string | Algorithm/procedure used to estimate the threshold (e.g., “5/10”, “10/20”, “PEST”, staircase, adaptive method, custom). |
| `threshold_measurement_method` | string | Measurement modality/method used to assess the response underlying the threshold (e.g., EMG-based MEP, visible twitch observation, participant report, behavioral endpoint, custom). |

* Rule for `threshold_pulse_intensity`:

1. If `PulseIntensityScalingVector` is present in `StimulusSet` and `PulseIntensityScalingReference = threshold`, then `threshold_pulse_intensity` SHOULD be omitted, since pulse-specific threshold-relative intensities are fully determined by `threshold_reference_intensity` and the scaling vector.
2. If `PulseIntensityScalingVector` is not present, `threshold_pulse_intensity` MAY be used to encode a single intensity value relative to the chosen threshold.

* Notes

1. When threshold-based dosing is used, `threshold_pulse_intensity` specifies the stimulation intensity relative to the threshold defined by `threshold_type`, while `threshold_reference_intensity` provides the corresponding device output value for that threshold.
2. If both `threshold_pulse_intensity` and `base_pulse_intensity` are provided, they MUST be numerically consistent with `threshold_reference_intensity` (i.e., `base_pulse_intensity ≈ threshold_reference_intensity * threshold_pulse_intensity / 100`, within measurement/rounding precision).

	
**Derived / Device-Generated Parameters**

| Field | Type | Description |
|---|---:|---|
| `stim_count` | integer | (Optional) Counter indicating the number of times a stimulation instance with the same `stim_id` has been delivered to the same `target_id` within the current file/session. Intended for counting deliveries to a target; MUST NOT be used for synchronization across modalities. Values typically start at 1 and increment monotonically for successive deliveries of the same (`stim_id`, `target_id`) combination. |
| `stim_validation` | string | (Optional) Free-form indication of whether stimulation delivery/positioning was verified or observed (e.g., `verified`, `observed`, `not_verified`, `unknown`). |
| `current_gradient` | number | (Optional) Device-reported measured gradient of coil current (units device-dependent). |
| `electric_field_target` | number | (Optional) Estimated or measured electric field at the stimulation target (units and model/device-dependent). |
| `electric_field_max` | number | (Optional) Peak electric field value (units and model/device-dependent). |
| `motor_response` | number | (Optional) Aggregate motor response metric reported by the stimulation system or experimenter and used during stimulation setup/calibration (e.g., threshold determination). This is a procedure-level summary value (e.g., amplitude/magnitude) and does not represent the full EMG waveform. Units and computation method are device- or protocol-dependent and may be proprietary. |
| `latency` | number | (Optional) Device- or procedure-reported delay between stimulus delivery and the detected motor response, as used during the experiment (e.g., for threshold estimation). This is a summary timing value and does not imply a standardized onset detection method. |
| `response_channel_name` | string | (Optional) Name/label of the recorded channel used to derive the response metric (e.g., EMG channel name). |
| `response_channel_type` | string | (Optional) Type of channel (e.g., `emg`, `eeg`, `meg`, `other`). |
| `response_channel_description` | string | (Optional) Free-form description of the response channel and how it was used. |
| `response_channel_reference` | string | (Optional) Reference channel name/label if applicable. |
| `response_channel_status` | string | (Optional) Free-form indication of data/measurement quality observed on the response channel. |
| `response_channel_status_description` | string | (Optional) Free-form description of noise/artifact affecting data quality on the response channel. |
| `subject_feedback` | string | (Optional) Participant-reported perception, discomfort, or other feedback related to stimulation. |
| `intended_for` | string | (Optional) BIDS-style reference/URI to a recorded data file associated with the response/measurement (example: `bids::sub-01/ses-01/eeg/sub-01_ses-01_task-..._eeg.eeg`). |
| `timestamp` | string | (Optional) Timestamp in ISO 8601 format. |

* Motor response–related parameters in the NIBS-BIDS specification are intended to store procedure-level or device-reported summary values used during stimulation setup (e.g., motor threshold determination).
* They are not intended to replace or describe EMG recordings or waveform-level analyses, which should be represented using dedicated EMG data types and extensions when available.


### 1.4 `*_nibs.json` & `*_nibs.tsv` hierarchy logic

Legend:

- `stim_id` → references a `StimulusSet` entry in `*_nibs.json` (`StimID`)
- row → one row in `*_nibs.tsv` (a stimulation record)
- logical event → one initiated stimulation execution that completes as a whole, indexed by `event_id`
- segment → a configuration segment within a logical event, indexed by `event_part` (only when a logical event must be split across multiple rows)

Hierarchy (structure + repetition):

**Stimulation instance structure (defined in `*_nibs.json`)**

`StimulusSet` (in `*_nibs.json`)
- `StimID = "stim_A"` defines the internal structure of a stimulation instance:
  - number of physical pulses in the instance: `StimulusPulsesNumber = N`
  - within-instance pulse spacing (uniform, if `N > 1`): `IntraPulseInterval` (+ `IntraPulseIntervalUnits`)
  - pulse properties: `PulseWaveform`, `PulseWidth`, `PulseCurrentDirection`
  - pulse-intensity rules (optional): `PulseIntensityScalingType`, `PulseIntensityScalingVector`, `PulseIntensityScalingReference`

**Within a logical stimulation event (recorded in `*_nibs.tsv`)**

- A logical stimulation event is identified by `event_id`.
- In the common case, one logical event is represented by a single `*_nibs.tsv` row:
  - the row references the stimulation-instance structure via `stim_id`
  - the row contains per-event parameters (e.g., intensities, targeting linkage, device/procedure metadata)

- If a single logical event requires more than one stimulation configuration (e.g., changes in `stim_id` within the same initiated execution), it MUST be split across multiple rows:
  - all rows share the same `event_id`
  - each row is disambiguated by `event_part = 1..N` (one configuration segment per row)

- Paradigm-level repetition described as a single initiated execution (e.g., burst/train delivered as one command) MAY be represented as one logical event. In such cases, repetition timing is described parametrically in `*_nibs.tsv` using the applicable timing fields (e.g., `burst_stimuli_number`, `burst_stimuli_interval`, `train_burst_number`, `inter_burst_interval`, etc.).

**Between stimulation events (across rows)**

- `inter_trial_interval` (and, when applicable, `trial_rate`) describes onset-to-onset spacing between consecutive logical stimulation events (row-to-row), when applicable.
- When time-locked onsets are provided, they SHOULD be recorded in `*_events.tsv` and linked via `event_id`.




## Appendix A: Examples of “protocol recipes”:

### Example 1 — Single-pulse TMS (manual or externally triggered)

* Conceptual meaning

A stimulation instance corresponds to the delivery of one single TMS pulse.  
Each delivered pulse is treated as an independent stimulation instance and is represented by one row in `*_nibs.tsv`.

Stimulus definition (`*_nibs.json` → `StimulusSet`)  
This example defines a single-pulse stimulation instance.

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "single",
    "StimulusPulsesNumber": 1,
    "PulseWaveform": "monophasic",
    "PulseWidth": 0.2,
    "PulseWidthUnits": "ms",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Defined according to manufacturer-specific coil orientation convention"
  }
]
```

* Interpretation

	- StimID defines the stimulation-instance structure referenced by stim_id.

	- The instance contains exactly one physical pulse (StimulusPulsesNumber = 1).

	- Pulse-level properties are fixed for this configuration and therefore belong in *_nibs.json.

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered single pulse.

```
event_id  stim_id  target_id  stim_count  base_pulse_intensity  threshold_type    threshold_reference_intensity  threshold_pulse_intensity  inter_trial_interval
event_1   stim_1   target_1   1           55                    resting_motor     50                             110                        5
event_2   stim_1   target_1   2           55                    resting_motor     50                             110                        5
event_3   stim_1   target_1   3           55                    resting_motor     50                             110                        5
```

* Timing note

	- If pulses are manually triggered or irregular, onsets SHOULD be recorded in *_events.tsv (linked via event_id), and inter_trial_interval MAY be omitted.

	- If pulses are delivered periodically and per-event time-locking is not required, inter_trial_interval or trial_rate MAY be used.

### Example 2 — Paired-pulse TMS (e.g., SICI / ICF)

* Conceptual meaning

A stimulation instance corresponds to the delivery of one paired-pulse stimulation instance, consisting of two pulses delivered with a fixed onset-to-onset interval.  
Each paired-pulse delivery is treated as one stimulation instance and represented by one row in `*_nibs.tsv`.

* Stimulus definition (`*_nibs.json` → `StimulusSet`)

This example defines a paired-pulse stimulation instance.

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "paired",
    "StimulusPulsesNumber": 2,
    "IntraPulseInterval": 0.003,
    "IntraPulseIntervalUnits": "s",
    "PulseWaveform": "biphasic",
    "PulseWidth": 0.2,
    "PulseWidthUnits": "ms",
    "PulseIntensityScalingType": "multiplicative",
    "PulseIntensityScalingVector": [0.8, 1.1],
    "PulseIntensityScalingReference": "threshold",
    "PulseIntensityScalingDescription": "Conditioning pulse at 80% of threshold, test pulse at 110% of threshold",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Defined according to manufacturer-specific coil orientation convention"
  }
]
```

* Interpretation

	- StimID = stim_1 defines the stimulation-instance structure referenced by stim_id.

	- The instance contains two physical pulses (StimulusPulsesNumber = 2).

	- The within-instance pulse spacing is defined by IntraPulseInterval in StimulusSet.

	- Pulse-level properties (waveform, width, direction) are fixed for this configuration and belong in *_nibs.json.

	- Pulse-specific intensity rules are defined in StimulusSet via the scaling fields.

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered paired-pulse stimulation instance.

```
event_id  stim_id  target_id  stim_count  threshold_type    threshold_reference_intensity  inter_trial_interval
event_1   stim_1   target_1   1           resting_motor     55                             6
event_2   stim_1   target_1   2           resting_motor     55                             6
event_3   stim_1   target_1   3           resting_motor     55                             6
```

* Timing note

- The paired-pulse structure is fully defined by::

	- StimulusPulsesNumber = 2 (JSON)
	- IntraPulseInterval (JSON)

If paired-pulse instances are delivered irregularly or task-triggered, onsets SHOULD be recorded in *_events.tsv (linked via event_id).

### Example 3 — Burst-based stimulation (e.g., TBS-like constructs)

* Conceptual meaning

A stimulation instance corresponds to the delivery of a burst/train-based construct executed as a single initiated unit (one logical stimulation event).  
A train is composed of repeated bursts, and each burst contains repeated stimulation instances defined by the configuration referenced by `stim_id`.  
A delivered burst/train-based construct can be represented by one row in `*_nibs.tsv` (with its internal repetition described parametrically).

* Stimulus definition (`*_nibs.json` → `StimulusSet`)

This example defines a single-pulse stimulation instance, which is repeated within bursts and trains.

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "single",
    "StimulusPulsesNumber": 1,
    "PulseWaveform": "biphasic",
    "PulseWidth": 0.2,
    "PulseWidthUnits": "ms"
  }
]
```

* Interpretation

	- `StimID defines the stimulation-instance structure referenced by stim_id in *_nibs.tsv.

	- The burst structure is defined parametrically by:

		- burst_stimuli_number

		- burst_stimuli_interval or burst_stimuli_rate

	- The train structure (burst repetition) is defined parametrically by:

		- train_burst_number

		- inter_burst_interval or train_burst_rate

	- If trains are repeated as a higher-level pattern, repetition MAY be encoded by:

		- train_number

		- inter_train_pulse_interval

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered burst/train-based stimulation event described parametrically.

```
event_id  stim_id  target_id  stim_count  base_pulse_intensity  threshold_type    threshold_reference_intensity  threshold_pulse_intensity  burst_stimuli_number  burst_stimuli_interval  train_burst_number  inter_burst_interval
event_1   stim_1   target_1   1           55                   	resting_motor     50                             110                        3                     0.02                    200                 0.2
```

* Timing note

- If bursts/trains are delivered irregularly or externally triggered, onsets SHOULD be recorded in *_events.tsv (linked via event_id).
- If the construct is executed as programmed and periodic, the burst/train parameters above are sufficient to reconstruct the intended temporal pattern.
