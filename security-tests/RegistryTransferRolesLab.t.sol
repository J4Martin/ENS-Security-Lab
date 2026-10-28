// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

// Offline-only security regressions on the pinned ENSv2 registry source.
// No RPC endpoints, public-network transactions, or external wallets.
// These checks exercise documented safe-transfer guarantees, not an exploit.
import {PermissionedRegistryTest} from "./PermissionedRegistry.t.sol";
import {IEnhancedAccessControl} from "~src/access-control/interfaces/IEnhancedAccessControl.sol";
import {IPermissionedRegistry} from "~src/registry/interfaces/IPermissionedRegistry.sol";
import {RegistryRolesLib} from "~src/registry/libraries/RegistryRolesLib.sol";

contract RegistryTransferRolesLab is PermissionedRegistryTest {
    uint256 constant TRANSFER_ROLE = RegistryRolesLib.ROLE_CAN_TRANSFER_ADMIN;
    uint256 constant RESOLVER_ROLE = RegistryRolesLib.ROLE_SET_RESOLVER;
    uint256 constant RESOLVER_ADMIN = RegistryRolesLib.ROLE_SET_RESOLVER_ADMIN;

    function test_lab_safeTransferRejectsOutstandingThirdPartyResolverRole() public {
        _makeEmancipated();
        testRoles = TRANSFER_ROLE | RESOLVER_ROLE | RESOLVER_ADMIN;
        uint256 tokenId = this._register();

        vm.prank(user1);
        registry.grantRoles(tokenId, RESOLVER_ROLE, actor);
        tokenId = registry.getTokenId(tokenId);

        assertTrue(registry.hasRoles(tokenId, RESOLVER_ROLE, actor));

        // A buyer using the safe transfer path must not silently inherit
        // a name with a separately authorized resolver delegate.
        vm.expectRevert(
            abi.encodeWithSelector(
                IPermissionedRegistry.TransferUnsafeWithMultipleAssignees.selector,
                tokenId,
                user1
            )
        );
        vm.prank(user1);
        registry.safeTransferFrom(user1, user2, tokenId, 1, "");

        assertEq(registry.ownerOf(tokenId), user1);
        assertTrue(registry.hasRoles(tokenId, RESOLVER_ROLE, actor));
    }

    function test_lab_revokingDelegateBeforeTransferPreventsOldAccess() public {
        _makeEmancipated();
        testRoles = TRANSFER_ROLE | RESOLVER_ROLE | RESOLVER_ADMIN;
        uint256 tokenId = this._register();

        // A third-party manager is authorized temporarily.
        vm.prank(user1);
        registry.grantRoles(tokenId, RESOLVER_ROLE, actor);
        tokenId = registry.getTokenId(tokenId);
        assertTrue(registry.hasRoles(tokenId, RESOLVER_ROLE, actor));

        // Owner revokes it before transferring the name.
        vm.prank(user1);
        registry.revokeRoles(tokenId, RESOLVER_ROLE, actor);
        tokenId = registry.getTokenId(tokenId);
        assertFalse(registry.hasRoles(tokenId, RESOLVER_ROLE, actor));

        // A safe transfer now completes.
        vm.prank(user1);
        registry.safeTransferFrom(user1, user2, tokenId, 1, "");
        assertEq(registry.ownerOf(tokenId), user2);

        // The delegate and original owner cannot set a new resolver.
        uint256 resource = registry.getResource(tokenId);
        vm.expectRevert(
            abi.encodeWithSelector(
                IEnhancedAccessControl.EACUnauthorizedAccountRoles.selector,
                resource,
                RESOLVER_ROLE,
                actor
            )
        );
        vm.prank(actor);
        registry.setResolver(tokenId, actor);

        vm.expectRevert(
            abi.encodeWithSelector(
                IEnhancedAccessControl.EACUnauthorizedAccountRoles.selector,
                resource,
                RESOLVER_ROLE,
                user1
            )
        );
        vm.prank(user1);
        registry.setResolver(tokenId, user1);

        // The new owner has the expected resolver role.
        assertTrue(registry.hasRoles(tokenId, RESOLVER_ROLE, user2));
        vm.prank(user2);
        registry.setResolver(tokenId, user2);
        assertEq(registry.getResolver(testLabel), user2);
    }
}
