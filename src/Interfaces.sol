// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal ERC20 surface used by the PoC.
interface IERC20Min {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @notice Subnet struct, copied field-for-field from the deployed
/// IBuildersV4 (Base, BuildersV4 implementation 0x18faef315b40a6d9cf49628f1133b1aa507513b0).
struct Subnet {
    string name;
    address admin;
    uint128 unusedStorage1_V4Update;
    uint128 withdrawLockPeriodAfterDeposit;
    uint128 unusedStorage2_V4Update;
    uint256 minimalDeposit;
    address claimAdmin;
}

struct SubnetMetadata {
    string slug;
    string description;
    string website;
    string image;
}

/// @notice Minimal BuildersV4 surface used by the PoC (deployed proxy on Base).
interface IBuildersV4Min {
    function createSubnet(Subnet calldata subnet_, SubnetMetadata calldata metadata_) external;
    function editSubnet(bytes32 subnetId_, Subnet calldata newSubnet_) external;
    function deposit(bytes32 subnetId_, uint256 amount_) external;
    function withdraw(bytes32 subnetId_, uint256 amount_) external;
    function getSubnetId(string memory subnetName_) external view returns (bytes32);
    function minimalWithdrawLockPeriod() external view returns (uint256);
    function subnetCreationFeeAmount() external view returns (uint256);
    function subnets(bytes32 subnetId_)
        external
        view
        returns (
            string memory name,
            address admin,
            uint128 unusedStorage1_V4Update,
            uint128 withdrawLockPeriodAfterDeposit,
            uint128 unusedStorage2_V4Update,
            uint256 minimalDeposit,
            address claimAdmin
        );
    function usersData(address user, bytes32 subnetId_)
        external
        view
        returns (uint128 lastDeposit, uint128 unusedStorage1_V4Update, uint256 deposited, uint256 unusedStorage2_V4Update);
    function subnetsData(bytes32 subnetId_)
        external
        view
        returns (uint128 unusedStorage1_V4Update, uint256 deposited, uint256 unusedStorage2_V4Update, uint256 rate, uint256 pendingRewards);
}
