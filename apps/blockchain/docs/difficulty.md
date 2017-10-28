# Coincoin difficulty

Difficulty is a concept that refers to proof-of-work. It basically set the time that is required to perform a proof-of-work, and hence, set the **pace at wich blocks are added to the blockchain**.

## Proof-of-work

The goal is to find a `sha256` hash that is below the defined **target**. There is plenty of explanations online

## What are the chances ?

For easier reasonning, imagine a `sha8` algorithm that digests data into 8 bits (and not 256 as `sha256`). If we set our target to :

`0111 1111` : we have `1/2` chance that `sha8` outputs a 0 on the first bit (it's either 0 or 1)

If we say at least 2 leading 0s:

`0011 1111` : we have `1/2 x 1/2 = 1/4` chance that the first and second bits will be 0

If we go on:

`0001 1111` : `1/2 x 1/2 x 1/2 = 1/8`

...

`0000 0000` : `1/2^8 = 0.00390625`

Same thing using **base 16** (hex numbers go from 0 to F which is 16 hex number):

`0111 1111` = `7F` : we have `8/16 = 1/2` chance that `sha8` outputs an hex number lower than or equal 7

`0011 1111` = `3F` : we have `4/16 = 1/4` chance that `sha8` outputs an hex number lower than or equal 3

...

`0000 0000` = `00` : we have `1/16 x 1/16 = 0.00390625` that both numbers are 0

And of course, same thing in **base 10** (8 bits can store decimal from 0 to 255, which is 256 possible numbers):

`7F` = `127` : we have `128/256 = 1/2` chance that `sha8` outputs a number lower than or equal 127

`3F` = `63` : we have `64/256 = 1/4` chance that `sha8` outputs a number lower than or equal 63

...

`00` = `0` : we have `1/256 = 0.00390625` chance that it outputs 0

## Finding a target

### Hash Rate

The hash rate is the number of hash a piece of hardware can compute per seconds. Knowing this and the fact that we can calculate the probability of finding a hash that's below a given target, we can estimate the time of a proof-of-work.

Coincoin provides you with a tool for that:

```

```

Run this command again, but pass a hash rate to the `Blockchain.Difficulty.benchmark/1` function. You will see time estimations based on the given hash rate

### Finding a good target

With your hash rate in mind, you can pick your target. Let's say I want my blocks to be generated every 10 seconds in average and that my hash rate is `135 000` :

```
Blockchain.Difficulty.target_for_time(10, 135_000)
00000C6D750EBFA67C0000000000000000000000000000000000000000000000
```

With a hash rate of `135 000`, the above target should make the proof-of-work last 10 seconds on average. We can test it:

```
Blockchain.Difficulty.test_target("00000C6D750EBFA67C0000000000000000000000000000000000000000000000")

```


Everything is about time

- enter hashrate
- how to use coincoin to find the right difficulty


