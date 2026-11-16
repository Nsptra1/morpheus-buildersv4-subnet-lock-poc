# NV-1 impact figures — BuildersV4, Base, block 58391435

All figures in MOR (18 decimals), read on-chain at **Base block 58391435**
(2026-11-17). Raw scan data: `impact-scan.json` in this directory.

## Headline figures

| Figure | MOR |
|---|---|
| (c) Protocol ceiling — `allSubnetsData.totalDeposited` | **2,977,063.630385230282087390** |
| Cross-check: MOR balance of the BuildersV4 proxy | 2,977,063.630385230282087390 (identical to the wei) |
| Deposits attributed to enumerated subnets (92 found, 66 holding stake) | 436,057.289008373332072394 |
| (a) Third-party stake across the enumerated subnets | **402,265.510466210586031622** |
| (b) Largest single subnet, third-party stake — **MySuperAgent** | **130,421.7708** |
| Deposits NOT attributed to any enumerated subnet (see Method) | 2,541,006.341376856950014996 |

Largest-subnet detail (b): MySuperAgent, admin
`0x67760bad63cc00294764ef7d1f6570e864c196c1`, total deposited 130,421.7708 MOR,
admin's own stake at the admin address 0 MOR — the full amount is third-party
stake, lockable in full by one `editSubnet` call from that admin. Its lock
period at the pinned block is 2,592,000 s (30 days).

## What the numbers mean

Every figure above is principal that the subnet's admin can lock permanently
with the single `editSubnet` call proven in the PoC: the lock applies
retroactively to all existing stakers of that subnet, and `withdraw()` is the
only exit. Figure (a) is the third-party stake summed over the 66 enumerated
subnets that currently hold deposits. Figure (c) is the hard protocol-wide
ceiling: the total principal sitting in BuildersV4 at the pinned block, all of
it held in subnets governed by the same editable-lock mechanism.

## Method

1. Subnet names were taken from Morpheus's own SmartContracts deploy registry
   (`deploy/builders-protocol/data/subnets.json`, 93 names), the additional
   subnet names listed in the repo's `2_v1_add_new_subnets.ts` deploy script
   (28 more, including the code-named batch — none of them resolved to a
   subnet on this proxy), plus the MorScan subnet name. Each name was resolved on-chain under both subnet-ID schemes
   (`getSubnetId` — V4, chainid-keyed — and `getSubnetIdOld` — legacy,
   name-keyed) via `eth_call` at block 58391435. 92 subnets exist; all 92 sit
   under legacy IDs, none under V4 IDs.
2. Per subnet, at the same block: admin and lock period from `subnets(id)`,
   total deposited from `subnetsData(id).deposited`, and the admin's own stake
   from `usersData(admin, id).deposited`. Third-party stake per subnet =
   deposited − admin's own stake.
3. Event-log enumeration (the direct route to every `SubnetCreated`) was
   attempted first and abandoned: the public Base RPCs cap `eth_getLogs`
   ranges (dRPC free plan: 10,000 blocks) and answered wide-range requests
   with HTTP 429, so the name-seeded route above was used instead.

## Approximations and limits — stated plainly

- **The enumeration is incomplete, and the gap is quantified.** The 92
  enumerated subnets account for 436,057.29 MOR of the 2,977,063.63 MOR total.
  The remaining **2,541,006.34 MOR** sits in subnets whose names appear in
  none of the sources used (the deploy-registry snapshot predates them, or
  they were created directly through the UI/contract later). Figures (a) and
  (b) are therefore exact for the enumerated set and a **floor** for the
  protocol: the true third-party total lies between 402,265.51 MOR and the
  2,977,063.63 MOR ceiling. The lock mechanism is identical for the
  unenumerated subnets — each has an admin who can raise its lock the same
  way — but their per-subnet split could not be determined from the available
  enumeration sources and is not estimated here.
- **"Third-party" is measured against the admin address only.** If a subnet
  admin also stakes from other addresses they control, those amounts are
  counted as third-party here; the contract's getters cannot attribute them.
  This can only overstate, never understate, third-party stake.
- **Admin is the current admin at the pinned block** (the role is itself
  transferable via `editSubnet`).

## Per-subnet table (subnets holding deposits, at block 58391435)

Full machine-readable data, including zero-balance subnets, is in
`impact-scan.json`. Lock = `withdrawLockPeriodAfterDeposit` in seconds at the
pinned block — every one of these is replaceable upward by the listed admin at
any time.

| Subnet | Admin | Deposited (MOR) | Admin's own (MOR) | Third-party (MOR) | Lock (s) |
|---|---|---:|---:|---:|---:|
| MySuperAgent | `0x67760bad63cc00294764ef7d1f6570e864c196c1` | 130,421.77 | 0.00 | 130,421.77 | 2592000 |
| Venice | `0x3666f9a79647c81b3b0aab98b9834f5020e762e0` | 82,189.36 | 0.00 | 82,189.36 | 2592000 |
| Protection and Capital Incentive | `0x65485deeceaf608c8304978ca0fca1c49f5308ae` | 80,817.00 | 1.00 | 80,816.00 | 604800 |
| PALcapital | `0x920d2b328f2058516496f932f6247d9347c594d2` | 40,275.51 | 14,935.20 | 25,340.31 | 2592000 |
| MOR Builders | `0x1cb2bc7ef28b2e127a2026fcdd2bf2fc27750525` | 25,028.43 | 0.00 | 25,028.43 | 2592000 |
| coincap | `0x3b438cc593d579627089f0d99bc5f0bb5151c6ce` | 9,917.82 | 157.90 | 9,759.92 | 604800 |
| AI Art by Venice | `0xdb0f1da2f916761beaaa1f58f65b0f1b31d31062` | 9,000.70 | 15.00 | 8,985.70 | 2600000 |
| brainpower | `0x0b0bc9645ac071051406c76d9000679c0366fda4` | 9,490.38 | 3,333.00 | 6,157.38 | 1814400 |
| Wire Network | `0x3caac83717157d7e9b14545803f36ff1650b467f` | 3,055.35 | 0.00 | 3,055.35 | 2592000 |
| NounspaceTom | `0x06ae622bf2029db79bdebd38f723f1f33f95f6c5` | 3,000.00 | 0.00 | 3,000.00 | 2592000 |
| MOR Staking | `0xa33be2c010fcef6650973587fb4bf12c2ef37032` | 2,786.57 | 0.00 | 2,786.57 | 604800 |
| IamAI-Core | `0x26827cce25992d47180aad75f3e69cb57d71602b` | 5,143.52 | 2,500.00 | 2,643.52 | 2592000 |
| ccovibe.com | `0x459c674aa0d686ac03a245af70f5775e33ac323e` | 5,815.16 | 3,207.16 | 2,608.00 | 700000 |
| Venice Pro | `0xe01c58819893865b5df20c9f75833401f1c0906b` | 2,116.60 | 0.00 | 2,116.60 | 2592000 |
| Morpheus Node | `0xf9b58539edfa57b4013e658666b1c61d165bcf3a` | 2,030.00 | 0.00 | 2,030.00 | 2592000 |
| Nounspace | `0xef93ccf233a6c6a0f3ce78e30ca3a06c06942133` | 1,764.23 | 0.00 | 1,764.23 | 2592000 |
| Katara | `0xcd8f007aae316b15baa10c650edeb3fe08a75999` | 4,064.60 | 2,500.00 | 1,564.60 | 1209600 |
| OLAS | `0xb04b996738f69ddad9099acb040e500c2492446d` | 1,525.20 | 0.00 | 1,525.20 | 2592000 |
| DAIS | `0x28bfe7a0fc7d541aa8ee1240f1551d65dca19291` | 1,103.20 | 0.00 | 1,103.20 | 2592000 |
| TacoBytes | `0x896c20da40c2a4df9b7c98b16a8d5a95129161a5` | 1,407.21 | 335.66 | 1,071.55 | 1814400 |
| CETI | `0x1f22b27f0b4faf651dbaea215b32988f658008a3` | 1,003.00 | 0.00 | 1,003.00 | 2592000 |
| Pattern | `0x9b9b617e5b4c964390f99b8504af070b349572c1` | 1,042.41 | 41.41 | 1,001.00 | 2592000 |
| Frostbyte | `0x4375a9cda86ff20ab963fdebd89610d4311d5b28` | 1,000.00 | 0.00 | 1,000.00 | 2592000 |
| Gif Studios | `0x9f853ac79013b932dc2e45140270ab7a47e65fbf` | 1,000.00 | 0.00 | 1,000.00 | 2592000 |
| Rainfall | `0xbd4672f2f283a081926b8b150b31022d2eecac8f` | 553.00 | 0.00 | 553.00 | 2592000 |
| Agent Access | `0xc2ff7040233afb5c117f9fb128d1d08d1bf351ba` | 510.00 | 0.00 | 510.00 | 2592000 |
| Tales & Conquest | `0x55d6c73306a7af0e68c004147f86a98f16130b3b` | 500.00 | 0.00 | 500.00 | 2592000 |
| Satori | `0x370feb9dad2062917b4ee99ebb6af3c1f0ccbecd` | 411.00 | 0.00 | 411.00 | 604800 |
| GrowMOR | `0xf8a9f05c149a73e80b35f9f929670d10cdd91fde` | 337.00 | 0.00 | 337.00 | 604800 |
| Theoriq | `0x0199346a0c257ac901a899baa83bcf1bcfa9e0e5` | 331.00 | 0.00 | 331.00 | 2592000 |
| Akash | `0x6c1ed23c071243879cbcc70dfda211c1f2ddb214` | 291.90 | 0.00 | 291.90 | 2592000 |
| Unocoin | `0x2e056a68c7ef30d0a5487703696184e6dcae4668` | 260.54 | 0.00 | 260.54 | 2592000 |
| 6079 | `0xc686d10c51b59dcb123547f2a3762e3ad43dd777` | 226.00 | 0.00 | 226.00 | 2592000 |
| Shapeshift | `0x6515514486788392055c794c1692f833f3c40a91` | 132.20 | 0.00 | 132.20 | 2592000 |
| Gen Layer | `0x12584bbe07643064992d603664937fa801112ef4` | 106.34 | 0.00 | 106.34 | 2592000 |
| Morlord | `0xb56bed300f084e308c7eab17c175fdc40ef3885f` | 104.00 | 0.00 | 104.00 | 2592000 |
| Flock.io | `0x372663a3629cbfd377c94d5962bd0b62c824bd4a` | 101.00 | 0.00 | 101.00 | 2592000 |
| Lumerin | `0xd87091bcf26332c501a08f90f9aad99a7c9045c3` | 64.92 | 0.00 | 64.92 | 2592000 |
| Manifest Network | `0xe7432b5415e8b3dba4a6ae167e89648a1051cb7f` | 53.20 | 0.00 | 53.20 | 2592000 |
| Virtuals | `0x64af3260da78548ad2f9be06ae77904690684460` | 53.20 | 0.00 | 53.20 | 2592000 |
| ZO.ME | `0xbbdea6172be7798f7fa37e7e5432d9426954c1de` | 51.20 | 0.00 | 51.20 | 2592000 |
| Sapien AI | `0xb5d104ce51a488eb34c087ec0a245031814c1a52` | 51.20 | 0.00 | 51.20 | 2592000 |
| Near | `0x82eaaaadfec2e4fc2003ac9d4fe312de1c468821` | 51.00 | 0.00 | 51.00 | 2592000 |
| Morlord MOR Staking | `0x72f457d6237f66f68b6ea4408a3219ab7ae13be8` | 37.30 | 0.00 | 37.30 | 2592000 |
| Hyperbolic | `0xe885927ba18e12a426a8f774149caf6613901003` | 15.20 | 0.00 | 15.20 | 2592000 |
| ATX DAO | `0xcbb0aac025f0554978a5ec4b35169e71e4910213` | 12.00 | 0.00 | 12.00 | 2592000 |
| Distro Media | `0x0e9aca260d4fa92ec6076db2265dc0014f0ddeb1` | 142.03 | 134.13 | 7.90 | 2592000 |
| Renascence | `0xb4a0462e8f0511f01689ff8d58d649b46e90cb9c` | 5.00 | 0.00 | 5.00 | 2592000 |
| Bloq | `0xf8d5ca35466a7eaba3fb7f9985d8ecc830af0667` | 3.20 | 0.00 | 3.20 | 2592000 |
| Lifted | `0xb081870678d563a4d1cf0ab189ab2038695827a3` | 3.00 | 0.00 | 3.00 | 2592000 |
| Airvey Advisory | `0xeda4b0cb9507d69b3ce45c86d199a62cb474514b` | 3.00 | 0.00 | 3.00 | 604800 |
| Arkeo | `0xa466f111133f218a024de7d85b6b1d8da0224bfd` | 3.00 | 0.00 | 3.00 | 2592000 |
| AI16Z | `0xd928ca72eac64523def6e2703f9091d9d99019e7` | 3.00 | 0.00 | 3.00 | 2592000 |
| Hemi | `0x21e58574b307766e5cff933cffdf4680f40b76b0` | 2.20 | 0.00 | 2.20 | 2592000 |
| exaBITS | `0x59eb7b69d07540549f1913f26855f8247557a8ab` | 2.20 | 0.00 | 2.20 | 2592000 |
| AO Arweave | `0x38ecffb55d36afcda4b8d6b65fff2ed5f373a4c7` | 2.20 | 0.00 | 2.20 | 2592000 |
| Phala Network | `0x696387bb15df29600cf4f646bd4a3658e6bbda7b` | 2.00 | 0.00 | 2.00 | 2592000 |
| Freedom GPT | `0x3e8d52d57798fc9c37d9618887935a1a5266a715` | 1.20 | 0.00 | 1.20 | 2592000 |
| MorpheusAI | `0x762bdda2cd7ca2760922694b034f10a73a5de0d4` | 1.00 | 0.00 | 1.00 | 604800 |
| Tales & Conquests | `0x55d6c73306a7af0e68c004147f86a98f16130b3b` | 1.00 | 0.00 | 1.00 | 2592000 |
| MORLORD | `0x72f457d6237f66f68b6ea4408a3219ab7ae13be8` | 0.50 | 0.00 | 0.50 | 604800 |
| Panorama | `0x25b7a50429d89a6e13dff47ccbe0e54e6cfc65b0` | 0.20 | 0.00 | 0.20 | 2592000 |
| iamai-core | `0x26827cce25992d47180aad75f3e69cb57d71602b` | 4,700.00 | 4,700.00 | 0.00 | 604800 |
| SUPERCYCLE | `0xeada699f119ec274dd2c58e286664c231602bb44` | 1,929.31 | 1,929.31 | 0.00 | 604800 |
| Staking | `0xa33be2c010fcef6650973587fb4bf12c2ef37032` | 1.01 | 1.01 | 0.00 | 604800 |
| Aiora Agency | `0x96706eb471f875a9a41442f358d3b34ba02f868b` | 1.00 | 1.00 | 0.00 | 604800 |

**Total third-party (enumerated): 402,265.51 MOR across 66 subnets with deposits.**
