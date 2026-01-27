## --------------- 22.12.2025  ---------------

1. *rel-<label>* — Relationship to Data Acquisition -> README.md
2. `HeadMeasurements`, `HeadMeasurementsUnits`, `HeadMeasurementsDescription` - *_coordsystem.json -> README.md 
3. `pulse_width` - _nibs.tsv -> README.md 
4. `burst_duration` - _nibs.tsv -> DELETED
5. `train_pulses` -> `train_bursts_number`
6. `train_duration` - _nibs.tsv -> DELETED
7. `repetition_rate` -> `train_burst_rate`
8. `inter_train_interval` -> `inter_train_pulse_interval`
9. `ramp_up_duration` -> DELETED
10. `ramp_down_duration` -> DELETED
11. `stimulus_pulses_number` -> Added
12. `stim_id` -> `target_id`
13. `stim_id` -> NEW
14. `StimulationSystemName` -> `StimulationSystemType`
15. `StimulusSet` -> _nibs.json
16.`tms_stim_mode` -> `StimulusSet` -> _nibs.json
17. current_direction -> PulseCurrentDirection -> `StimulusSet` -> _nibs.json
18. `waveform` -> `StimulusSet` -> _nibs.json
19. `pulse_width` -> `StimulusSet` -> _nibs.json

## Update_270126 --------------- 27.01.2026  ---------------

1. `coil_handle_direction` moved from nibs.tsv to markers.tsv
2. Updated: `target_id`, `target_part`, `event_id`, `event_part`
3. `StimulationSystemType` -> `StimulationSystem`
4. `targeting_method` -> `coil_positioning_method`
5. `NavigationSystem` (new) 
6. `stimulus_pulse_interval` -> `IntraPulseInterval` (StimulusSet)