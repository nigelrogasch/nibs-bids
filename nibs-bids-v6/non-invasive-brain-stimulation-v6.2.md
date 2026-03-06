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

The NIBS specification uses a set of internal identifiers to link information between the tabular files (`*_nibs.tsv`, `*_markers.tsv`, `*_events.tsv`) and structured metadata objects defined in sidecar JSON files.

These identifiers ensure that device definitions, stimulus configurations, and spatial targets can be reused across multiple stimulation events without repeating metadata.

##### `coil_id` → `CoilID` (`CoilSet` in `*_nibs.json`)

- `coil_id` in `*_nibs.tsv` MUST reference a `CoilID` defined in the `CoilSet` section of `*_nibs.json`.

- `CoilID` values MUST be unique within a given `*_nibs.json`.

- The same `coil_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same coil definition applies.

##### `electrode_id` → `ElectrodeID` (`ElectrodeSet` in `*_nibs.json`)

- `electrode_id` in `*_nibs.tsv` MUST reference an `ElectrodeID` defined in the `ElectrodeSet` section of `*_nibs.json`.

- `ElectrodeID` values MUST be unique within a given `*_nibs.json`.

- The same `electrode_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same electrode configuration applies.
  
##### `transducer_id` → `TransducerID` (`TransducerSet` in `*_nibs.json`)

- `transducer_id` in `*_nibs.tsv` MUST reference a `TransducerID` defined in the `TransducerSet` section of `*_nibs.json`.

- `TransducerID` values MUST be unique within a given `*_nibs.json`.

- The same `transducer_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same transducer definition applies.
  
##### `stim_id` → `StimID` (`StimulusSet` in `*_nibs.json`)

- `stim_id` in `*_nibs.tsv` MUST reference a `StimID` defined in the `StimulusSet` section of `*_nibs.json`.

- `StimID` values MUST be unique within a given `*_nibs.json`.

- The same `stim_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same stimulation configuration applies.

##### `target_id` → spatial targets (`*_markers.tsv`)

- `target_id` in `*_nibs.tsv` MUST reference a row in `*_markers.tsv`.

- `target_id` values MUST be unique within a given `*_markers.tsv`.

#### Composite (multi-point) targets in `*_markers.tsv`

In some experiments, stimulation involves multiple spatial points that are conceptually related (e.g., multi-contact TES montages, multi-coil TMS setups, or phased-array TUS protocols with multiple focus locations).

In this specification, `*_markers.tsv` represents **one spatial point/contact per row**. Therefore, multi-point constructs are represented as **multiple rows**, each with its own unique `target_id`. These `target_id` values are then referenced from `*_nibs.tsv` to describe which points/contacts were involved in a given stimulation event.

| Field | Description |
|------|-------------|
| `target_id` | Identifier linking a single row (a single point/contact) in `*_markers.tsv` to stimulation events recorded in `*_nibs.tsv`. `target_id` values MUST be unique within a given `*_markers.tsv`. |
| `target_group` | string | (Optional) Group identifier used to logically group multiple `target_id` rows that belong to the same higher-level construct (e.g., a TES montage, an HD set, a multi-coil setup, a multi-focus set). This field is for convenience and organization only and MUST NOT be used for synchronization across modalities. |

This mechanism enables representation of:

- TES montages involving multiple electrode contacts (each contact has its own `target_id`)
- TMS stimulation involving multiple coils (each coil placement/point has its own `target_id`)
- TUS phased-array stimulation involving multiple spatial focus points (each focus location has its own `target_id`)

When sequential stimulation across multiple points is used (e.g., phased-array TUS beam steering), the order of stimulation across points SHOULD be encoded at the event/stimulus level (e.g., in `StimulusSet`) by referencing an ordered list of `target_id` values.

### 5. Synchronizing NIBS Data Across Modalities (`*_events.tsv`)

In multimodal experiments (e.g., NIBS combined with EEG, MEG, fMRI, or behavioral recordings), stimulation events are synchronized with other data streams using the shared `*_events.tsv` file.

The `*_events.tsv` file represents the primary timeline of experimental events, including stimulus presentations, behavioral responses, and stimulation triggers.

NIBS-specific stimulation parameters are stored in `*_nibs.tsv`.  
Synchronization between these files is achieved through the `event_id` field.

| Field | Description |
|------|-------------|
| `event_id` | Identifier linking a row in `*_nibs.tsv` to a corresponding event in `*_events.tsv`. |

Each row in `*_nibs.tsv` typically corresponds to a stimulation event referenced by the same `event_id` in `*_events.tsv`.

In some cases, a single experimental event may involve multiple stimulation configurations (e.g., TES with multiple channels or TMS with multiple coils).
In such cases, multiple rows in `*_nibs.tsv` MAY share the same `event_id`.

The `stim_count` field in `*_nibs.tsv` is intended only for counting repeated stimulation deliveries to the same target and MUST NOT be used for synchronization between modalities.


### 6. File-linking overview 

The NIBS data structure links stimulation events, device definitions, stimulus configurations, and spatial targets across several files.

The central table `*_nibs.tsv` contains event-level stimulation parameters.
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
					│                        *_nibs.tsv                         		  │
					│  Required:  event_id                                      		  │
					│  Links:     coil_id\electrode_id\transducer_id, stim_id, target_id  │
					│  Count:     stimulus_count (NOT for synchronization)      		  │
					└─────────────┬───────────────────────────────┬───────────────────────┘
								  │                               │
							   target_id                        event_id
								  │                               │
								  ▼                               ▼
					┌──────────────────────────┐        ┌────────────────────────┐
					│       *_markers.tsv      │        │       *_events.tsv     │
					│  		  target_id  	   │        │  onset/duration/...    │
					│						   │        │  MAY include event_id  │
					│  		MUST be unique	   │        │  					     │
					│                		   │        │  MUST NOT include      │
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

- `*_nibs.tsv` describes what was executed (logical stimulation events), and links to configuration (`*_nibs.json`) and space (`*_markers.tsv`).

- `*_events.tsv` describes when it happened (time-locking) via `event_id`.

- `*_markers.tsv` + `*_coordsystem.json` describe where it happened; composite targets are represented by multiple marker rows disambiguated by `target_id`.


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


## NIBS: Transcranial Magnetic Stimulation section

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `*_markers.json` )

Stores stimulation target coordinates and optional coil's orientation information. Supports multiple navigation systems (e.g., Localite, Nexstim) via flexible fields. 


| Field | Type | Description |
|---|---|---|
| `target_id` | string | Identifier of a stimulation target point (one row per target). |
| `target_group` | string | (Optional) Group identifier used to logically group multiple `target_id` rows that belong to the same higher-level construct (e.g., a TES montage, an HD set, a multi-coil setup, a multi-focus set). This field is for convenience and organization only and MUST NOT be used for synchronization across modalities. |
| `target_label` | string | (Optional) Short human-readable label for the stimulation target. Intended for standardized target naming when available (e.g., 10–20 position labels such as `C3`, `F3`, `Cz`, or common anatomical/site labels such as `M1_hand`, `DLPFC`). Interpretation is in the coordinate context defined by `*_coordsystem.json`. |
| `target_description` | string | (Optional) Free-form description of the stimulation target (e.g., anatomical location, rationale, landmark-based description, or notes on how the target was selected). Interpretation is in the coordinate context defined by `*_coordsystem.json` when coordinate-system conventions apply (e.g., 10–20 naming). |
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


### Field Ordering Rationale

The `_markers.tsv` file defines the spatial locations and (where applicable) orientation-related metadata for stimulation targets used across NIBS experiments (e.g., TMS, TES, TUS).
When designing this structure, we drew partial inspiration from existing BIDS files such as `*_electrodes.tsv` (eeg), which capture sensor positions.
However, no existing BIDS modality explicitly supports the full specification required for navigated TMS — including stimulation coordinates, coil pose/orientation, and optional electric field estimates — while TES/TUS introduce additional multi-point target constructs (e.g., electrode pairs, entry points).

This makes `_markers.tsv` a novel file type tailored to NIBS needs. Fields are ordered to reflect their functional roles:

- Identification: `target_id` appears first, enabling structured referencing from `*_nibs.tsv`.
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

- `CoilSet`, `ElectrodeSet`, `TransducerSet` — modality-specific device component definitions
- `StimulusSet` — reusable definitions of stimulation waveforms or stimulus configurations
- `StimulationSystem` — description of the primary stimulation device and hardware configuration
- `NavigationSystem` — neuronavigation or targeting system used during stimulation

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
| `PulseCount` | integer | Number of physical pulses contained in a single stimulation instance defined by `StimID` (e.g., single: 1; paired: 2; triple: 3; quadruple: 4; multi: N). |
| `PulseWaveform` | string | Shape of the stimulation pulse waveform produced by the stimulator (e.g., monophasic, biphasic, custom). Defined per `StimID`. |
| `PulseDuration` | number | (Optional) Duration of a single pulse, measured from pulse onset to pulse offset. Defined per `StimID`. |
| `PulseDurationUnits` | string | Units of `PulseDuration` (e.g., ms, µs). |
| `PulseRepetitionInterval` | number | (Optional) Within-instance pulse-to-pulse onset spacing (onset-to-onset) for stimulation instances with more than one physical pulse (`PulseCount` > 1). Assumed uniform across consecutive pulses within the instance. |
| `PulseRepetitionIntervalUnits` | string | Units of `PulseRepetitionInterval` (e.g., ms, µs). |
| `PulseIntensityScalingType` | string | Defines how pulse-specific intensities are derived from the base intensity specified in `*_nibs.tsv` (e.g., multiplicative, additive). |
| `PulseIntensityScalingVector` | array[number] | Vector of scaling coefficients, ordered by pulse occurrence within the stimulation instance. Length MUST match `PulseCount`. |
| `PulseIntensityScalingReference` | string | Specifies which per-event intensity field in `*_nibs.tsv` is used as the reference for applying `PulseIntensityScalingVector` when pulse-specific intensities differ within an instance. Allowed values: `base`, `threshold`. |
| `PulseIntensityScalingDescription` | string | Free-form description clarifying how scaling is applied and how pulse order is defined for the stimulation instance. |
| `PulseCurrentDirection` | string | (Optional) Vendor-defined coil current direction / polarity setting for the pulse (e.g., `normal`, `reverse`). This field refers to the direction of current flow in the coil as defined by the stimulator/coil system and MUST NOT be interpreted as the induced cortical current direction in tissue. |
| `PulseCurrentDirectionDescription` | string | (Optional) Free-form description of how `PulseCurrentDirection` is defined for this stimulator/coil (e.g., manufacturer convention, reference orientation, polarity definition). |

#### `StimulusSet` description example

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "quadruple",
    "PulseCount": 4,
    "PulseWaveform": "monophasic",
    "PulseDuration": 200,
    "PulseDurationUnits": "µs",
	"PulseRepetitionInterval": 10,
	"PulseRepetitionIntervalUnits": "ms",
    "PulseIntensityScalingType": "multiplicative",
    "PulseIntensityScalingVector": [1.0, 1.0, 1.0, 1.1],
    "PulseIntensityScalingReference": "base",
    "PulseIntensityScalingDescription": "Pulse-specific intensities are derived by multiplying the base intensity in *_nibs.tsv by the corresponding scaling coefficient (ordered by pulse occurrence within the instance). Vector length MUST match PulseCount.",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Free-form text description"
  },
  {
    "StimID": "stim_2",
    "StimulusType": "triple",
    "PulseCount": 3,
    "PulseWaveform": "biphasic",
    "PulseDuration": 200,
    "PulseDurationUnits": "µs",
	"PulseRepetitionInterval": 10,
	"PulseRepetitionIntervalUnits": "ms",
    "PulseIntensityScalingType": "additive",
    "PulseIntensityScalingVector": [0.0, 0.0, 5.0],
    "PulseIntensityScalingReference": "threshold",
    "PulseIntensityScalingDescription": "Pulse-specific intensities are computed by adding the corresponding offset to the threshold intensity in *_nibs.tsv (ordered by pulse occurrence within the instance). Vector length MUST match PulseCount.",
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

If representing a single logical stimulation event requires more than one stimulation configuration (e.g., changes in `stim_id` within the same initiated execution), it MUST be split across multiple rows (one per configuration segment). Rows belonging to the same logical event MUST share the same `event_id`.

Logical stimulation events may be delivered:

- manually by the experimenter,

- automatically by the stimulation device,

- or triggered externally (e.g., by experimental software, behavioral tasks, or physiological events).


Repeated deliveries SHOULD be represented by multiple rows when individual events are logged or time-locked. When time-locked annotations are provided in `*_events.tsv`, linkage is performed via `event_id` (not via `stim_id`, `target_id`, or `stimulus_count`).

This section describes all possible fields that may appear in `*_nibs.tsv` files. Fields are grouped into logical sections based on their functional role and expected variability during an experiment. All fields are optional unless stated otherwise, but some are strongly recommended.

The order and grouping of parameters in `*_nibs.tsv` reflect a hierarchical organization of stimulation metadata, progressing from device and configuration parameters, through event indexing, to spatial targeting and derived measures. This structure supports both manual and automated data acquisition scenarios.


**Coil Configuration**

| Field | Type | Description |
|---|---:|---|
| `coil_id` | string | Coil identifier. References `CoilID` entries in `CoilSet` within `*_nibs.json`. |

**Non-navigated coil placement/orientation (optional)**

These fields support studies without neuronavigation, where coil placement and orientation are recorded using conventional verbal descriptions. They are intended for event-level documentation and MAY vary across rows in `*_nibs.tsv`.

| Field | Type | Description |
|---|---:|---|
| `coil_positioning_method` | string | (Optional) Method used to guide coil positioning (free-form). Recommended values include: `manual`, `fixed`, `cobot`, `robot`. |
| `coil_handle_direction` | string | (Optional) Free-form coplanar coil handle direction description (e.g., “handle posterior”, “45° posterolateral”). |
| `coil_placement_description` | string | (Optional) Free-form description of coil placement/orientation relative to anatomical landmarks or conventions used in the study. |
| `coil_orientation_code` | string | (Optional) Short structured orientation code when a local convention exists (free-form but recommended to use a limited set within a dataset: “PA”, “AP”, “LM”, “ML”). |

**Protocol / Event Metadata**

| Field | Type | Description |
|---|---:|---|
| `event_id` | string | Identifier of a single logical stimulation event. Used for linkage to time-locked annotations in `*_events.tsv`. MUST be unique within a given `*_nibs.tsv` file. |
| `event_part` | integer | (Optional) Index of a row/segment within a logical stimulation event (`event_id`) when multiple rows are required to represent one event (e.g., multi-contact TES, multi-component stimulation, or segmented configurations). Values SHOULD start at 1 and increment monotonically (1..N) within each `event_id`. When present, `event_part` MUST be unique within the same `event_id`. |
| `event_name` | string | (Optional) Human-readable protocol label (e.g., SICI, LICI, custom). Intended for readability; MUST NOT be used for machine linkage. |

**Stimulation Configuration Reference**

| Field | Type | Description |
|---|---:|---|
| `stim_id` | string | Identifier of a stimulation configuration/pattern. References `StimID` entries in `StimulusSet` within `*_nibs.json`. |


**Stimulation Timing Parameters** 

| Field | Type | Description |
|---|---:|---|
| `train_duration` | number | (Optional) Active duration of a train, from the onset of the first element in the train to the end of the last element in the train (onset-to-offset)(i.e., excludes any post-train gap). |
| `train_count` | number | (Optional) Number of stimulation instances delivered within one train (count). |
| `train_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive stimulation instances within a train (used together with `train_count`). |
| `repeat_duration` | number | (Optional) Active duration of a repeat block, from the onset of the first train in the repeat to the end of the last train in the repeat (onset-to-offset)(i.e., excludes any post-repeat gap). || `repeat_count` | number | (Optional) Number of repeats indicated by an event. |
| `repeat_count` | number | (Optional) Number of trains (train windows) delivered within one repeat block (count). |
| `repeat_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive trains (train windows) within a repeat block (used together with `repeat_count`). |
| `train_ramp_up` | number | (Optional) Gradual increase of stimulation amplitude applied across successive trains at the beginning of a stimulation block (train-to-train ramping). |
| `train_ramp_up_count` | number | (Optional) Number of initial trains over which the ramp-up is applied. |
| `train_ramp_down` | number | (Optional) Gradual decrease of stimulation amplitude applied across successive trains at the end of a stimulation block (train-to-train ramping). |
| `train_ramp_down_count` | number | (Optional) Number of final trains over which the ramp-down is applied. |
| `stimulation_duration` | number | (Optional) Total wall-clock duration of the stimulation block. |
   
*Timing hierarchy note:* In this scheme, `PulseCount`/`PulseRepetitionInterval` define the within-instance pulse structure in `StimulusSet` (`*_nibs.json`). At the event level (`*_nibs.tsv`), `train_*` parameters describe repetition of stimulation instances within a train window, and `repeat_*` parameters describe repetition of train windows within a higher-level repeat block.

**Spatial & Targeting Information**

| Field | Type | Description |
|---|---:|---|
| `target_id` | string | Identifier of a spatial stimulation target (stimulation-level target identifier). Links `*_nibs.tsv` to spatial target definitions in `*_markers.tsv`. |

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
| `stimulus_count` | integer | (Optional) Counter indicating the number of times a stimulation instance with the same `stim_id` has been delivered to the same `target_id` within the current file/session. Intended for counting deliveries to a target; MUST NOT be used for synchronization across modalities. Values typically start at 1 and increment monotonically for successive deliveries of the same (`stim_id`, `target_id`) combination. |
| `stimulus_validation` | string | (Optional) Free-form indication of whether stimulation delivery/positioning was verified or observed (e.g., `verified`, `observed`, `not_verified`, `unknown`). |
| `measured_current_gradient` | number | (Optional) Device-reported measured gradient of coil current (units device-dependent). |
| `electric_field_target` | number | (Optional) Electric-field magnitude at the stimulation target, as reported by the stimulation/navigation system during acquisition or derived from an explicit field model. This value is not a direct measurement of tissue current. |
| `electric_field_max` | number | (Optional) Maximum (peak) electric-field magnitude within the modeled/reported region, as reported during acquisition or derived from an explicit field model. This value is not a direct measurement of tissue current. |
| `electric_field_units` | string | (Optional) Units for `electric_field_target` and `electric_field_max` (free-form; recommended: `V/m`). SHOULD be provided when any `electric_field_*` value is present. |
| `electric_field_model_name` | string | (Optional) Name of the model/system used to obtain `electric_field_*` values (e.g., navigation software name, field estimation model name). SHOULD be provided when any `electric_field_*` value is present. |
| `electric_field_model_version` | string | (Optional) Version of the model/system used to obtain `electric_field_*` values (free-form vendor/version string). SHOULD be provided when any `electric_field_*` value is present. |
| `motor_response` | number | (Optional) Aggregate motor response metric reported by the stimulation system or experimenter and used during stimulation setup/calibration (e.g., threshold determination). This is a procedure-level summary value (e.g., amplitude/magnitude) and does not represent the full EMG waveform. Units and computation method are device- or protocol-dependent and may be proprietary. |
| `latency` | number | (Optional) Device- or procedure-reported delay between stimulus delivery and the detected motor response, as used during the experiment (e.g., for threshold estimation). This is a summary timing value and does not imply a standardized onset detection method. |
| `response_channel_name` | string | (Optional) Name/label of the recorded channel used to derive the response metric (e.g., EMG channel name). |
| `response_channel_type` | string | (Optional) Type of channel (e.g., `emg`, `eeg`, `meg`, `other`). |
| `response_channel_description` | string | (Optional) Free-form description of the response channel and how it was used. |
| `response_channel_reference` | string | (Optional) Reference channel name/label if applicable. |
| `response_channel_status` | string | (Optional) Free-form indication of data/measurement quality observed on the response channel. |
| `response_channel_status_description` | string | (Optional) Free-form description of noise/artifact affecting data quality on the response channel. |
| `status` | string  | (Optional) Data quality observed on the channel.                                               
| `status_description` | string  | (Optional) Freeform text description of noise or artifact affecting data quality on the channel.                                               
| `subject_feedback` | string | (Optional) Participant-reported perception, discomfort, or other feedback related to stimulation. |
| `intended_for` | string | (Optional) BIDS-style reference/URI to a recorded data file associated with the response/measurement (example: `bids::sub-01/ses-01/eeg/sub-01_ses-01_task-..._eeg.eeg`). |
| `timestamp` | string | (Optional) Timestamp in ISO 8601 format indicating when the stimulation instance occurred or was logged by the system. |

* Notes

- Motor response–related parameters in the NIBS-BIDS specification are intended to store procedure-level or device-reported summary values used during stimulation setup (e.g., motor threshold determination).

- They are not intended to replace or describe EMG recordings or waveform-level analyses, which should be represented using dedicated EMG data types and extensions when available.

- If `electric_field_*` values are computed offline as part of post-processing, they SHOULD be stored in a derived dataset (or accompanied by sufficient provenance metadata to reproduce the computation).

### 1.4 `*_nibs.json` & `*_nibs.tsv` hierarchy logic

Legend:

- `stim_id` → references a `StimulusSet` entry in `*_nibs.json` (`StimID`)
- row → one row in `*_nibs.tsv` (a stimulation record)
- logical event → one initiated stimulation execution that completes as a whole, indexed by `event_id`

Hierarchy (structure + repetition):

**Stimulation instance structure (defined in `*_nibs.json`)**

`StimulusSet` (in `*_nibs.json`)
- `StimID = "stim_A"` defines the internal structure of a stimulation instance:
  - number of physical pulses in the instance: `PulseCount = N`
  - within-instance pulse spacing (uniform, if `N > 1`): `PulseRepetitionInterval` (+ `PulseRepetitionIntervalUnits`)
  - pulse properties: `PulseWaveform`, `PulseDuration`, `PulseCurrentDirection`
  - pulse-intensity rules (optional): `PulseIntensityScalingType`, `PulseIntensityScalingVector`, `PulseIntensityScalingReference`

**Within a logical stimulation event (recorded in `*_nibs.tsv`)**

- A logical stimulation event is identified by `event_id`.
- In the common case, one logical event is represented by a single `*_nibs.tsv` row:
  - the row references the stimulation-instance structure via `stim_id`
  - the row contains per-event parameters (e.g., intensities, targeting linkage, device/procedure metadata)

- If a single logical event requires more than one stimulation configuration (e.g., changes in `stim_id` within the same initiated execution), it MUST be split across multiple rows:
  - all rows share the same `event_id`


- Paradigm-level repetition described as a single initiated execution (e.g., burst/train delivered as one command) MAY be represented as one logical event. In such cases, repetition timing is described parametrically in `*_nibs.tsv` using the applicable timing fields (e.g., `burst_stimuli_number`, `burst_stimuli_interval`, `train_burst_number`, `inter_burst_interval`, etc.).

**Between stimulation events (across rows)**

- When time-locked onsets are provided, they SHOULD be recorded in `*_events.tsv` and linked via `event_id`.



## NIBS: Transcranial Electrical Stimulation section (TES).

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

| Field | Type | Description |
|---|---|---|
| `target_id` | string | Identifier of a TES montage (stimulation-level target). A single electrode/contact position (one row per contact) |
| `target_group` | string | (Optional) Group identifier used to logically group multiple `target_id` rows that belong to the same higher-level construct (e.g., a TES montage, an HD set, a multi-coil setup, a multi-focus set). This field is for convenience and organization only and MUST NOT be used for synchronization across modalities. |
| `target_label` | string | (Optional) Short human-readable label for the stimulation target. Intended for standardized target naming when available (e.g., 10–20 position labels such as `C3`, `F3`, `Cz`, or common anatomical/site labels such as `M1_hand`, `DLPFC`). Interpretation is in the coordinate context defined by `*_coordsystem.json`. |
| `target_description` | string | (Optional) Free-form description of the montage/target rationale (e.g., anatomical rationale, selection notes). |
| `peeling_depth` | number | (Optional. For TES, peeling_depth is typically not used.) Depth/distance from cortex surface to the target point OR from an entry marker to a target marker (if applicable for the coordinate definition). |
| `entry_x` | number | X-coordinate of the electrode/contact position on the scalp (TES primary spatial point). |
| `entry_y` | number | Y-coordinate of the electrode/contact position on the scalp (TES primary spatial point). |
| `entry_z` | number | Z-coordinate of the electrode/contact position on the scalp (TES primary spatial point). |
| `target_x` | number | (Optional) X-coordinate of an intracranial target point associated with the montage (e.g., model-derived). |
| `target_y` | number | (Optional) Y-coordinate of an intracranial target point associated with the montage (e.g., model-derived). |
| `target_z` | number | (Optional) Z-coordinate of an intracranial target point associated with the montage (e.g., model-derived). |
| `electric_field_max_x` | number | (Optional) X-coordinate of the location where `electric_field_max` was obtained (model-/system-derived). Coordinate frame and units are defined by `*_coordsystem.json` / `NIBSCoordinateUnits`. |
| `electric_field_max_y` | number | (Optional) Y-coordinate of the location where `electric_field_max` was obtained (model-/system-derived). Coordinate frame and units are defined by `*_coordsystem.json` / `NIBSCoordinateUnits`. |
| `electric_field_max_z` | number | (Optional) Z-coordinate of the location where `electric_field_max` was obtained (model-/system-derived). Coordinate frame and units are defined by `*_coordsystem.json` / `NIBSCoordinateUnits`. |

* Notes

For TES, electrode/contact locations are recorded as `entry_x`, `entry_y`, `entry_z` (scalp surface points).  
`target_x`, `target_y`, `target_z` are OPTIONAL and may be used to store an intracranial target point associated with the montage (e.g., a model-derived target used for field estimation). If `target_*` values are derived offline, they SHOULD be stored in a derived dataset (or accompanied by explicit provenance metadata).

#### Example *_markers.tsv

```
target_id	target_label	target_description				    entry_x  entry_y  entry_z
tes_01  	F3				"... montage description ..."	    ...      ...      ...
tes_02      Cz				"... montage description ..."	    ...      ...      ...
tes_03      C3				"... montage description ..."	    ...      ...      ...
tes_04      C4				"... montage description ..."	    ...      ...      ...

```

### 1.2 `*_nibs.json` — Sidecar JSON 

The _nibs.json file is a required sidecar accompanying the _nibs.tsv file. 
It serves to describe the columns in the tabular file, define units and levels for categorical variables, and—crucially—provide structured metadata about the stimulation device, task, and context of the experiment.

Like other BIDS modalities, this JSON file includes:

**Task information:**

- TaskName, TaskDescription, Instructions

**Institutional context:**

- InstitutionName, InstitutionAddress, InstitutionalDepartmentName

**Device metadata:**

- Manufacturer, ManufacturersModelName, SoftwareVersion, DeviceSerialNumber

**Additional options**

- `CoilSet`, `ElectrodeSet`, `TransducerSet` — modality-specific device component definitions
- `StimulusSet` — reusable definitions of stimulation waveforms or stimulus configurations
- `StimulationSystem` — description of the primary stimulation device and hardware configuration
- `NavigationSystem` — neuronavigation or targeting system used during stimulation

Additionally, the _nibs.json file introduces a dedicated hardware block called 'ElectrodeSet', which captures detailed physical and electromagnetic parameters of one or more stimulation electrodes used in the session. 
This structure allows precise modeling, reproducibility, and harmonization of electrode-related effects across studies.

#### `ElectrodeSet`

`ElectrodeSet` defines reusable TES **electrode/contact hardware entries** used within montages (“what was used”), independently of spatial placement (`*_markers.tsv`) and per-event stimulation values (`*_nibs.tsv`).

`ElectrodeSet` is an array of definitions. Each entry is identified by `ElectrodeID`, which is referenced from `*_nibs.tsv` via `electrode_id`.

| Field | Type | Description |
|---|---:|---|
| `ElectrodeID` | string | Unique identifier of an electrode montage hardware configuration, referenced from `*_nibs.tsv` via `electrode_id`. |
| `ElectrodeRole` | string | REQUIRED. Role within the montage (e.g., `anode`, `cathode`, `return`, `ground`, `other`). |
| `ElectrodeManufacturer` | string | (Optional) Manufacturer name. |
| `ElectrodeModelName` | string | (Optional) Model name/number. |
| `ElectrodeSerialNumber` | string | (Optional) Serial number (if applicable). |
| `ElectrodeNotes` | string | (Optional) Free-form notes. |
| `ElectrodeShape` | string | (Optional) Physical shape (e.g., rectangular, circular, ring, segmented). |
| `ElectrodeArea` | object | (Optional) Contact area with units (recommended: `cm^2`). |
| `ElectrodeSize` | object | (Optional) Contact size/dimensions with units. |
| `ElectrodeThickness` | object | (Optional) Total thickness with units. |
| `ElectrodeMaterial` | string | (Optional) Material in direct contact with skin (e.g., Ag/AgCl, rubber, carbon). |
| `ElectrodeContactMedium` | string | (Optional) Interface medium (e.g., gel, saline, paste, dry). |
| `ElectrodePreparation` | string | (Optional) Free-form preparation notes. |

#### Example JSON `ElectrodeSet` (different contacts within one montage)

```
"ElectrodeSet": [
  {
    "ElectrodeID": "elec_1",
    "ElectrodeRole": "anode",
    "ElectrodeManufacturer": "ExampleManufacturer",
    "ElectrodeModelName": "ExampleModel",
    "ElectrodeSerialNumber": "SN-001",
    "ElectrodeShape": "rectangular",
    "ElectrodeArea": { "Value": 25, "Units": "cm^2" },
    "ElectrodeSize": { "Value": "5x5", "Units": "cm" },
    "ElectrodeThickness": { "Value": 5, "Units": "mm" },
    "ElectrodeMaterial": "carbon rubber",
    "ElectrodeContactMedium": "saline",
    "ElectrodePreparation": "Saline-soaked sponge",
    "ElectrodeNotes": "Anode electrode definition"
  },
  {
    "ElectrodeID": "elec_2",
    "ElectrodeRole": "cathode",
    "ElectrodeManufacturer": "ExampleManufacturer",
    "ElectrodeModelName": "ExampleModel",
    "ElectrodeSerialNumber": "SN-002",
    "ElectrodeShape": "rectangular",
    "ElectrodeArea": { "Value": 25, "Units": "cm^2" },
    "ElectrodeSize": { "Value": "5x5", "Units": "cm" },
    "ElectrodeThickness": { "Value": 5, "Units": "mm" },
    "ElectrodeMaterial": "carbon rubber",
    "ElectrodeContactMedium": "saline",
    "ElectrodePreparation": "Saline-soaked sponge",
    "ElectrodeNotes": "Cathode electrode definition"
  }
]
```

#### Linking rule to *_markers.tsv

For TES montages represented by multiple contacts:

- *_nibs.tsv references the montage hardware via electrode_id → ElectrodeSet.ElectrodeID.

- *_nibs.tsv references the montage geometry via target_id → rows in *_markers.tsv.

- *_markers.tsv represents a montage as multiple rows disambiguated by target_id.

**  A complete example is included in Appendix A.


#### `StimulusSet` (TES)

`StimulusSet` defines reusable TES stimulation configurations referenced from `*_nibs.tsv` via `stim_id`. Each entry describes the signal form and control characteristics of a TES stimulation instance/template (not event-specific dosing values).

| Field | Type | Description |
|---|---:|---|
| `StimID` | string | Identifier of the TES stimulation configuration/template. Referenced from `*_nibs.tsv` via `stim_id`. MUST be unique within `*_nibs.json`. |
| `StimulusType` | string | TES stimulation mode/type (e.g., `tDCS`, `tACS`, `tRNS`, `tPCS`). |
| `StimulusControlMode` | string | Stimulator control mode (what the device regulates). Recommended values: `current-controlled`, `voltage-controlled`. |
| `StimulusWaveform` | string | Type of waveform used to deliver stimulation (e.g., `sine`, `square`, `pulse`, `custom`). |
| `StimulusFrequency` | number | (Optional) Waveform frequency in Hz (applicable to periodic waveforms such as `tACS` / some `tPCS`; typically omitted for `tDCS`). |
| `StimulusNoiseType` | string | (Optional) Noise specification for tRNS (e.g., white, pink, band-limited, custom). Describes the intended/high-level noise type as defined by the device/protocol. |
| `NoiseFrequencyBand` | object | (Optional) Frequency band definition for noise-based stimulation (recommended for `tRNS`). Structured as `{ "Low": <number>, "High": <number>, "Units": <string> }` (typically `Hz`). **REQUIRED** when `StimulusNoiseType = band-limited`. |
| `NoiseGenerationMethod` | string | (Optional) Method by which the noise signal is generated or implemented (e.g., `device-native`, `gaussian-sampled`, `uniform-sampled`, `lookup-table`, `filtered-noise`, `custom`). Use to capture vendor-/software-specific implementation details when relevant for reproducibility. |
| `NoiseSampleDistribution` | string | (Optional) Statistical distribution of instantaneous noise samples/values when known (e.g., `gaussian`, `uniform`, `custom`). |
| `NoiseUpdateRate` | object | (Optional) Noise update / resampling rate when known. Structured as `{ "Value": <number>, "Units": <string> }` (typically `Hz`). Indicates how frequently the noise signal is updated by the device/generator. |


##### tPCS-specific (transcranial Pulsed Current Stimulation) metadata fields 

| Field | Type | Description |
|---|---:|---|
| `PulseWaveform` | string | (Optional; applicable to `tPCS`) Pulse waveform/polarity (e.g., `monophasic`, `biphasic`). |
| `PulseCount` | integer | (Optional; applicable to `tPCS`) Number of pulses within one stimulation instance/template. |
| `PulseDuration` | number | (Optional; applicable to `tPCS`) Duration of a single pulse (pulse width). |
| `PulseDurationUnits` | string | (Optional; applicable to `tPCS`) Units of `PulseDuration` (e.g., ms, µs). |
| `PulseRepetitionInterval` | number | (Optional; applicable to `tPCS`) Pulse onset-to-onset interval between consecutive pulses within the same stimulation instance/template. SHOULD be provided when `PulseCount > 1`. |
| `PulseRepetitionIntervalUnits` | string | (Optional; applicable to `tPCS`) Units of `PulseRepetitionInterval` (e.g., ms, s). |

**Notes**
- For `tPCS`, pulse timing within an instance is described via `PulseRepetitionInterval` (analogous to the TMS `StimulusSet` logic). `StimulusFrequency` SHOULD NOT be used to encode the within-instance pulse rate for `tPCS`.
- Event-level repetition and block timing (train/repeat/duration parameters) are described in `*_nibs.tsv`.

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


### 1.3 `*_nibs.tsv` — Stimulation Parameters

#### Conceptual definition

In TES, a single logical stimulation event may involve multiple simultaneous electrode contacts (e.g., anode + cathode, anode + multiple returns, multi-channel montages). Therefore, `*_nibs.tsv` MAY contain multiple rows with the same `event_id`. Each row encodes event-level parameters for one electrode/contact/channel participating in that logical event.

- `event_id` is the primary linkage key to `*_events.tsv`.
- When multiple rows share the same `event_id`, `event_part` SHOULD be used to index the parts of that event (1..N).
- Each row references:
  - the electrode/contact hardware definition via `electrode_id` (`*_nibs.json` → `ElectrodeSet.ElectrodeID`, including `ElectrodeRole`),
  - the stimulation template via `stim_id` (`*_nibs.json` → `StimulusSet.StimID`),
  - the spatial placement of that contact via `target_id` (`*_markers.tsv`).

When `event_part` is present, the pair (`event_id`, `event_part`) MUST be unique within `*_nibs.tsv`.

#### Core linkage fields

**Stimulator Configuration**

| Field | Type | Description |
|---|---:|---|
| `electrode_id` | string | References `ElectrodeSet.ElectrodeID` in `*_nibs.json` (includes `ElectrodeRole`). |

**Protocol / Event Metadata**

| Field | Type | Description |
|---|---:|---|
| `event_id` | integer | Identifier of a logical stimulation event. Primary linkage key to `*_events.tsv`. Multiple rows MAY share the same `event_id` to encode per-contact parameters. |
| `event_part` | integer | (Optional) Index of a row/segment within a logical stimulation event (`event_id`) when multiple rows are required to represent one event (e.g., multi-contact TES, multi-component stimulation, or segmented configurations). Values SHOULD start at 1 and increment monotonically (1..N) within each `event_id`. When present, `event_part` MUST be unique within the same `event_id`. |
| `event_name` | string | (Optional) Human-readable event/protocol label. Intended for readability; MUST NOT be used for machine linkage. |

**Stimulation Configuration Reference**

| Field | Type | Description |
|---|---:|---|
| `stim_id` | string | References `StimulusSet.StimID` in `*_nibs.json`. |

**Stimulation Timing Parameters (tDCS / tACS — continuous protocols)**

For continuous TES protocols (e.g., tDCS, tACS), timing is typically described by the total stimulation duration and optional ramp phases. When stimulation is delivered in repeated on/off windows, the `repeat_*` fields define the repetition pattern.

| Field | Type | Description |
|---|---:|---|
| `stimulation_duration` | number | (Optional) Total wall-clock duration of the stimulation block. **Includes** `ramp_up_duration` and `ramp_down_duration` phases if present. |
| `ramp_up_duration` | number | (Optional) Duration of the amplitude ramp-up phase at the beginning of the stimulation block. This duration is a subcomponent of `stimulation_duration` when both are provided. |
| `ramp_down_duration` | number | (Optional) Duration of the amplitude ramp-down phase at the end of the stimulation block. This duration is a subcomponent of `stimulation_duration` when both are provided. |
| `repeat_duration` | number | (Optional) Active duration of one stimulation window (repeat unit), from onset to end (excludes any post-window gap). |
| `repeat_count` | number | (Optional) Number of repeated stimulation windows delivered within the block (count).|
| `repeat_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive stimulation windows (repeat units) within the block. |

**Stimulation Timing Parameters tPCS (transcranial Pulsed Current Stimulation)**

| Field | Type | Description |
|---|---:|---|
| `train_duration` | number | (Optional) Active duration of a train, from the onset of the first element in the train to the end of the last element in the train (onset-to-offset)(i.e., excludes any post-train gap). |
| `train_count` | number | (Optional) Number of stimulation instances delivered within one train (count). |
| `train_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive stimulation instances within a train (used together with `train_count`). |
| `repeat_duration` | number | (Optional) Active duration of a repeat block, from the onset of the first train in the repeat to the end of the last train in the repeat (onset-to-offset)(i.e., excludes any post-repeat gap). |
| `repeat_count` | number | (Optional) Number of trains (train windows) delivered within one repeat block (count). |
| `repeat_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive trains (train windows) within a repeat block (used together with `repeat_count`). |

**Spatial & Targeting Information**

| Field | Type | Description |
|---|---:|---|
| `target_id` | string | Identifier of a TES montage geometry. Links `*_nibs.tsv` to montage/contact definitions in `*_markers.tsv` (electrode positions via `entry_*`). |

**Amplitude & Thresholds (TES)**

| Field | Type | Description |
|---|---:|---|
| `base_current_intensity` | number | (Optional) Commanded stimulation current amplitude for the event/contact. Applicable to current-controlled stimulation. Units SHOULD be documented (recommended: mA). |
| `base_voltage_intensity` | number | (Optional) Commanded stimulation voltage amplitude for the event/contact. Applicable to voltage-controlled stimulation. Units SHOULD be documented (recommended: V). |
| `base_pulse_intensity` | number | (Optional; applicable to `tPCS`) Commanded pulse intensity for pulsed stimulation. Units SHOULD be documented (recommended: mA for current-controlled, V for voltage-controlled). |
| `threshold_type` | string | (Optional) Type of threshold used as a reference for dosing or safety limits. Recommended values include `sensation` (perceptual threshold) and `pain` (discomfort/pain threshold), or `custom`. |
| `threshold_reference_current` | number | (Optional) Threshold reference value expressed as current amplitude (recommended units: mA). Intended for thresholds such as sensation/pain when defined in current units. |
| `threshold_reference_voltage` | number | (Optional) Threshold reference value expressed as voltage amplitude (recommended units: V). Intended for thresholds such as sensation/pain when defined in voltage units. |

* For alternating waveforms (e.g., tACS), the value represents the peak current amplitude unless otherwise specified by the device (I(t) = `base_current_intensity` mA * sin(2πft)).

* base_voltage_intensity represents the peak voltage amplitude delivered by the stimulator (I(t) = `base_voltage_intensity` V * sin(2πft)).

**Derived / Device-Generated Parameters (TES)**

| Field | Type | Description |
|---|---:|---|
| `contact_impedance` | number | (Optional) Measured contact impedance for this electrode/contact as reported during the session. Units MUST be documented (recommended: Ω or kΩ). |
| `status` | string | (Optional) Free-form indication of device/channel measurement quality or status for this contact/event. |
| `status_description` | string | (Optional) Free-form description of noise, artifact, safety limit, or any issue affecting this contact/event. |
| `subject_feedback` | string | (Optional) Participant-reported perception or discomfort related to stimulation (e.g., tingling, itching, pain). |
| `measured_current_intensity` | number | (Optional) Device-reported measured current amplitude for this contact/channel (when available). Units MUST be documented (recommended: mA). |
| `measured_voltage_intensity` | number | (Optional) Device-reported measured voltage amplitude for this contact/channel (when available). Units MUST be documented (recommended: V). |
| `current_statistics` | string | (Optional) Summary statistics reported by the device/software for delivered current (e.g., min/mean/max, stability metrics). Format and units are device-dependent and should be documented. |
| `electric_field_target` | number | (Optional) Electric-field magnitude at the stimulation target, as reported during acquisition or derived from an explicit field model. Not a direct measurement of tissue current. |
| `electric_field_max` | number | (Optional) Maximum (peak) electric-field magnitude within the modeled/reported region, as reported during acquisition or derived from an explicit field model. Not a direct measurement of tissue current. |
| `electric_field_units` | string | (Optional) Units for `electric_field_target` and `electric_field_max` (recommended: `V/m`). SHOULD be provided when any `electric_field_*` value is present. |
| `electric_field_model_name` | string | (Optional) Name of the model/system used to obtain `electric_field_*` values (e.g., navigation/software name, field estimation model name). SHOULD be provided when any `electric_field_*` value is present. |
| `electric_field_model_version` | string | (Optional) Version of the model/system used to obtain `electric_field_*` values. SHOULD be provided when any `electric_field_*` value is present. |
| `timestamp` | string | (Optional) Timestamp in ISO 8601 format indicating when the stimulation instance occurred or was logged by the system. |

 
 
## NIBS: Transcranial Ultrasound Stimulation section.

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

| Field | Type | Description |
|---|---|---|
| target_id              | REQUIRED         | Identifier linking this stimulation target to entries in `*_nibs.tsv`. |
| target_group 			 | string 			| (Optional) Group identifier used to logically group multiple `target_id` rows that belong to the same higher-level construct (e.g., a TES montage, an HD set, a multi-coil setup, a multi-focus set). This field is for convenience and organization only and MUST NOT be used for synchronization across modalities. |
| target_label           | OPTIONAL         | Short human-readable label for the stimulation target (e.g., `M1_left`, `V1`, `hippocampus`). |
| target_description     | OPTIONAL         | Free-text description of the stimulation target or the rationale for its selection. |
| target_x               | OPTIONAL         | X coordinate of the stimulation target. Coordinate system defined in `*_coordsystem.json`. |
| target_y               | OPTIONAL         | Y coordinate of the stimulation target. Coordinate system defined in `*_coordsystem.json`. |
| target_z               | OPTIONAL         | Z coordinate of the stimulation target. Coordinate system defined in `*_coordsystem.json`. |
| entry_x                | OPTIONAL         | X coordinate of the ultrasound beam entry point on the scalp or skull surface. |
| entry_y                | OPTIONAL         | Y coordinate of the ultrasound beam entry point on the scalp or skull surface. |
| entry_z                | OPTIONAL         | Z coordinate of the ultrasound beam entry point on the scalp or skull surface. |
| normal_x               | OPTIONAL         | X component of the unit vector normal to the transducer surface. |
| normal_y               | OPTIONAL         | Y component of the unit vector normal to the transducer surface. |
| normal_z               | OPTIONAL         | Z component of the unit vector normal to the transducer surface. |
| beam_x                 | OPTIONAL         | X component of the ultrasound beam direction vector. |
| beam_y                 | OPTIONAL         | Y component of the ultrasound beam direction vector. |
| beam_z                 | OPTIONAL         | Z component of the ultrasound beam direction vector. |
| transducer_x           | OPTIONAL         | X coordinate of the ultrasound transducer center. |
| transducer_y           | OPTIONAL         | Y coordinate of the ultrasound transducer center. |
| transducer_z           | OPTIONAL         | Z coordinate of the ultrasound transducer center. |
| transducer_transform   | OPTIONAL         | Transformation matrix describing the pose of the ultrasound transducer relative to the coordinate system. Typically a 4×4 homogeneous transformation matrix. |

** target_x/y/z: **

- "Coordinates of the acoustic focus — the point where the ultrasound energy is concentrated and stimulation is intended to occur."

** entry_x/y/z: **  

- "Scalp entry point of the ultrasound beam — where it penetrates the skin and skull en route to the target."

** transducer_x/y/z: ** 

- "Coordinates of the ultrasound transducer’s physical reference point — typically its geometric center or coupling interface."

** normal_x/y/z: ** 

- "Unit vector normal to the scalp at the entry point, defining the intended beam axis direction."

** beam_x/y/z: ** 

- "Unit vector defining the direction of the ultrasound beam propagation from the transducer. Used if the beam axis differs from the scalp surface normal vector (normal_x/y/z)."

** transducer_transform: ** 

- "Optional 4×4 affine transformation matrix describing the transducer’s spatial pose (position and orientation) relative to the coordinate system defined in *_coordsystem.json. Used in setups with tracked transducers or navigation systems."


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

- `CoilSet`, `ElectrodeSet`, `TransducerSet` — modality-specific device component definitions
- `StimulusSet` — reusable definitions of stimulation waveforms or stimulus configurations
- `StimulationSystem` — description of the primary stimulation device and hardware configuration
- `NavigationSystem` — neuronavigation or targeting system used during stimulation

#### `TransducerSet` 

`TransducerSet` provides a structured, machine-readable description of ultrasound transducers used in the dataset.
Each transducer is defined as an object with a unique `TransducerID`, referenced from the `transducer_id` column in `*_nibs.tsv`.
This block is analogous to `CoilSet` (TMS) and `ElectrodeSet` (TES) and captures physical and acoustic properties of the transducer, including its focusing characteristics and coupling interface.

* Each entry in `TransducerSet` is an object with the following fields:

| Field | Type | Description |
|---|---:|---|
| `TransducerID` | string | Unique identifier for the transducer, referenced from `transducer_id` in `*_nibs.tsv`. |
| `TransducerType` | string | Physical configuration of the transducer (e.g., `single-element`, `phased-array`, `planar`, `custom`). |
| `FocusType` | string | Focus profile produced by the transducer (e.g., `point`, `line`, `volume`, `swept`, `unfocused`). |
| `CarrierFrequency` | object \| number | Nominal center frequency of the transducer carrier. RECOMMENDED as `{ "Value": <number>, "Units": "Hz", "Description": <string> }`. |
| `FocalDepth` | object \| number | Distance from the transducer surface to the nominal acoustic focus. RECOMMENDED as `{ "Value": <number>, "Units": "mm", "Description": <string> }`. |
| `ApertureDiameter` | object \| number | Diameter of the active acoustic aperture. RECOMMENDED as `{ "Value": <number>, "Units": "mm", "Description": <string> }`. |
| `MaxPeakNegativePressure` | object \| number | Maximum or rated peak negative pressure at the focus under reference conditions (manufacturer specification or calibration). RECOMMENDED as `{ "Value": <number>, "Units": "MPa", "Description": <string> }`. |
| `MaxMechanicalIndex` | object \| number | Maximum or rated Mechanical Index under reference conditions (dimensionless). RECOMMENDED as `{ "Value": <number>, "Units": "dimensionless", "Description": <string> }`. |
| `ContactMedium` | string | Coupling medium/interface between transducer and scalp (e.g., `ultrasound gel`, `membrane`, `water bag`, `dry contact`). |


**Phased-array extensions (OPTIONAL; use when `TransducerType` is `phased-array`)**

| Field | Type | Description |
|---|---:|---|
| `NumberOfElements` | integer | Number of independently driven elements in the array. |
| `ElementPitch` | object \| number | Center-to-center spacing between adjacent elements. RECOMMENDED as `{ "Value": <number>, "Units": "mm", "Description": <string> }`. |
| `ArrayGeometry` | string | High-level description of array layout (e.g., `linear`, `2D matrix`, `annular`, `curvilinear`, `custom`). |

#### TransducerSet description:

```
"TransducerSet": [
  {
    "TransducerID": "tx_1",
    "TransducerType": "single-element",
    "FocusType": "point",
    "CarrierFrequency": { "Value": 500000, "Units": "Hz" },
    "FocalDepth": { "Value": 30, "Units": "mm" },
    "ApertureDiameter": { "Value": 30, "Units": "mm" },
    "MaxPeakNegativePressure": { "Value": 1.2, "Units": "MPa" },
    "MaxMechanicalIndex": { "Value": 0.9, "Units": "dimensionless" },
    "ContactMedium": "ultrasound gel"
  },
  {
    "TransducerID": "tx_2",
    "TransducerType": "phased-array",
    "FocusType": "steerable-point",
    "CarrierFrequency": { "Value": 650000, "Units": "Hz" },
    "FocalDepth": { "Value": 40, "Units": "mm" },
    "ApertureDiameter": { "Value": 60, "Units": "mm" },
    "MaxPeakNegativePressure": { "Value": 1.5, "Units": "MPa" },
    "MaxMechanicalIndex": { "Value": 1.1, "Units": "dimensionless" },
    "ContactMedium": "water bag",
    "NumberOfElements": 128,
    "ElementPitch": { "Value": 0.8, "Units": "mm" },
    "ArrayGeometry": "2D matrix"
  }
]
```

#### `StimulusSet`

`StimulusSet` defines a reusable library of ultrasound stimulus configurations referenced from `stim_id` in `*_nibs.tsv`.
It captures stimulus-level parameters that remain constant across stimulation events, while event-specific timing and intensity parameters (e.g., `base_stimulus_intensity`, `base_pulse_intensity`) are stored in `*_nibs.tsv`.

* Each entry in `StimulusSet` is an object with the following fields:

| Field | Type | Description |
|---|---:|---|
| `StimID` | string | Unique identifier for the stimulus configuration, referenced from `stim_id` in `*_nibs.tsv`. |
| `StimulusType` | string | Type of TUS stimulation protocol (e.g., `continuous`, `pulsed`, `burst`). Determines which parameter groups below are applicable. |


##### `StimulusType = continuous`

| Field | Type | Description |
|---|---:|---|
| `StimulusWaveform` | string | Waveform used for continuous ultrasound stimulation (e.g., `sine`, `square`, `custom`). |
| `StimulusFrequency` | object | Frequency of the continuous ultrasound stimulus. Structured as `{ "Value": <number>, "Units": <string> }`. |

##### `StimulusType = pulsed` or `burst`

| Field | Type | Description |
|---|---:|---|
| `PulseCount` | integer | Number of ultrasound pulses delivered within one stimulation instance. |
| `PulseWaveform` | string | Waveform used for individual ultrasound pulses (e.g., `sine`, `square`, `custom`). |
| `PulseDuration` | object | Duration of a single ultrasound pulse. Structured as `{ "Value": <number>, "Units": <string> }`. |
| `PulseRepetitionInterval` | object | Time interval between the start of consecutive pulses within a stimulation instance. Structured as `{ "Value": <number>, "Units": <string> }`. The duty cycle can be derived as `PulseDuration / PulseRepetitionInterval`. |
| `PulseRampShape` | string | Shape of the amplitude ramp applied to the beginning and end of each pulse (e.g., `linear`, `raised-cosine`, `tukey`, `custom`). Optional. |
| `PulseRiseTime` | object | Duration of the rising edge (amplitude ramp-up) of each pulse. Structured as `{ "Value": <number>, "Units": <string> }`. Optional. |
| `PulseFallTime` | object | Duration of the falling edge (amplitude ramp-down) of each pulse. Structured as `{ "Value": <number>, "Units": <string> }`. Optional. |
| `PulseIntensityScalingType` | string | Defines how pulse-specific intensities are derived from the base intensity specified in `*_nibs.tsv` (e.g., `multiplicative`, `additive`, `custom`). |
| `PulseIntensityScalingVector` | array | Multiplicative scaling factors applied to `base_pulse_intensity` for each pulse. The length of the vector MUST match `PulseCount`. For example `[1.0, 0.8, 0.6]`. Optional. |
| `PulseIntensityScalingReference` | string | Reference point for applying the scaling factors (e.g., `base_pulse_intensity`). Optional. |
| `PulseIntensityScalingDescription` | string | Free-text description of the scaling rule or pattern applied to pulse intensities. Optional. |

- PulseCount is defined at the stimulus-template level. If the number of pulses varies across events, define separate entries in StimulusSet (with different StimID) and reference them from *_nibs.tsv.

- When provided, PulseIntensityScalingVector MUST have length equal to PulseCount for the corresponding StimID.

- `PulseRampShape`, `PulseRiseTime`, and `PulseFallTime` describe amplitude shaping within an individual pulse, whereas `PulseIntensityScaling*` parameters describe relative intensity differences between pulses within the same stimulation instance.

##### Amplitude Modulation (optional)

These parameters define amplitude modulation of the ultrasound stimulus envelope (e.g., AM-tFUS protocols).  
Amplitude modulation scales the instantaneous amplitude of the carrier signal over time according to a modulation function:

`amplitude(t) = base_stimulus_intensity × modulation(t)`

where `base_stimulus_intensity` is defined per event in `*_nibs.tsv`.

| Field | Type | Description |
|---|---:|---|
| `ModulationFrequency` | object | Frequency of the amplitude modulation envelope. Structured as `{ "Value": <number>, "Units": <string> }`. Optional. |
| `ModulationWaveform` | string | Waveform of the amplitude modulation envelope (e.g., `sine`, `square`, `custom`). Optional. |
| `ModulationDepth` | number | Depth of amplitude modulation expressed as a fraction of the base intensity (e.g., `0.5` means ±50% modulation). Optional. |

* The modulation envelope is applied to the base_stimulus_intensity defined in *_nibs.tsv.

##### Phased-array beamforming (optional)

| Field | Type | Description |
|---|---:|---|
| `BeamformingMode` | string | Beamforming strategy used when a phased-array transducer is employed (e.g., `none`, `fixed`, `dynamic`). Optional and primarily relevant when the selected transducer in `TransducerSet` has `TransducerType = phased-array`. |
| `FocusTrajectory` | string | Spatial trajectory followed by the acoustic focus during the stimulation instance (e.g., `static`, `linear`, `circular`, `raster`, `custom`). |
| `FocusUpdateRate` | object | Rate at which the acoustic focus position is updated during stimulation when beam steering is used. Structured as `{ "Value": <number>, "Units": <string> }`. |
| `FocusSequence` | array | Defines the ordered sequence of target_id values (as defined in `*_markers.tsv`) to be stimulated sequentially. |

- If FocusSequence is not provided, the stimulation target is assumed to correspond to the target_id specified in *_nibs.tsv.

- `Focus*` parameters are typically relevant only when `BeamformingMode` = dynamic.


#### `StimulusSet` description:

```
 "StimulusSet": [
    {
      "StimID": "stim_01",
      "StimulusType": "continuous",
      "StimulusWaveform": "sine",
      "StimulusFrequency": {
        "Value": 500,
        "Units": "kHz"
      }
    },
    {
      "StimID": "stim_02",
      "StimulusType": "pulsed",
      "PulseCount": 5,
      "PulseWaveform": "sine",
      "PulseDuration": {
        "Value": 200,
        "Units": "us"
      },
      "PulseRepetitionInterval": {
        "Value": 1,
        "Units": "ms"
      },
      "PulseRampShape": "raised-cosine",
      "PulseRiseTime": {
        "Value": 20,
        "Units": "us"
      },
      "PulseFallTime": {
        "Value": 20,
        "Units": "us"
      },
      "PulseIntensityScalingType": "multiplicative",
      "PulseIntensityScalingVector": [1.0, 0.8, 0.8, 0.6, 0.6],
      "PulseIntensityScalingReference": "base_pulse_intensity",
      "PulseIntensityScalingDescription": "Gradual reduction of pulse intensity across the pulse train."
    },
    {
      "StimID": "stim_03",
      "StimulusType": "continuous",
      "StimulusWaveform": "sine",
      "StimulusFrequency": {
        "Value": 500,
        "Units": "kHz"
      },
      "ModulationFrequency": {
        "Value": 10,
        "Units": "Hz"
      },
      "ModulationWaveform": "sine",
      "ModulationDepth": 0.5
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


**  A complete example is included in Appendix A.

### 1.3 `*_nibs.tsv` — Stimulation Parameters

The `*_nibs.tsv` file stores event-level (instance-level) stimulation parameters for NIBS experiments.
Each row represents a stimulation instance and links the delivered stimulation to (i) a reusable stimulus template defined in `*_nibs.json` (`stim_id` → `StimulusSet.StimID`), (ii) hardware components (e.g., `transducer_id` → `TransducerSet.TransducerID`), and (iii) a stimulation target (`target_id` → `*_markers.tsv`).
Unlike `StimulusSet`, which captures template-level structure, `*_nibs.tsv` captures parameters that can vary across instances (e.g., timing at the event level and base intensity values).

**Stimulator Device & Configurations**

| Field | Type | Description | 
|------|------|-------------|
| `transducer_id` | string | Identifier of the ultrasound transducer used in this stimulation instance. References `TransducerSet.TransducerID` in `*_nibs.json`. | 
| `transducer_positioning_method` | string | Method used to position the ultrasound transducer relative to the target (e.g., MRI-guided neuronavigation, robotic positioning, stereotactic frame, freehand placement). | 


**Non-navigated transducer placement/orientation (optional)**

| Field | Type | Description |
|------|------|-------------|
| `transducer_positioning_method` | string | Description of the anatomical placement of the transducer relative to the head (e.g., left temporal region, right motor cortex approximation, midline frontal). | 
| `transducer_placement_description` | string | Free-text description of transducer placement (e.g., anatomical reference points used, placement rationale, and any deviations from the intended target). |
| `transducer_orientation` | string | Description of the orientation of the transducer relative to the head or skull surface (e.g., perpendicular to skull surface, angled anteriorly). | 

**Protocol / Event Metadata**

| Field | Type | Description |
|------|------|-------------|
| `event_id` | string | Identifier linking the stimulation instance to a corresponding entry in `_events.tsv`. |
| `event_part` | integer | (Optional) Index of a row/segment within a logical stimulation event (`event_id`) when multiple rows are required to represent one event (e.g., multi-contact TES, multi-component stimulation, or segmented configurations). Values SHOULD start at 1 and increment monotonically (1..N) within each `event_id`. When present, `event_part` MUST be unique within the same `event_id`. |
| `event_name` | string | Name of the stimulation event or protocol condition (e.g., sham, active, baseline stimulation). |

**Stimulation Configuration Reference**

| Field | Type | Description |
|------|------|-------------|
| `stim_id` | string | Identifier of the stimulation configuration used for this instance. References `StimulusSet.StimID` in `*_nibs.json`. |

**Stimulation Timing Parameters** 

| Field | Type | Description |
|---|---:|---|
| `stimulation_duration` | number | (Optional) Total wall-clock duration of the stimulation block. **Includes** `ramp_up_duration` and `ramp_down_duration` phases if present. |
| `ramp_up_duration` | number | (Optional) Duration of the amplitude ramp-up phase at the beginning of the stimulation block. This duration is a subcomponent of `stimulation_duration` when both are provided. |
| `ramp_down_duration` | number | (Optional) Duration of the amplitude ramp-down phase at the end of the stimulation block. This duration is a subcomponent of `stimulation_duration` when both are provided. |
| `repeat_duration` | number | (Optional) Active duration of one stimulation window (repeat unit), from onset to end (excludes any post-window gap). |
| `repeat_count` | number | (Optional) Number of repeated stimulation windows delivered within the block (count). |
| `repeat_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive stimulation windows (repeat units) within the block. |
| `train_duration` | number | (Optional) Active duration of a train, from the onset of the first element in the train to the end of the last element in the train (onset-to-offset) (i.e., excludes any post-train gap). |
| `train_count` | number | (Optional) Number of stimulation instances delivered within one train (count). |
| `train_repetition_interval` | number | (Optional) Onset-to-onset interval between consecutive stimulation instances within a train. |
| `train_ramp_up` | number | (Optional) Gradual increase of stimulation amplitude applied across successive trains at the beginning of a stimulation block. |
| `train_ramp_up_count` | number | (Optional) Number of initial trains over which the ramp-up is applied. |
| `train_ramp_down` | number | (Optional) Gradual decrease of stimulation amplitude applied across successive trains at the end of a stimulation block. |
| `train_ramp_down_count` | number | (Optional) Number of final trains over which the ramp-down is applied. |

**Spatial & Targeting Information**

| Field | Type | Description |
|---|---:|---|
| `target_id` | string | Identifier of a spatial stimulation target (stimulation-level target identifier). Links `*_nibs.tsv` to spatial target definitions in `*_markers.tsv`. |

**Amplitude & Thresholds**

For continuous stimulation protocols (including amplitude-modulated stimulation), the parameter `base_stimulus_intensity` is used.

For pulsed or burst stimulation protocols, the parameter `base_pulse_intensity` is used and may be further modified using pulse-specific scaling rules defined in `StimulusSet`.

| Field | Type | Description |
|------|------|-------------|
| `base_stimulus_intensity` | number | Base intensity level applied to the stimulation instance for continuous stimulation protocols. In amplitude-modulated stimulation, this value represents the base intensity that is modulated according to the `Modulation*` parameters defined in `StimulusSet`. |
| `base_pulse_intensity` | number | Base intensity level applied to individual pulses in pulsed or burst stimulation protocols. Pulse-specific intensities may be derived from this value using the `PulseIntensityScaling*` parameters defined in `StimulusSet`. |

* Only one of `base_stimulus_intensity` or `base_pulse_intensity` SHOULD be provided for a given row in `*_nibs.tsv`.

| Field | Type | Description |
|------|------|-------------|
| `threshold_type` | string | (Optional) Type of threshold used to determine or justify the selected stimulation intensity (e.g., perceptual threshold, safety limit, protocol-defined threshold, custom). |
| `threshold_intensity` | number | (Optional) Threshold intensity value associated with `threshold_type`, reported in the same units/scale as the corresponding base intensity field used in the row (i.e., `base_stimulus_intensity` or `base_pulse_intensity`). |

* When provided, `threshold_intensity` SHOULD be expressed in the same scale as the base intensity used in the row (either `base_stimulus_intensity` or `base_pulse_intensity`).

**Derived / Device-Generated Parameters**

This section contains parameters that are not directly controlled by the experimenter but are measured, estimated, or computed by the stimulation device during or after stimulation delivery.  
These values are typically derived from internal device measurements, calibration models, or safety monitoring systems.

| Field | Type | Description |
|------|------|-------------|
| `stimulus_count` | integer | (Optional) Counter indicating the number of times a stimulation instance with the same `stim_id` has been delivered to the same `target_id` within the current file/session. Intended for counting deliveries to a target; MUST NOT be used for synchronization across modalities. Values typically start at 1 and increment monotonically for successive deliveries of the same (`stim_id`, `target_id`) combination. |
| `stimulus_validation` | string | (Optional) Free-form indication of whether stimulation delivery or positioning was verified during the experiment (e.g., `verified`, `observed`, `not_verified`, `unknown`). |
| `measured_peak_negative_pressure` | number | Estimated or measured peak negative acoustic pressure generated by the transducer during stimulation. |
| `spatial_peak_pulse_average_intensity` | number | Spatial-peak pulse-average acoustic intensity (ISPPA) estimated for the delivered stimulation. |
| `spatial_peak_temporal_average_intensity` | number | Spatial-peak temporal-average acoustic intensity (ISPTA) estimated for the delivered stimulation. |
| `mechanical_index` | number | Mechanical Index (MI) estimated for the delivered stimulation. Typically computed as peak negative pressure divided by the square root of the carrier frequency. |
| `thermal_index` | number | Thermal Index (TI) estimated for the delivered stimulation. |
| `subject_feedback` | string | (Optional) Participant-reported perception, discomfort, or other feedback related to stimulation. |
| `timestamp` | string | (Optional) Timestamp in ISO 8601 format indicating when the stimulation instance occurred or was logged by the system. |

- Units for numerical parameters SHOULD be defined in the corresponding *_nibs.json sidecar when applicable.

**  A complete example is included in Appendix A.


## Appendix A: Examples of “protocol recipes”:

### TMS section

#### Example 1 — Single-pulse TMS (manual or externally triggered)

* Conceptual meaning

A stimulation instance corresponds to the delivery of one single TMS pulse.  
Each delivered pulse is treated as an independent stimulation instance and is represented by one row in `*_nibs.tsv`.

* Stimulus layer (*_nibs.json → StimulusSet)

This example defines a single-pulse stimulation instance.

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "single",
    "PulseCount": 1,
    "PulseWaveform": "monophasic",
    "PulseDuration": 0.2,
    "PulseDurationUnits": "ms",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Defined according to manufacturer-specific coil orientation convention"
  }
]
```

* Interpretation

	- StimID defines the stimulation-instance structure referenced by stim_id.

	- The instance contains exactly one physical pulse (`PulseCount` = 1).

	- Pulse-level properties are fixed for this configuration and therefore belong in *_nibs.json.

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered single pulse.

```
event_id  stim_id  target_id  stimulus_count  base_pulse_intensity  threshold_type    threshold_reference_intensity  threshold_pulse_intensity  repeat_repetition_interval
event_1   stim_1   target_1   1           55                    resting_motor     50                             110                        5
event_2   stim_1   target_2   2           55                    resting_motor     50                             110                        5
event_3   stim_1   target_3   3           55                    resting_motor     50                             110                        5
```

* Timing note

	- If pulses are manually triggered or irregular, onsets SHOULD be recorded in *_events.tsv (linked via event_id), and repeat_repetition_interval MAY be omitted.

	- If pulses are delivered periodically and per-event time-locking is not required, repeat_repetition_interval MAY be used.

#### Example 2 — Paired-pulse TMS (e.g., SICI / ICF)

* Conceptual meaning

A stimulation instance corresponds to the delivery of one paired-pulse stimulation instance, consisting of two pulses delivered with a fixed onset-to-onset interval.  
Each paired-pulse delivery is treated as one stimulation instance and represented by one row in `*_nibs.tsv`.

* Stimulus layer (*_nibs.json → StimulusSet)

This example defines a paired-pulse stimulation instance.

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "paired",
    "PulseCount": 2,
    "PulseRepetitionInterval": 2,
    "PulseRepetitionIntervalUnits": "ms",
    "PulseWaveform": "biphasic",
    "PulseDuration": 0.2,
    "PulseDurationUnits": "ms",
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

	- `StimID` = stim_1 defines the stimulation-instance structure referenced by `stim_id`.

	- The instance contains two physical pulses (`PulseCount` = 2).

	- The within-instance pulse spacing is defined by `PulseRepetitionInterval` in `StimulusSet`.

	- Pulse-level properties are fixed for this configuration and belong in *_nibs.json.

	- Pulse-specific intensity rules are defined in `StimulusSet` via the scaling fields.

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered paired-pulse stimulation instance.

```
event_id  stim_id  target_id  stimulus_count  threshold_type    threshold_reference_intensity
event_1   stim_1   target_1   1           resting_motor     55                   
event_2   stim_1   target_2   2           resting_motor     55                             
event_3   stim_1   target_3   3           resting_motor     55                             
```

* Timing note

- The paired-pulse structure is fully defined by::

	- `PulseCount` = 2 (JSON)
	- `PulseRepetitionInterval` = 0.003 (JSON)

If paired-pulse instances are delivered irregularly or task-triggered, onsets SHOULD be recorded in *_events.tsv (linked via event_id).

#### Example 3 — Burst-based stimulation (e.g., TBS-like constructs)

* Conceptual meaning

A stimulation instance corresponds to the delivery of a train-based construct executed as a single initiated unit (one logical stimulation event).  
A train is composed of repeated stimulation instances defined by the configuration referenced by `stim_id`.  
A delivered train-based construct can be represented by one row in `*_nibs.tsv` (with its internal repetition described parametrically).

* Stimulus layer (*_nibs.json → StimulusSet)

This example defines a triple-pulse stimulation instance, which is repeated within trains.

```
"StimulusSet": [
  {
    "StimID": "stim_1",
    "StimulusType": "triple",
    "PulseCount": 3,
    "PulseWaveform": "biphasic",
    "PulseDuration": 0.2,
    "PulseDurationUnits": "ms",
	"PulseRepetitionInterval": 0.02,
    "PulseRepetitionIntervalUnits": "s",
  }
]
```

* Interpretation

	- `StimID` defines the stimulation-instance structure referenced by `stim_id` in *_nibs.tsv.

	- The train structure (burst repetition) is defined parametrically by:

		- train_count

		- train_repetition_interval and train_duration

	- If trains are repeated as a higher-level pattern, repetition MAY be encoded by:

		- repeat_count

		- repeat_repetition_interval

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered burst/train-based stimulation event described parametrically.

```
event_id  stim_id  target_id  stimulus_count  base_pulse_intensity  threshold_type    threshold_reference_intensity  threshold_pulse_intensity  train_count  train_repetition_interval  train_duratino	repeat_count	repeat_repetition_interval  repeat_duration
event_1   stim_1   target_1   1           55                   	resting_motor     50                             110                        10           0.2						0.06			20				10							2
```

* Timing note

- If trains are delivered irregularly or externally triggered, onsets SHOULD be recorded in *_events.tsv (linked via event_id).
- If the construct is executed as programmed and periodic, the train parameters above are sufficient to reconstruct the intended temporal pattern.


### TES section

#### Example 1 — Continuous tDCS stimulation

This example illustrates a simple continuous transcranial direct current stimulation (tDCS) protocol delivered using a two-electrode montage. A constant current is applied for a fixed duration with ramp-up and ramp-down phases at the beginning and end of stimulation.

The stimulation device uses a pair of saline-soaked sponge electrodes. The stimulation waveform is direct current and the stimulation protocol is defined once in the StimulusSet. The actual stimulation event references this protocol and specifies the intensity and timing parameters.

* Device layer (*_nibs.json → ElectrodeSet)

```
{
  "ElectrodeSet": [
    {
      "ElectrodeID": "elec_01",
	  "ElectrodeRole": "anode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "rectangle",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "saline sponge"
    },
	{
      "ElectrodeID": "elec_02",
	  "ElectrodeRole": "cathode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "rectangle",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "saline sponge"
    }
  ]
}
```

* Stimulus layer (*_nibs.json → StimulusSet)

```
{
  "StimulusSet": [
    {
      "StimID": "stim_01",
      "StimulusType": "tDCS",
      "StimulusControlMode": "current-controlled",
      "StimulusWaveform": "direct_current"
    }
  ]
}
```

* Event layer (*_nibs.tsv)
* The stimulation event references the electrode configuration and stimulus protocol and specifies the intensity and timing parameters.

```
event_id	event_part	electrode_id	stim_id	base_current_intensity	stimulation_duration	ramp_up_duration	ramp_down_duration	target_id
event_01	1			elec_01			stim_01	2.0						1200					30					30					target_01
event_01	2			elec_02			stim_01	2.0						1200					30					30					target_02
```

#### Example 2 — tACS (frequency-based stimulation)

This example illustrates transcranial alternating current stimulation (tACS) where a sinusoidal current is applied at a specific frequency.
Unlike tDCS, the stimulation waveform oscillates continuously and is defined by the waveform type and stimulus frequency in the StimulusSet.

The electrode configuration is defined in the device layer, while the stimulus protocol specifies the sinusoidal waveform and frequency. The stimulation event references this configuration and defines the stimulation intensity and duration.

* Device layer (*_nibs.json → ElectrodeSet)

```
{
  "ElectrodeSet": [
    {
      "ElectrodeID": "elec_01",
      "ElectrodeRole": "anode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "rectangle",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "saline_sponge"
    },
    {
      "ElectrodeID": "elec_02",
      "ElectrodeRole": "cathode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "rectangle",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "saline_sponge"
    }
  ]
}
```

* Stimulus layer (*_nibs.json → StimulusSet)

```
{
  "StimulusSet": [
    {
      "StimID": "stim_02",
      "StimulusType": "tACS",
      "StimulusControlMode": "current-controlled",
      "StimulusWaveform": "sine",
      "StimulusFrequency": 10
    }
  ]
}
```

* Event layer (*_nibs.tsv)
* The stimulation event references the electrode configuration and stimulus protocol and specifies the stimulation intensity and duration.

```
event_id	event_part	electrode_id	stim_id	base_current_intensity	stimulation_duration	target_id
event_02	1			elec_01			stim_02	1.5						900						target_01
event_02	2			elec_02			stim_02	1.5						900						target_02
```

#### Example 3 — tRNS (random noise stimulation)

This example illustrates transcranial random noise stimulation (tRNS), where the stimulation signal consists of randomly varying current amplitudes within a defined frequency band. Unlike tACS, the waveform is not periodic but stochastic.

The stimulation protocol defines the noise waveform and its frequency band in the StimulusSet. The stimulation event specifies the stimulation intensity and duration.

* Device layer (*_nibs.json → ElectrodeSet)

```
{
  "ElectrodeSet": [
    {
      "ElectrodeID": "elec_01",
      "ElectrodeRole": "anode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "rectangle",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "saline_sponge"
    },
    {
      "ElectrodeID": "elec_02",
      "ElectrodeRole": "cathode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "rectangle",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "saline_sponge"
    }
  ]
}
```

* Stimulus layer (*_nibs.json → StimulusSet)

```
{
  "StimulusSet": [
    {
      "StimID": "stim_03",
      "StimulusType": "tRNS",
      "StimulusControlMode": "current-controlled",
      "StimulusWaveform": "random_noise",
      "StimulusNoiseType": "band-limited",
      "NoiseFrequencyBand": { "Low": 100, "High": 640, "Units": "Hz" },
      "NoiseGenerationMethod": "device-native",
      "NoiseSampleDistribution": "gaussian",
      "NoiseUpdateRate": { "Value": 1000, "Units": "Hz" }
    }
  ]
}
```

* Event layer (*_nibs.tsv)
* The stimulation event references the electrode configuration and stimulus protocol and specifies the stimulation intensity and duration.

```
event_id	event_part	electrode_id	stim_id	base_current_intensity	stimulation_duration	target_id
event_03	1			elec_01			stim_03	1.0						1200					target_01
event_03	2			elec_02			stim_03	1.0						1200					target_02
```

#### Example 4 — HD-tDCS (4×1 montage: 1 anode + 4 returns)

* Device layer (*_nibs.json → ElectrodeSet)

```
{
  "ElectrodeSet": [
    {
      "ElectrodeID": "elec_01",
      "ElectrodeRole": "anode",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "circular",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "gel"
    },
    {
      "ElectrodeID": "elec_02",
      "ElectrodeRole": "return",
      "ElectrodeType": "rubber",
      "ElectrodeShape": "circular",
      "ElectrodeSize": { "Value": 35, "Units": "cm2" },
      "ElectrodeContactMedium": "gel"
    }
  ]
}
```

* Stimulus layer (*_nibs.json → StimulusSet)

```
{
  "StimulusSet": [
    {
      "StimID": "stim_01",
      "StimulusType": "tDCS",
      "StimulusControlMode": "current-controlled",
      "StimulusWaveform": "direct_current"
    }
  ]
}
```

* Event layer (*_nibs.tsv)
* The stimulation event references the electrode configuration and stimulus protocol and specifies the stimulation intensity and duration.

```
event_id	event_part	electrode_id	stim_id	base_current_intensity	stimulation_duration	ramp_up_duration	ramp_down_duration	target_id
event_01	1			elec_01			stim_01	2.0						1200					30					30					target_01
event_01	2			elec_02			stim_01	-0.5					1200					30					30					target_02
event_01	3			elec_02			stim_01	-0.5					1200					30					30					target_03
event_01	4			elec_02			stim_01	-0.5					1200					30					30					target_04
event_01	5			elec_02			stim_01	-0.5					1200					30					30					target_05
```

* Spatial layer (*_markers.tsv)

```
target_id	target_label	entry_x	entry_y	entry_z
target_01	...				...		...		...
target_02	...				...		...		...
target_03	...				...		...		...
target_04	...				...		...		...
target_05	...				...		...		...
```	

#### Example 5 — HD-tACS (4×1 montage: 1 anode + 4 returns)

* Device layer (*_nibs.json → ElectrodeSet)

```	
{
  "ElectrodeSet": [
    {
      "ElectrodeID": "elec_01",
      "ElectrodeRole": "anode",
      "ElectrodeShape": "circular",
      "ElectrodeArea": {
        "Value": 3.14,
        "Units": "cm^2"
      },
      "ElectrodeContactMedium": "gel"
    },
    {
      "ElectrodeID": "elec_02",
      "ElectrodeRole": "return",
      "ElectrodeShape": "circular",
      "ElectrodeArea": {
        "Value": 3.14,
        "Units": "cm^2"
      },
      "ElectrodeContactMedium": "gel"
    }
  ]
}
```	

* Stimulus layer (*_nibs.json → StimulusSet)

```	
{
  "StimulusSet": [
    {
      "StimID": "stim_01",
      "StimulusType": "tACS",
      "StimulusControlMode": "current-controlled",
      "StimulusWaveform": "sine",
      "StimulusFrequency": 10
    }
  ]
}
```	

* Spatial layer (*_markers.tsv) — separate target_id per contact

```	
target_id	target_label	entry_x	entry_y	entry_z
target_01	...				...		...		...
target_02	...				...		...		...
target_03	...				...		...		...
target_04	...				...		...		...
target_05	...				...		...		...
```		

* Event layer (*_nibs.tsv) — one event_id, 5 rows (per contact)

```
event_id	event_part	electrode_id	stim_id	base_current_intensity	stimulation_duration	target_id
event_01	1			elec_01			stim_01	1.0						900					target_01
event_01	2			elec_02			stim_01	-0.25					900					target_02
event_01	3			elec_02			stim_01	-0.25					900					target_03
event_01	4			elec_02			stim_01	-0.25					900					target_04
event_01	5			elec_02			stim_01	-0.25					900					target_05
```