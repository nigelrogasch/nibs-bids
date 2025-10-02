# Framework for describing TMS intervention parameters

The current methods for describing the timing of TMS interventions are often imprecise and ambiguous, meaning there are often multiple different interpretations of how the timing could be implemented.

Below I describe a method for accurately describing the timing of common rTMS paradigms. 6 parameters are defined which allows 3 nested timings (bursts, trains, protocol). Nested timings refer to grouping of pulses. This allows the description of protocols with 3 levels of nesting (e.g., iTBS: 50 Hz burst repeated at 5 Hz train repeated at 10 s intervals over protocol), 2 levels of nesting (e.g., cTBS, 10 Hz rTMS, QPS, iTMS) and 1 level of nesting (e.g., 1 Hz rTMS). 

Importantly, only intervals (in seconds) and number of pulses  are described, which prevents ambiguity from describing combinations of frequency of stimulation and duration of stimulation.

* `inter_pulse_interval` = time in seconds between the first pulse and subsequent pulse.
* `pulses_in_burst` = first level of nesting - describes the number of pulses in a burst.
* `inter_burst_interval` = time in seconds between first pulse in first burst and first pulse in subsequent burst.
* `bursts_in_train` = second level of nesting - describes the number of bursts in a train.
* `inter_train_interval` = time in seconds between first pulse in first train and first pulse in subsequent train.
* `trains_in_protocol` = third level of nesting - describes the number of trains in a protocol.

From these parameters, two additional features can be calculated:
* Total pulses = total number of pulses in protocol
* Total duration = time in seconds from first pulse to last pulse of protocol.

Here are the settings for some common protocols.

| **Protocol** | **inter_pulse_interval** | **pulses_in_burst** | **inter_burst_interval** | **bursts_in_train** | **inter_train_interval** | **trains_in_protocol** |
|--------------|--------------------------|---------------------|--------------------------|---------------------|--------------------------|------------------------|
| iTBS         | 3                        | 0.02                | 10                       |0.2                  |20                        | 10                     |
| cTBS         | 3                        | 0.02                | 200                      |0.2                  |1                         | 0                      |
| 10 Hz        | 40                       | 0.1                 | 75                       |30                   |1                         | 0                      |
| 1 Hz         | 600                      | 1                   | 1                        |0                    |1                         | 0                      |
| QPS          | 4                        | 0.005               | 360                      |5                    |1                         | 0                      |
| iTMS         | 2                        | 0.0015              | 180                      |5                    |1                         | 0                      |

I've written a basic script `tms_intervention_builder.m` to show how these settings can build the protocols and calculate total pulses and total duration.
