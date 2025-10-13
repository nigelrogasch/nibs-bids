# NIBS-BIDS proposal v5+ (Scalable Structure for Non-Invasive Brain Stimulation)

This document presents a concise overview of our proposed scalable structure for organizing **non-invasive brain stimulation (NIBS)** data in BIDS. It is designed to precede and accompany real-life examples and comparative demonstrations.
The structure does not imply the separation of data depending on the experimental conditions (online, offline), but offers structured storage of data in a single directory in both conditions.
## 1. NIBS as a Dedicated `datatype`

* All data related to non-invasive brain stimulation is stored under a dedicated `nibs/` folder.
* This folder is treated as a standalone BIDS `datatype`, similar in role to `eeg/`, `pet/`, or `motion/`.
* This design allows coherent grouping of stimulation parameters, spatial data, and metadata.
** The structure can equally be defined as a datatype similar to the physio/ section.
 
## 2. Supported Stimulation Modalities

* The structure supports multiple types of NIBS techniques:

  * Transcranial Magnetic Stimulation (**TMS**)
  * Transcranial Electrical Stimulation (**tES**, e.g., tDCS, tACS)
  * Transcranial Ultrasound Stimulation (**TUS**)
* At this stage, the file templates and parameters are modeled based on **TMS**, while allowing future extensibility to other modalities.

## 3. Modality-Specific Suffix via `stimsys`

* To distinguish between different stimulation systems, we introduce the suffix `stimsys`, analogous to `tracksys` in the `motion/` datatype.
* The `stimsys` suffix can take values like `tms`, `tes`, or `tus`.

## 4. Synchronizing NIBS Data Across Modalities (*_events.tsv)

### Core Idea 

Every stimulation event recorded in `*_nibs.tsv` and spatially described in `*_markers.tsv` can be **referenced from other modalities** (e.g., `eeg/`, `nirs/`, `beh/`) using the following fields:

| Column Name      | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `StimStepCount`  | Corresponds to the unique stimulation row in `*_nibs.tsv`                   |
| `MarkerID`       | One or more marker IDs from `*_markers.tsv` & `*_nibs.tsv` used in the event|

### Modality-Specific Considerations

| Modality | MarkerID Usage                                   	 | Example Format            |
|----------|-----------------------------------------------------|---------------------------|
| `TMS`    | Typically **one marker** per stimulation            | `marker1.1`               |
| `tES`    | **Multiple electrodes** involved in one stimulation | `marker2.1; marker2.2`    |
| `TUS`    | **Single target**, **multiple entry points**        | `marker3.1; marker3.2`    |

- MarkerIDs can be **semicolon-separated** to indicate multi-point involvement.
- This preserves **readability** and avoids complex hierarchical structures.

``` events.tsv
onset	duration	trial_type	StimStepCount	MarkerID
12.500	0.001	    stim_tms	1	            marker1.1
17.300	0.001	    stim_tes	2	            marker2.1; marker2.2
23.700	0.001	    stim_tus	3	            marker3.1; marker3.2; marker3.3
```

## 5. Scalable File Naming Convention

The following files are used to organize stimulation-related data:

* `sub-01_stimsys-tms_task-<taskname>_nibs.tsv`
* `sub-01_stimsys-tms_task-<taskname>_nibs.json`

  * Contains stimulation protocol and pulse parameters + metadata.
  * Equivalent to the former `*_tms.tsv`.

* `sub-01_stimsys-tms_task-<taskname>_markers.tsv`
* `sub-01_stimsys-tms_task-<taskname>_markers.json`

  * Contains 3D coordinates of stimulation points, coil orientation, and electric field vectors + metadata.
  * Equivalent to the former `*_markers.tsv`.

* `sub-01_stimsys-tms_coordsystem.json`

  * Describes the coordinate system used in the stimulation session.
  * Equivalent to the former `*_coordsystem.json`.

## 6. Design Philosophy

* The structure is **modular**, **scalable**, and follows the BIDS principle of one `datatype` per modality.
* It avoids semantic overload and ambiguity by isolating stimulation metadata from behavioral, electrophysiological, and physiological datatypes.
* It enables consistent data discovery and analysis, even in complex multi-modal experiments.

Further elaboration and demonstration of these principles are provided in the accompanying example datasets and comparative analysis.
