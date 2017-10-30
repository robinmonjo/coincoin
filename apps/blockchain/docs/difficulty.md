# Coincoin difficulty

Difficulty is a concept that relates to proof-of-work. It basically set the time that is required to perform a proof-of-work, and hence, set the **pace at which blocks are added to the blockchain**.

## Proof-of-work

In the Bitcoin protocol proof-of-work is simple to understand: https://en.bitcoin.it/wiki/Proof_of_work#Example

`coincoin` proof-of-work works almost the same way: given some data (usually a block header), the goal is to find a `sha256` hash that is **below** a given **target**. The `sha256` is modified by a **nounce** everytime until a valid `sha256` hash is found.

## What are the chances ?

When talking about proof-of-work in the blockchain area, we always talk about the *number of leading zeros in the block hash*. This is confusing and not totally right.

In order to simplify, imagine a `sha8` algorithm that hash data into 8 bits (and not 256 as `sha256`). If we set our target to:

`0111 1111` : we have `1/2` chance that `sha8` outputs a 0 on the first bit (it's either 0 or 1)

For at least 2 leading 0s:

`0011 1111` : we have `1/2 x 1/2 = 1/4` chance that the first and second bits will be 0

If we go on:

`0001 1111` : `1/2 x 1/2 x 1/2 = 1/8`

...

`0000 0000` : `1/2^8 = 0.00390625`

Same thing using **base 16** (hexadelcimal numbers go from 0 to F):

`0111 1111` = `7F` : we have `8/16 = 1/2` chance that `sha8` outputs a number lower than or equal 7

`0011 1111` = `3F` : we have `4/16 = 1/4` chance that `sha8` outputs a number lower than or equal 3

...

`0000 0000` = `00` : we have `1/16 x 1/16 = 0.00390625` that both numbers are 0

And of course, same thing in **base 10** (8 bits can store decimal numbers from 0 to 255):

`7F` = `127` : we have `128/256 = 1/2` chance that `sha8` outputs a number lower than or equal 127

`3F` = `63` : we have `64/256 = 1/4` chance that `sha8` outputs a number lower than or equal 63

...

`00` = `0` : we have `1/256 = 0.00390625` chance that it outputs 0

**Conclusion**

Leadings zeros do affect the time required to compute a proof-of-work because they reduce the **target**. Adding a leading zero divide the target by two. However, a target is **just a number** stored on 256 bits.

## Finding a target

### Hash Rate

The hash rate is the number of hashes a piece of hardware can compute per seconds. Knowing this and the fact that we can calculate the probability of finding a hash that's below a given target, we can estimate the time of a proof-of-work.

`coincoin` provides you with a tool for that:

```elixir
Blockchain.Difficulty.benchmark # this may take some times
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
| :target         | :probab                 | :estimated_trials     | :nounce        | :estimated_time      | :time         | :hashrate              |
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
| "2^252.0"       | 0.0625                  | 16.0                  | 13             | "n/a"                | 0.0           | "n/a"                  |
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
| "2^248.0"       | 0.00390625              | 256.0                 | 33             | "n/a"                | 0.001         | "n/a"                  |
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
| "2^240.0"       | 1.52587890625e-5        | 65536.0               | 238476         | "n/a"                | 1.829         | 130386.00328048113     |
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
| "2^236.0"       | 9.5367431640625e-7      | 1048576.0             | 2289880        | "n/a"                | 17.604        | 130077.25516927971     |
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
| "2^235.0"       | 4.76837158203125e-7     | 2097152.0             | 2289880        | "n/a"                | 17.707        | 129320.60766928333     |
+-----------------+-------------------------+-----------------------+----------------+----------------------+---------------+------------------------+
```

In this table you see:
- `:target` the target (expressed in power of 2)
- `:probab` the probability of finding a hash that is below the target (a valid proof-of-work)
- `:estimated_trials` the estimated number of trials according to the probability
- `:nounce` the nounce that satifies the proof-of-work
- `:estimated_time` the estimated time in seconds to come up with a nounce that satisfies the proof-of-work (only available when a hash rate is provided)
- `:time` the actual time spent in seconds
- `:hasrate` the number of hash computed per second

The table shows that my hash rate is around 130 000 hashes/s. I can run the same function again but this time passing this hash rate:

```elixir
Blockchain.Difficulty.benchmark(130_000) # using 130_000 hashes/s
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
| :target         | :probab                | :estimated_trials     | :nounce       | :estimated_time         | :time         | :hashrate             |
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
| "2^252.0"       | 0.0625                 | 16.0                  | 41            | 1.2307692307692307e-4   | 0.001         | "n/a"                 |
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
| "2^248.0"       | 0.00390625             | 256.0                 | 326           | 0.001969230769230769    | 0.004         | "n/a"                 |
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
| "2^240.0"       | 1.52587890625e-5       | 65536.0               | 97779         | 0.5041230769230769      | 0.737         | "n/a"                 |
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
| "2^236.0"       | 9.5367431640625e-7     | 1048576.0             | 1539392       | 8.06596923076923        | 11.319        | 136000.70677621698    |
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
| "2^235.0"       | 4.76837158203125e-7    | 2097152.0             | 1539392       | 16.13193846153846       | 11.375        | 135331.16483516485    |
+-----------------+------------------------+-----------------------+---------------+-------------------------+---------------+-----------------------+
```

I now have an estimation of the time that is required (according to probabilities) to complete a proof-of-work.

### Finding a target for a given time

With your hash rate in mind, you can pick your target. Let's say I want my blocks to be generated every **10 seconds** in average and that my hash rate is estimated to `135 000`:

```
Blockchain.Difficulty.target_for_time(10, 135_000)
00000C6D750EBFA67C0000000000000000000000000000000000000000000000
```

With a hash rate of `135 000`, the above target should make the proof-of-work last 10 seconds on average. We can test it:

```
Blockchain.Difficulty.test_target("00000C6D750EBFA67C0000000000000000000000000000000000000000000000")
+-------------------------+------------------------+----------------------+---------------+--------------------+--------------+----------------------+
| :target                 | :probab                | :estimated_trials    | :nounce       | :estimated_time    | :time        | :hashrate            |
+-------------------------+------------------------+----------------------+---------------+--------------------+--------------+----------------------+
| "2^235.63547202339973"  | 7.407407407407408e-7   | 1349999.9999999998   | 1460163       | "n/a"              | 10.887       | 134119.8677321576    |
+-------------------------+------------------------+----------------------+---------------+--------------------+--------------+----------------------+
```

Run this multiple times and you should see that the time spent approaches 10 seconds.

## What's next

Hash rate can change depending on the hardware or the proof-of-work implementation (Elixir will give you a bad hash rate compared to C for example). That is why Bitcoin protocol adjusts the difficulty target every 2016 blocks. This is not yet available in `coincoin` but will be soon.


