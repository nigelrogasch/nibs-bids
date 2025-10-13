# Framework for describing TMS intervention parameters

The current methods for describing the timing of TMS interventions are often imprecise and ambiguous, meaning there are often multiple different interpretations of how the timing could be implemented.

Below I describe a method for accurately describing the timing of common rTMS paradigms. 6 parameters are defined which allows 3 nested timings (bursts, trains, protocol). Nested timings refer to grouping of pulses. This allows the description of protocols with 3 levels of nesting (e.g., iTBS: 50 Hz burst repeated at 5 Hz train repeated at 10 s intervals over protocol), 2 levels of nesting (e.g., cTBS, 10 Hz rTMS, QPS, iTMS) and 1 level of nesting (e.g., 1 Hz rTMS). 

Importantly, only intervals (in seconds) and number of pulses  are described, which prevents ambiguity from describing combinations of frequency of stimulation and duration of stimulation.

* `inter-pulse-interval` = time in seconds between the first pulse and subsequent pulse.
* `pulses-in-burst` = first level of nesting - describes the number of pulses in a burst.
* `inter-burst-interval` = time in seconds between first pulse in first burst and first pulse in subsequent burst.
* `bursts-in-train` = second level of nesting - describes the number of bursts in a train.
* `inter-train-interval` = time in seconds between first pulse in first train and first pulse in subsequent train.
* `trains-in-protocol` = third level of nesting - describes the number of trains in a protocol.

*Note:* I've used the term `interval` above, but perhaps `period` might be more appropriate as it describes the time taken to complete a full cycle including stimuli and gaps.

From these parameters, two additional features can be calculated:
* Total pulses = total number of pulses in protocol
* Total duration = time in seconds from first pulse to end of cycle (I think it is better to calculate total period - i.e., the time taken to complete all cycles - it's easier to calculate and is perhaps more intuitive).

Here are the settings for some common protocols.

| **Protocol** | **pulses-in-burst**      | **inter-pulse-interval** | **bursts-in-train** | **inter-burst-interval** | **trains-in-protocol** | **inter-train-interval** |
|--------------|--------------------------|---------------------|--------------------------|---------------------|--------------------------|------------------------|
| iTBS         | 3                        | 0.02                | 10                       |0.2                  |20                        | 10                     |
| cTBS         | 3                        | 0.02                | 200                      |0.2                  |1                         | 0                      |
| 10 Hz        | 40                       | 0.1                 | 75                       |30                   |1                         | 0                      |
| 1 Hz         | 600                      | 1                   | 1                        |0                    |1                         | 0                      |
| QPS          | 4                        | 0.005               | 360                      |5                    |1                         | 0                      |
| iTMS         | 2                        | 0.0015              | 180                      |5                    |1                         | 0                      |

I've written a basic script `tms_intervention_builder.m` to show how these settings can build the protocols and calculate total pulses and total duration.

## Text description of TMS intervention parameters

I've given some examples of writing these protocols out in text form. Note that other descriptors like frequency can be described, however the 6 descriptors are required and take precedence. If a descriptor is not described it is automatically condsidered to = 1 (for no-repeats) or 0 (for interval). 

*iTBS:*  
iTBS consisted of 3 pulses at 50 Hz (inter-pulse-interval = 0.02 s; pulses-in-burst = 3) repeated at 5 Hz (inter-burst-interval = 0.2 s; bursts-in-train = 10) for 2 seconds with an 8 seconds gap (inter-train-interval = 10 s; trains-in-protocol = 20) for a total of 600 pulses over 200 seconds. 

*cTBS:*  
cTBS iTBS consisted of 3 pulses at 50 Hz (inter-pulse-interval = 0.02 s; pulses-in-burst = 3) repeated at 5 Hz (inter-burst-interval = 0.2 s; bursts-in-train = 200) for a total of 600 pulses over 40 seconds.

*10 Hz rTMS:*  
rTMS was given at 10 Hz for 4 s (inter-pulse-interval = 0.1 s; pulses-in-burst = 40) followed by a 26 s gap (inter-burst-interval = 30; burst-in-train = 75) for a total of 3000 pulses over 37 mins and 30 seconds.

*1 Hz rTMS:*  
rTMS was given at 1 Hz for 10 minutes (inter-pulse-interval = 1; pulses-in-burst = 600).
