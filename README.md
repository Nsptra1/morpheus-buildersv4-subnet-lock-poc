# NV-1 PoC — BuildersV4 subnet admin can permanently lock stakers' principal

**Target:** BuildersV4 proxy `0x42BB446eAE6dca7723a9eBdb81EA88aFe77eF4B9` on Base (chainId 8453)
**Fork block:** `58391435` (pinned in the test)
**Token:** MOR on Base, `0x7431aDa8a591C955a994a21710752EF9b882b8e3`

## The bug

`deposit()` records only the stake amount and a `lastDeposit` timestamp — the withdraw
lock period is never snapshotted per staker. `withdraw()` reads
`withdrawLockPeriodAfterDeposit` from the *live* Subnet struct, and `editSubnet()` lets the
subnet admin replace that struct at any time. `_validateSubnet()` enforces only a lower
bound (≥ `minimalWithdrawLockPeriod`, 7 days) on the lock period — no upper bound, no
timelock, no staker consent, no exemption for subnets that already hold deposits.

The subnet-admin role is acquired permissionlessly: `createSubnet()` is public and the
creator names any admin (including itself). So any address can create a subnet, attract
third-party stake under a normal-looking 7-day lock, then raise the lock to 2^127 seconds
(or to the uint128 maximum) with one `editSubnet()` call. Every existing staker's
principal becomes permanently unreachable — `withdraw()` is the only principal-exit path
in the contract, and it can never pass again.

## What the test proves

Three fresh, unprivileged addresses; no one is pranked as a protocol owner/admin/multisig.

1. `attacker` creates a subnet via the public `createSubnet()` (7-day lock, the on-chain
   minimum). `victim` stakes **500 MOR** into it.
2. A control pair repeats the identical flow on a second subnet whose admin never edits.
3. The attacker calls `editSubnet()` once, raising the lock to 2^127 seconds.
4. After warping past the original 7-day lock, the **control staker withdraws in full**
   (control assertion), while the **victim's withdraw reverts**.
5. After a further ~100 years, the victim's withdraw still reverts; a second edit to the
   uint128 maximum also leaves withdraw unreachable.
6. Loss asserted numerically: the victim's MOR balance is short exactly the 500 MOR
   principal, the stake is still recorded in `usersData`, and BuildersV4 still holds it
   (its MOR balance fell only by the control staker's legitimate exit).

## Run it (one command)

Requires a Foundry install (`forge`). From a clean clone:

```bash
BASE_RPC_URL=<any Base mainnet RPC URL> forge test
```

That is the only setup: the test forks Base at block 58391435 via
`vm.createSelectFork(vm.envString("BASE_RPC_URL"), 58391435)`, and forge-std is vendored
under `lib/` so no dependency installation is needed.

Expected result: `1 passed; 0 failed`. A captured passing run is in `poc-run.log`.
On-chain impact figures at the pinned block are in `impact.md` (raw scan data:
`impact-scan.json`).
