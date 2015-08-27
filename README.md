# tzlookup service

##


## Next steps

{} ~~tune postgresql~~ (applied https://github.com/gregs1104/pgtune)~~
* tune amount of puma threads/processes
* tune sequel connection pool


## Benchmark (between 2 digitialocean nodes)

Service hosted on 10$/month digitialocean machine (1cpu)

### 300tps
```
Requests	[total, rate]			4190869, 299.97
Duration	[total, attack, wait]		3h52m51.16106085s, 3h52m51.06293717s, 98.12368ms
Latencies	[mean, 50, 95, 99, max]		3.483116ms, 2.743673ms, 4.200926ms, 20.459332ms, 3.332649904s
Bytes In	[total, mean]			121535201, 29.00
Bytes Out	[total, mean]			0, 0.00
Success		[ratio]				100.00%
Status Codes	[code:count]			200:4190869
Error Set:

Bucket         #        %       Histogram
[0,     1ms]   0        0.00%
[1ms,   2ms]   8789     0.21%
[2ms,   3ms]   2794841  66.69%  ##################################################
[3ms,   4ms]   1103348  26.33%  ###################
[4ms,   5ms]   126522   3.02%   ##
[5ms,   6ms]   12151    0.29%
[6ms,   7ms]   22162    0.53%
[7ms,   8ms]   20701    0.49%
[8ms,   9ms]   4899     0.12%
[9ms,   10ms]  5626     0.13%
[10ms,  15ms]  24771    0.59%
[15ms,  20ms]  23022    0.55%
[20ms,  +Inf]  44037    1.05%
```
