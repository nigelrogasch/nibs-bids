# NIBS-BIDS proposal v.6.2 (Scalable Structure for Non-Invasive Brain Stimulation)

### This document presents a concise overview of our proposed scalable structure for organizing **non-invasive brain stimulation (NIBS)** data in BIDS. 

### It is designed to precede and accompany real-life examples and comparative demonstrations.


## NIBS as a Dedicated `datatype`

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


### Core NIBS files

The following files are used to organize stimulation-related data:

- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.tsv`
- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.json`

  * Contains event-level stimulation records (what was executed), including per-event timing/intensity fields and links to reusable definitions in *_nibs.json and spatial definitions in *_markers.tsv..

- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.tsv` 
- `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.json` 

  * May contain either 3D coordinates and/or standardized location labels (e.g., 10–20) depending on available targeting information.	
  
- `sub-<label>_task-<label>[_stimsys-<label>]_coordsystem.json` 

  * Describes the coordinate system used in the stimulation session.

  
### Supported Stimulation Systems

The structure supports multiple types of NIBS techniques:

  * Transcranial Magnetic Stimulation (**TMS**)
  
  * Transcranial Electrical Stimulation (**TES**, e.g., tDCS, tACS)
  
  * Transcranial Ultrasound Stimulation (**TUS**)
   
   
### Modality-Specific Suffix via `stimsys`

* To distinguish between different stimulation systems, we introduce the suffix `stimsys` (kind of analogous to `tracksys` in the `/motion` datatype).
* The `stimsys` suffix should take values like `tms`, `tes`, `tus`.

The `stimsys-<label>` entity should be used as a key-value pair to label `*_nibs.tsv` and `*_nibs.json` files. 

It also should be used to label `*_markers.tsv`; `*_markers.json` or `*_coordsystem.json` files when they belong to a specific stimulation system.

If `stimsys-<label>` is present in the filename, the sidecar MUST include `StimulationSystem`, and it SHOULD be consistent with the label.


### Internal NIBS File Linking

The NIBS specification uses internal identifiers to link event-level stimulation records stored in `*_nibs.tsv` with reusable device and stimulus definitions stored in `*_nibs.json`, and with spatial definitions stored in `*_markers.tsv` (with accompanying JSON sidecars where applicable).

These identifiers enable compact representation of stimulation events while avoiding repetition of device and stimulus configuration parameters.


#### Device identifiers

Device identifiers reference physical stimulation hardware used during the experiment.
They link rows in `*_nibs.tsv` to device definitions stored in `*_nibs.json`.

This separation allows hardware properties (e.g., coil geometry, electrode/contact hardware, or ultrasound transducer characteristics) to be defined once and reused across multiple stimulation events.

Device identifiers describe **physical devices**, not stimulation parameters.
Changes in stimulation protocol (e.g., pulse timing or intensity) do not require a new device identifier unless the physical hardware itself changes.

| Field | Description |
|------|-------------|
| `coil_id` | References an entry in `CoilSet` defined in `*_nibs.json`. Used for TMS stimulation devices. |
| `electrode_id` | References an entry in `ElectrodeSet` defined in `*_nibs.json`. Used for TES electrode/contact hardware definitions (includes `ElectrodeRole`). |
| `transducer_id` | References an entry in `TransducerSet` defined in `*_nibs.json`. Used for TUS stimulation devices. |


#### Stimulus configuration identifiers

Stimulus configuration identifiers reference reusable stimulation protocol definitions stored in the `StimulusSet` section of `*_nibs.json`.

A stimulus configuration represents a predefined set of stimulation parameters (e.g., waveform shape, pulse timing structure, or modulation pattern) that are intended to be reused across multiple events” / “typically invariant across multiple stimulation events.

This mechanism allows complex stimulation protocols to be defined once and referenced by multiple rows in `*_nibs.tsv`, avoiding repetition of protocol parameters and improving dataset readability.

Event-specific parameters such as timing, target location, and intensity adjustments remain stored in `*_nibs.tsv`.

| Field | Description |
|------|-------------|
| `stim_id` | References an entry in `StimulusSet` defined in `*_nibs.json`. The stimulus definition contains parameters intended to be reused across multiple stimulation events. Event-specific timing and intensity parameters are stored in `*_nibs.tsv`. |


#### Target identifiers

Target identifiers define spatial locations associated with stimulation events. 
They link stimulation events recorded in `*_nibs.tsv` to spatial definitions (coordinates and/or standardized location labels) stored in `*_markers.tsv`.

Peripheral nerve stimulation (PNS) is not treated as a separate modality in this specification. 
Instead, stimulation of peripheral nerves is represented using the same stimulation modalities (TMS, TES, or TUS) depending on the physical stimulation technology used. 
In such cases, the stimulated nerve can be described using `target_label`, `target_description`, and coordinates defined in `*_markers.tsv`.

| Field | Description |
|------|-------------|
| `target_id` | References one row in `*_markers.tsv` describing stimulation site coordinates. |
| `target_group` | (Optional) Group identifier used to logically group multiple `target_id` rows that belong to the same higher-level construct (e.g., a TES montage, an HD set, a multi-coil setup, a multi-focus set). This field is for convenience and organization only and MUST NOT be used for synchronization across modalities. |

#### Linking keys

The NIBS specification uses a set of internal identifiers to link information between tabular files (`*_nibs.tsv`, `*_markers.tsv`, `*_events.tsv`) and structured metadata objects defined in accompanying JSON files (e.g., `*_nibs.json`, `*_markers.json`, `*_events.json`).

These identifiers ensure that device definitions, stimulus configurations, and spatial targets can be reused across multiple stimulation events without repeating metadata.

##### `coil_id` → `CoilID` (`CoilSet` in `*_nibs.json`)

- `coil_id` in `*_nibs.tsv` MUST reference a `CoilID` defined in the `CoilSet` section of `*_nibs.json`.
- `CoilID` values MUST be unique within a given `*_nibs.json`.
- The same `coil_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same coil definition applies.

##### `electrode_id` → `ElectrodeID` (`ElectrodeSet` in `*_nibs.json`)

- `electrode_id` in `*_nibs.tsv` MUST reference an `ElectrodeID` defined in the `ElectrodeSet` section of `*_nibs.json`.
- `ElectrodeID` values MUST be unique within a given `*_nibs.json`.
- The same `electrode_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same electrode/contact hardware definition applies.

##### `transducer_id` → `TransducerID` (`TransducerSet` in `*_nibs.json`)

- `transducer_id` in `*_nibs.tsv` MUST reference a `TransducerID` defined in the `TransducerSet` section of `*_nibs.json`.
- `TransducerID` values MUST be unique within a given `*_nibs.json`.
- The same `transducer_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same transducer definition applies.

##### `stim_id` → `StimID` (`StimulusSet` in `*_nibs.json`)

- `stim_id` in `*_nibs.tsv` MUST reference a `StimID` defined in the `StimulusSet` section of `*_nibs.json`.
- `StimID` values MUST be unique within a given `*_nibs.json`.
- The same `stim_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same stimulation template applies.

##### `target_id` → spatial targets (`*_markers.tsv`)

- `target_id` in `*_nibs.tsv` MUST reference a `target_id` value defined in `*_markers.tsv`.
- `target_id` values MUST be unique within a given `*_markers.tsv` (one row per `target_id`).

##### `target_group` (organizational grouping in `*_markers.tsv`)

- `target_group` MAY be used in `*_markers.tsv` to logically group multiple `target_id` entries (e.g., montage membership).
- `target_group` MUST NOT be used for linkage from `*_nibs.tsv` and MUST NOT be used for synchronization across modalities.

##### `event_id` → experimental timeline (`*_events.tsv`)

- `event_id` in `*_nibs.tsv` MUST reference an event in `*_events.tsv` when time-locking/synchronization is required.
- Multiple rows in `*_nibs.tsv` MAY share the same `event_id` when a single logical event requires multiple rows (e.g., multi-contact TES or segmented configurations).

##### `event_part` → row/segment index within `event_id` (`*_nibs.tsv`)

- `event_part` is OPTIONAL when `event_id` occurs once in `*_nibs.tsv`.
- When multiple rows share the same `event_id`, `event_part` SHOULD be present.
- Within the same `event_id`, `event_part` MUST be unique and values SHOULD start at 1 and increment monotonically (1..N).

#### Grouped (multi-point) target constructs in `*_markers.tsv`

In some experiments, stimulation involves multiple spatial points that are conceptually related (e.g., multi-contact TES montages, multi-coil TMS setups, or phased-array TUS protocols with multiple focus locations).

In this specification, `*_markers.tsv` represents **one spatial point/contact per row**. Multi-point constructs are therefore represented as **multiple rows**, each with its own unique `target_id`. These `target_id` values are referenced from `*_nibs.tsv` to indicate which points/contacts were involved in a given stimulation event.

`target_group` MAY be used as an optional organizational label to group related `target_id` entries (e.g., montage membership). `target_group` MUST NOT be used for linkage or synchronization; linkage from `*_nibs.tsv` is always performed via `target_id`.

| Field | Description |
|------|-------------|
| `target_id` | Identifier of a single row (a single point/contact) in `*_markers.tsv`, referenced from `*_nibs.tsv`. `target_id` values MUST be unique within a given `*_markers.tsv`. |
| `target_group` | (Optional) Group identifier used to logically group multiple `target_id` rows that belong to the same higher-level construct (e.g., a TES montage, an HD set, a multi-coil setup, a multi-focus set). This field is for convenience and organization only and MUST NOT be used for synchronization across modalities. |

This mechanism enables representation of:

- TES montages involving multiple electrode contacts (each contact has its own `target_id`)
- TMS stimulation involving multiple coils (each coil placement/point has its own `target_id`)
- TUS protocols involving multiple focus points (each focus location has its own `target_id`)

When sequential stimulation across multiple points is used (e.g., phased-array TUS beam steering), the order of stimulation across points SHOULD be encoded at the event/stimulus level.

### Synchronizing NIBS Data Across Modalities (`*_events.tsv`)

In multimodal experiments (e.g., NIBS combined with EEG, MEG, fMRI, or behavioral recordings), stimulation events are synchronized with other data streams using the corresponding BIDS `*_events.tsv` file.

The `*_events.tsv` file represents the primary timeline of experimental events, including stimulus presentations, behavioral responses, and stimulation triggers.

NIBS-specific stimulation parameters are stored in `*_nibs.tsv`.
Synchronization between these files is achieved through the `event_id` field.

| Field | Description |
|------|-------------|
| `event_id` | Identifier linking rows in `*_nibs.tsv` to a corresponding event in `*_events.tsv`. |

Each logical stimulation event in `*_nibs.tsv` is referenced by `event_id` in `*_events.tsv`.

In some cases, a single experimental event may involve multiple stimulation records (e.g., TES with multiple contacts/channels, or segmented configurations).
In such cases, multiple rows in `*_nibs.tsv` MAY share the same `event_id` and SHOULD be indexed using `event_part`.

The `stimulus_count` field in `*_nibs.tsv` is intended only for counting repeated stimulation deliveries to the same target and MUST NOT be used for synchronization between modalities.


### File-linking overview

The NIBS data structure links stimulation events, device definitions, stimulus configurations, and spatial targets across several files.

The central table `*_nibs.tsv` contains event-level stimulation records.
Identifiers in this table reference reusable definitions stored in `*_nibs.json` and spatial target definitions stored in `*_markers.tsv`.

Synchronization with other modalities is performed through `event_id`, which links entries in `*_nibs.tsv` to `*_events.tsv`.
When a single logical event requires multiple `*_nibs.tsv` rows, those rows SHOULD share the same `event_id` and be indexed using `event_part`.


```
									┌───────────────────────────────┐
									│        *_nibs.json 		    │
									│	- - - - - - - - - - - -     │
									│		(device layer)		    │
									│		 CoilSet: CoilID 	    │
									│	ElectrodeSet: ElectrodeID   │
									│   TransducerSet: TransducerID │
									│   - - - - - - - - - - - -     │
									│		(stimulus layer)        │
									│  	   StimulusSet: StimID      │
									└─────────────┬─────────────────┘
												  │
										coil_id → CoilID
										electrode_id → ElectrodeID
										transducer_id → TransducerID
										stim_id → StimID
												  │
					┌─────────────────────────────▼───────────────────────────────────────┐
					│                           *_nibs.tsv                                │
					│  Required:  event_id                                                │
					│  Optional:  event_part (indexes multi-row events)                   │
					│  Links:     coil_id\electrode_id\transducer_id, stim_id, target_id  │
					│  Count:     stimulus_count (NOT for synchronization)                │
					└─────────────┬───────────────────────────────┬───────────────────────┘
								  │                               │
							   target_id                        event_id
								  │                               │
								  ▼                               ▼
					┌──────────────────────────┐        ┌────────────────────────┐
					│       *_markers.tsv      │        │       *_events.tsv     │
					│         target_id        │        │  onset/duration/...    │
					│   target_id MUST be      │        │  (primary timeline)    │
					│   unique (one row per    │        │  event_id used for     │
					│   point/contact)         │        │  cross-modality sync   │
					│   (optional: target_group│        └────────────────────────┘
					│    for organization)     │
					└─────────────┬────────────┘
								  │
								  ▼
					┌──────────────────────────┐
					│    *_coordsystem.json    │
					│ (coordinate context for  │
					│  markers/targets)        │
					└──────────────────────────┘
```

Read it like this:

- `*_nibs.tsv` describes what was executed (logical stimulation events), and links to configuration (`*_nibs.json`) and space (`*_markers.tsv`).
  If one logical event requires multiple rows, those rows share `event_id` and are indexed by `event_part`.

- `*_events.tsv` describes when it happened (time-locking) via `event_id`.

- `*_markers.tsv` + `*_coordsystem.json` describe where it happened.
  Multi-point constructs (e.g., montages) are represented by multiple `target_id` entries (optionally grouped using `target_group`).


## Detailed overview of data structure

### `*_coordsystem.json` — Coordinate Metadata

A _coordsystem.json file is used to specify the fiducials, the location of anatomical landmarks, and the coordinate system and units in which the position of landmarks or TMS stimulation targets is expressed. 
Anatomical landmarks are locations on a research subject such as the nasion (for a detailed definition see the coordinate system appendix).
The _coordsystem.json file is REQUIRED for navigated TMS, TES, TUS stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the TMS, TES, TUS data.

| Field | Type | Description |
|---|---|---|
| `IntendedFor`                                   | string  | Path to the anatomical file this coordinate system refers to. BIDS-style path. (example: `bids::sub-01/ses-01/anat/sub-01_T1w.nii.gz`)        |                                                                                                                                  			
| `NIBSCoordinateSystem`						  | string  | Name of the coordinate system used to define the spatial location of stimulation targets. Common values for TUS include: IndividualMRI, MNI152NLin2009cAsym, or CapTrak.		|																												
| `NIBSCoordinateUnits`							  | string  | Units used to express spatial coordinates in *_markers.tsv. Typically mm (millimeters) for MRI-based spaces.																|																												
| `NIBSCoordinateSystemDescription`				  | string  | Free-text description providing details on how the coordinate system was defined. This may include registration methods (e.g., neuronavigation, manual annotation), whether coordinates represent the ultrasound focus or entry point, and how the space aligns with anatomical references.|
| `FiducialsDescription`							| string  | Free-form text description of how the fiducials such as vitamin-E capsules were placed relative to anatomical landmarks, and how the position of the fiducials were measured (for example, "both with Polhemus and with T1w MRI").|
| `FiducialsCoordinates`							| object  | Key-value pairs of the labels and 3-D digitized position of anatomical landmarks, interpreted following the "FiducialsCoordinateSystem" (for example, {"NAS": [12.7,21.3,13.9], "LPA": [5.2,11.3,9.6], "RPA": [20.2,11.3,9.1]}). Each array MUST contain three numeric values corresponding to x, y, and z axis of the coordinate system in that exact order.|
| `FiducialsCoordinateSystem`						| string  | Defines the coordinate system for the fiducials. Preferably the same as the "NIBSCoordinateSystem". |
| `FiducialsCoordinateUnits`						| string  |	Units in which the coordinates that are listed in the field "FiducialsCoordinateSystem" are represented. Must be one of: "m", "mm", "cm", "n/a".	|	
| `FiducialsCoordinateSystemDescription`			| string  |	Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail.	|
| `AnatomicalLandmarkCoordinates`                 | object  | Key-value pairs of the labels and 3-D digitized locations of anatomical landmarks, interpreted following the `AnatomicalLandmarkCoordinateSystem`. Each array MUST contain three numeric values corresponding to x, y, and z axis of the coordinate system in that exact order.	|		
| `AnatomicalLandmarkCoordinateSystem`            | string  | Defines the coordinate system for the anatomical landmarks. See the Coordinate Systems Appendix for a list of restricted keywords for coordinate systems. If "Other", provide definition of the coordinate system in `AnatomicalLandmarkCoordinateSystemDescription`.   |        	
| `AnatomicalLandmarkCoordinateUnits`             | string  | Units of the coordinates of Anatomical Landmark Coordinate System. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.           |                                                                                                                                                   	
| `AnatomicalLandmarkCoordinateSystemDescription` | string  | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail.  |                                                                                                                        		
| `AnatomicalLandmarkCoordinatesDescription`      | string  | `[x, y, z]` coordinates of anatomical landmarks. NAS — nasion, LPA — left preauricular point, RPA — right preauricular point            |                                                                                                                                        				
| `HeadMeasurements`							  | object  | Object containing one or more head measurement vectors relevant for 10–20–based navigation. Each value MUST be a numeric array.|
| `HeadMeasurementsUnits`						  | string  | Units used for all values stored in HeadMeasurements (e.g., "mm").|
| `HeadMeasurementsDescription`					  | string  | Free-form description of how HeadMeasurements were obtained (e.g., tape/geodesic along scalp vs. Euclidean), including any conventions (landmark definitions, repetitions, averaging).|
| `DigitizedHeadPoints`                           | string  | Relative path to the file containing the locations of digitized head points collected during the session. (for example, `"sub-01_headshape.pos"`)          |                                                                                                                     	
| `DigitizedHeadPointsNumber`                     | integer | Number of digitized head points during co-registration.      |                                                                                                                                                                                                                 		
| `DigitizedHeadPointsDescription`                | string  | Free-form description of digitized points.                  |                                                                                                                                                                                                                    			
| `DigitizedHeadPointsUnits`                      | string  | Unit type. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.      |                                                                                                                                                                                                                		
| `AnatomicalLandmarkRmsDeviation`                | object  | `{"RMS":[],"NAS":[],"LPA":[],"RPA":[]}` — deviation values per landmark  |                                                                                                                                                                                                       		
| `AnatomicalLandmarkRmsDeviationUnits`           | string  | Unit of RMS deviation values.                                          |                                                                                                                                                                                                     			
| `AnatomicalLandmarkRmsDeviationDescription`     | string  | Description of how RMS deviation is calculated and for which markers.  |                                                                                                                                                                                                       		


### TUS-specific transducer coordinate metadata fields (*_coordsystem.json)

These optional fields are recommended for transcranial ultrasound stimulation (TUS) datasets when the spatial position and/or orientation of the ultrasound transducer is known or fixed (e.g., in neuronavigated or modeled setups). 
They complement the standard NIBSCoordinateSystem fields, which typically describe the focus location.
Optional QC metric (in mm) representing the root-mean-square deviation of the ultrasound transducer's actual position and/or orientation from its intended location.
This may be computed from optical tracking, neuronavigation logs, or mechanical fixation assessment.


| Field | Type | Description |
|---|---|---|
| `TransducerCoordinateUnits`					| string  | Units of measurement for transducer coordinates (typically mm).|
| `TransducerCoordinateSystemDescription`		| string  | Textual description of how the transducer coordinate system was defined and aligned with anatomy.|
| `TransducerCoordinates`						| object  | Dictionary with spatial coordinates (e.g., X, Y, Z ) and optionally 4×4 affine transformation matrix for transducer orientation.|
| `TransducerCoordinatesDescription`			| string  | Free-text explanation of what the coordinates represent (e.g., transducer center, entry point, beam axis, etc.).|
| `TransducerRmsDeviation`						| string  | Root-mean-square deviation (in millimeters) of the ultrasound transducer’s actual position and/or orientation from the planned or intended placement, typically computed across time or repeated trials.|
| `TransducerRmsDeviationUnits`   				| string  | Units used to express the RMS deviation value. Must be consistent with the spatial coordinate system units (e.g., "mm").|
| `TransducerRmsDeviationDescription`			| string  | Free-text description of how the deviation was calculated, including what was measured (e.g., position, angle), over what time frame, and using which method (e.g., optical tracking, neuronavigation, manual estimate).|

*These fields enable reproducible modeling, visualization, and interpretation of TUS targeting and acoustic beam propagation when precise transducer positioning is known.

### (Optional) Headshape Files (*_headshape.<extension>)


3D digitized head points  that describe the head shape and/or EEG electrode locations can be digitized and stored in separate files. 
These files are typically used to improve the accuracy of co-registration between the stimulation target, anatomical data, etc. 

** Template:**

```
sub-<label>/
└── [ses-<label>/]
    └── nibs/
        └── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>]_acq-HEAD_headshape.pos 

```
These files supplement the DigitizedHeadPoints, DigitizedHeadPointsUnits, and DigitizedHeadPointsDescription fields in the corresponding _coordsystem.json file. 
Their inclusion is especially useful when sharing datasets intended for advanced spatial analysis or electric field modeling.


### (Optional) Landmark photos (*_photo.<extension>)

Photos of the anatomical landmarks and/or fiducials.

** Template:**

```
sub-<label>/
└── [ses-<label>/]
    └── nibs/
        ├── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>]_photo.jpg
		├──	sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>]_photo.png
		└──	sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>]_photo.tif

```

Photos of the anatomical landmarks and/or fiducials are OPTIONAL. Please note that the photos may need to be cropped or blurred to conceal identifying features prior to sharing, depending on the terms of the consent given by the participant.

The acq-<label> entity can be used to indicate acquisition of different photos of the same face or body part.

## Detailed overview of data structure

### non-invasive-brain-stimulation-v6.2.md
