// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Reproduce migration and subsequent ERC-1155 ownership transfer on a
// fully synthetic, offline ENSv1/ENSv2 Foundry fixture.
// These are regression guards, not a published vulnerability PoC.
import {MigrationHelperTest} from "./MigrationHelper.t.sol";
import {LibMigration} from "~src/migration/libraries/LibMigration.sol";
import {LockedChildren} from "~src/migration/MigrationHelper.sol";
import {RegistryRolesLib} from "~src/registry/libraries/RegistryRolesLib.sol";
import {IPermissionedRegistry} from "~src/registry/interfaces/IPermissionedRegistry.sol";
import {IEnhancedAccessControl} from "~src/access-control/interfaces/IEnhancedAccessControl.sol";

contract MigrationPostTransferRolesLab is MigrationHelperTest {
    uint256 constant RESOLVER_ROLE = RegistryRolesLib.ROLE_SET_RESOLVER;

    function _migrateLabName() internal returns (uint256 tokenId) {
        (bytes memory encodedName, ) = registerUnwrapped("labmigrated");

        vm.prank(testOwner);
        baseRegistrar.setApprovalForAll(address(helper), true);

        LibMigration.Data[] memory names = _toArray(_unlockedData(encodedName));
        vm.prank(testOwner);
        helper.migrate(
            names,
            new LibMigration.Data[][](0),
            new LibMigration.Data[][](0),
            new LockedChildren[](0)
        );
        tokenId = ethRegistry.findTokenId("labmigrated");
        assertEq(ethRegistry.ownerOf(tokenId), testOwner);
        assertTrue(ethRegistry.hasRoles(tokenId, RESOLVER_ROLE, testOwner));
    }

    function test_lab_migrationThenSafeTransferMovesResolverRoleToNewOwner() public {
        uint256 tokenId = _migrateLabName();

        vm.prank(testOwner);
        ethRegistry.safeTransferFrom(testOwner, friend, tokenId, 1, "");

        assertEq(ethRegistry.ownerOf(tokenId), friend);
        assertFalse(ethRegistry.hasRoles(tokenId, RESOLVER_ROLE, testOwner));
        assertTrue(ethRegistry.hasRoles(tokenId, RESOLVER_ROLE, friend));

        uint256 resource = ethRegistry.getResource(tokenId);
        vm.expectRevert(
            abi.encodeWithSelector(
                IEnhancedAccessControl.EACUnauthorizedAccountRoles.selector,
                resource, RESOLVER_ROLE, testOwner
            )
        );
        vm.prank(testOwner);
        ethRegistry.setResolver(tokenId, testOwner);

        vm.prank(friend);
        ethRegistry.setResolver(tokenId, friend);
        assertEq(ethRegistry.getResolver("labmigrated"), friend);
    }

    function test_lab_migratedNameSafeTransferBlocksUntilDelegateRevoked() public {
        uint256 tokenId = _migrateLabName();

        vm.prank(testOwner);
        ethRegistry.grantRoles(tokenId, RESOLVER_ROLE, actor);
        tokenId = ethRegistry.getTokenId(tokenId);
        assertTrue(ethRegistry.hasRoles(tokenId, RESOLVER_ROLE, actor));

        // Protected ERC-1155 transfer is denied while a third party
        // still has an unrevoked resolver role on the token.
        vm.expectRevert(
            abi.encodeWithSelector(
                IPermissionedRegistry.TransferUnsafeWithMultipleAssignees.selector,
                tokenId, testOwner
            )
        );
        vm.prank(testOwner);
        ethRegistry.safeTransferFrom(testOwner, friend, tokenId, 1, "");

        vm.prank(testOwner);
        ethRegistry.revokeRoles(tokenId, RESOLVER_ROLE, actor);
        tokenId = ethRegistry.getTokenId(tokenId);

        vm.prank(testOwner);
        ethRegistry.safeTransferFrom(testOwner, friend, tokenId, 1, "");

        assertEq(ethRegistry.ownerOf(tokenId), friend);
        assertFalse(ethRegistry.hasRoles(tokenId, RESOLVER_ROLE, actor));
        assertTrue(ethRegistry.hasRoles(tokenId, RESOLVER_ROLE, friend));

        uint256 resource = ethRegistry.getResource(tokenId);
        vm.expectRevert(
            abi.encodeWithSelector(
                IEnhancedAccessControl.EACUnauthorizedAccountRoles.selector,
                resource, RESOLVER_ROLE, actor
            )
        );
        vm.prank(actor);
        ethRegistry.setResolver(tokenId, actor);
    }
}
