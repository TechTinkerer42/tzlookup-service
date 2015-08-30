# benchmarks

As an imaginary target performance, we assume an SLA of *50ms* on the *95percentile*. The amount of concurrent connections is to be determined during the benchmarks.

## Tooling
Benchmarks are done with [vegeta](https://github.com/tsenart/vegeta)

	$ brew install vegeta

### Run a test against localhost (start service in another window)

	$ vegeta attack -targets=targets_localhost.txt -duration=30m -rate=200 | vegeta report


### Run a test against a remote server

	$ vegeta attack -targets=targets.txt -duration=30m -rate=200 | vegeta report

## Results of benchmarks between 2 digitialocean nodes (same datacenter)

Service hosted on 10$/month [digitalocean](https://www.digitalocean.com/) vm (1 cpu, 1gb memory), being tested from another node within the same datacenter.

### @200tps for 30m

The service is able to sustain the required SLA of *50ms* here. The network seens to add almost no overhead, since it is within the same datacenter.

```
Requests        [total, rate]                   360000, 200.00
Duration        [total, attack, wait]           29m59.999103648s, 29m59.994999694s, 4.103954ms
Latencies       [mean, 50, 95, 99, max]         4.824762ms, 3.554667ms, 10.622074ms, 20.982116ms, 1.072776739s
Bytes In        [total, mean]                   11970000, 33.25
Bytes Out       [total, mean]                   0, 0.00
Success         [ratio]                         100.00%
Status Codes    [code:count]                    200:360000
Error Set:

Bucket         #       %       Histogram
[0,     1ms]   0       0.00%
[1ms,   2ms]   12855   3.57%   ##
[2ms,   3ms]   114342  31.76%  #######################
[3ms,   4ms]   94092   26.14%  ###################
[4ms,   5ms]   67539   18.76%  ##############
[5ms,   6ms]   32967   9.16%   ######
[6ms,   7ms]   4469    1.24%
[7ms,   8ms]   1592    0.44%
[8ms,   9ms]   3717    1.03%
[9ms,   10ms]  6469    1.80%   #
[10ms,  15ms]  12155   3.38%   ##
[15ms,  20ms]  5407    1.50%   #
[20ms,  25ms]  2044    0.57%
[25ms,  30ms]  740     0.21%
[30ms,  35ms]  320     0.09%
[35ms,  40ms]  217     0.06%
[40ms,  45ms]  206     0.06%
[45ms,  50ms]  192     0.05%
[50ms,  +Inf]  677     0.19%
```
### @300tps for 30m

At 300tps a noticable increase in response times can be seen. The service is till within it's SLA of *50ms* for the *95percentile*, not for the *99percentile* anymore though.

```
equests        [total, rate]                   540000, 300.00
Duration        [total, attack, wait]           30m0.003377175s, 29m59.996486317s, 6.890858ms
Latencies       [mean, 50, 95, 99, max]         9.326914ms, 4.243023ms, 28.569724ms, 73.817023ms, 610.634306ms
Bytes In        [total, mean]                   17955000, 33.25
Bytes Out       [total, mean]                   0, 0.00
Success         [ratio]                         100.00%
Status Codes    [code:count]                    200:540000
Error Set:

[0,     1ms]   0       0.00%
[1ms,   2ms]   19716   3.65%   ##
[2ms,   3ms]   116033  21.49%  ################
[3ms,   4ms]   118838  22.01%  ################
[4ms,   5ms]   40998   7.59%   #####
[5ms,   6ms]   20367   3.77%   ##
[6ms,   7ms]   36312   6.72%   #####
[7ms,   8ms]   27612   5.11%   ###
[8ms,   9ms]   9010    1.67%   #
[9ms,   10ms]  12498   2.31%   #
[10ms,  15ms]  54821   10.15%  #######
[15ms,  20ms]  31753   5.88%   ####
[20ms,  25ms]  18094   3.35%   ##
[25ms,  30ms]  8910    1.65%   #
[30ms,  35ms]  5794    1.07%
[35ms,  40ms]  3655    0.68%
[40ms,  45ms]  2654    0.49%
[45ms,  50ms]  2008    0.37%
[50ms,  +Inf]  10927   2.02%   #
```

## Results of benchmarks between 2 digitialocean nodes (SFO -> NYC)

This test shows the impact of network latency on a service's perceived performance. An ICMP ping alone is already breaking the SLA:

    $ ping 104.236.236.214
    PING 104.236.236.214 (104.236.236.214) 56(84) bytes of data.
    64 bytes from 104.236.236.214: icmp_seq=1 ttl=53 time=74.3 ms
    64 bytes from 104.236.236.214: icmp_seq=2 ttl=53 time=74.2 ms
    64 bytes from 104.236.236.214: icmp_seq=3 ttl=53 time=74.1 ms
    64 bytes from 104.236.236.214: icmp_seq=4 ttl=53 time=74.3 ms
    64 bytes from 104.236.236.214: icmp_seq=5 ttl=53 time=74.2 ms
    64 bytes from 104.236.236.214: icmp_seq=6 ttl=53 time=74.1 ms
    64 bytes from 104.236.236.214: icmp_seq=7 ttl=53 time=74.2 ms

So it can not be expected that the service will uphold the old SLA of *50ms*. We will be using *100ms* as our new SLA on the 95percentile here.

### @200tps for 30m

The text confirms the expectation: the service can not achieve better results than a plain ping, but it also did *not* uphold the new SLA (off by 3ms). It is possible the service might have managed the SLA under a less taxing load.

```
Requests        [total, rate]                   360000, 200.00
Duration        [total, attack, wait]           30m0.084189652s, 29m59.994999791s, 89.189861ms
Latencies       [mean, 50, 95, 99, max]         89.231749ms, 87.714309ms, 103.520203ms, 119.969297ms, 486.252029ms
Bytes In        [total, mean]                   11970000, 33.25
Bytes Out       [total, mean]                   0, 0.00
Success         [ratio]                         100.00%
Status Codes    [code:count]                    200:360000
Error Set:

Bucket           #       %       Histogram
[50ms,   55ms]   0       0.00%
[55ms,   60ms]   0       0.00%
[60ms,   65ms]   0       0.00%
[65ms,   70ms]   0       0.00%
[70ms,   75ms]   1221    0.34%
[75ms,   80ms]   28344   7.87%   #####
[80ms,   85ms]   112824  31.34%  #######################
[85ms,   90ms]   68015   18.89%  ##############
[90ms,   95ms]   81034   22.51%  ################
[95ms,   100ms]  34968   9.71%   #######
[100ms,  105ms]  19596   5.44%   ####
[105ms,  110ms]  6745    1.87%   #
[110ms,  115ms]  2415    0.67%
[115ms,  120ms]  1244    0.35%
[120ms,  +Inf]   3594    1.00%
```

### @150tps for 30m

This test shows that with a lower tps the service manages to (barely) reach the targeted SLA.

```
Requests        [total, rate]                   270000, 150.00
Duration        [total, attack, wait]           30m0.090786542s, 29m59.993153125s, 97.633417ms
Latencies       [mean, 50, 95, 99, max]         88.560362ms, 89.042294ms, 100.762409ms, 108.184683ms, 379.913417ms
Bytes In        [total, mean]                   8977508, 33.25
Bytes Out       [total, mean]                   0, 0.00
Success         [ratio]                         100.00%
Status Codes    [code:count]                    200:270000
Error Set:

Bucket           #      %       Histogram
[50ms,   55ms]   0      0.00%
[55ms,   60ms]   0      0.00%
[60ms,   65ms]   0      0.00%
[65ms,   70ms]   0      0.00%
[70ms,   75ms]   1761   0.65%
[75ms,   80ms]   18417  6.82%   #####
[80ms,   85ms]   76396  28.29%  #####################
[85ms,   90ms]   55125  20.42%  ###############
[90ms,   95ms]   85753  31.76%  #######################
[95ms,   100ms]  17161  6.36%   ####
[100ms,  105ms]  9905   3.67%   ##
[105ms,  110ms]  3368   1.25%
[110ms,  115ms]  927    0.34%
[115ms,  120ms]  375    0.14%
[120ms,  +Inf]   812    0.30%
```
