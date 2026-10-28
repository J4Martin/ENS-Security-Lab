// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Public, non-sensitive regression tests on pinned official ENSv2 source.
// Only in-memory Foundry accounts are used, with no RPC or network access.
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Execution} from "nexus/types/DataTypes.sol";
import {ERC1271_MAGICVALUE} from "nexus/types/Constants.sol";

import {HCAOwnerAndSessionValidator} from "~src/hca/HCAOwnerAndSessionValidator.sol";
import {HCAOwnerAndSessionValidatorTest} from "./HCAOwnerAndSessionValidator.t.sol";

contract HcaPolicyBoundariesLab is HCAOwnerAndSessionValidatorTest {
    function _setupRefund()
        internal
        view
        returns (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        )
    {
        (proof, permissionId) = _multiChainEnableProof();
        refund = HCAOwnerAndSessionValidator.GasRefund({
            token: proof.refundToken,
            exchangeRate: proof.maxRefundExchangeRate,
            overhead: (uint256(proof.maxRefundAmount) << 128) | proof.maxRefundGasOverhead
        });
        operation = _initialRefundCommitOperation(permissionId, proof);
    }

    function _checkRefund(
        SessionEnableProofFixture memory proof,
        bytes32 permissionId,
        HCAOwnerAndSessionValidator.GasRefund memory refund,
        bytes memory operation,
        uint256 nonce
    )
        internal
        view
        returns (bytes4)
    {
        bytes32 digest = validator.singleChainDigestWithRefundHarness(
            address(hca), nonce, operation, refund
        );
        bytes memory envelope = _initialRefundEnvelope(
            permissionId, proof, nonce, refund, operation, digest
        );
        return hca.validate(validator, digest, envelope);
    }

    // Compute the digest and envelope BEFORE setting the revert expectation:
    // the digest harness is an external view call in its own right.
    function _expectRefundRevert(
        SessionEnableProofFixture memory proof,
        bytes32 permissionId,
        HCAOwnerAndSessionValidator.GasRefund memory refund,
        bytes memory operation,
        uint256 nonce,
        bytes memory expectedRevert
    )
        internal
    {
        bytes32 digest = validator.singleChainDigestWithRefundHarness(
            address(hca), nonce, operation, refund
        );
        bytes memory envelope = _initialRefundEnvelope(
            permissionId, proof, nonce, refund, operation, digest
        );
        vm.expectRevert(expectedRevert);
        hca.validate(validator, digest, envelope);
    }

    function test_lab_rejectsExchangeRateAboveOwnerSignedCeiling() public {
        (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        ) = _setupRefund();

        // Positive control: same proof at its maximum signed exchange rate.
        assertEq(_checkRefund(proof, permissionId, refund, operation, 101), ERC1271_MAGICVALUE);

        refund.exchangeRate += 1;
        _expectRefundRevert(
            proof, permissionId, refund, operation, 102,
            abi.encodeWithSelector(HCAOwnerAndSessionValidator.GasRefundNotAllowed.selector)
        );
    }

    function test_lab_rejectsGasOverheadAboveOwnerSignedCeiling() public {
        (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        ) = _setupRefund();

        assertEq(_checkRefund(proof, permissionId, refund, operation, 103), ERC1271_MAGICVALUE);
        refund.overhead += 1; // changes only the lower gas-overhead component
        _expectRefundRevert(
            proof, permissionId, refund, operation, 104,
            abi.encodeWithSelector(HCAOwnerAndSessionValidator.GasRefundNotAllowed.selector)
        );
    }

    function test_lab_rejectsDifferentRefundToken() public {
        (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        ) = _setupRefund();

        assertEq(_checkRefund(proof, permissionId, refund, operation, 105), ERC1271_MAGICVALUE);
        refund.token = makeAddr("unauthorized-refund-token");
        _expectRefundRevert(
            proof, permissionId, refund, operation, 106,
            abi.encodeWithSelector(HCAOwnerAndSessionValidator.GasRefundNotAllowed.selector)
        );
    }

    function test_lab_rejectsUnapprovedERC20Spender() public {
        (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        ) = _setupRefund();

        assertEq(_checkRefund(proof, permissionId, refund, operation, 107), ERC1271_MAGICVALUE);

        Execution[] memory executions = _initialRefundExecutions(permissionId, proof);
        executions[2].callData = abi.encodeWithSelector(
            IERC20.approve.selector, makeAddr("unauthorized-spender"), proof.maxRefundAmount
        );
        operation = _encodeExecutions(executions);

        _expectRefundRevert(
            proof, permissionId, refund, operation, 108,
            abi.encodeWithSelector(HCAOwnerAndSessionValidator.PolicyRuleFailed.selector)
        );
    }

    function test_lab_rejectsArbitraryERC20Transfer() public {
        (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        ) = _setupRefund();

        assertEq(_checkRefund(proof, permissionId, refund, operation, 109), ERC1271_MAGICVALUE);

        Execution[] memory executions = _initialRefundExecutions(permissionId, proof);
        executions[2].callData = abi.encodeWithSelector(
            IERC20.transfer.selector, makeAddr("unauthorized-recipient"), uint256(100)
        );
        operation = _encodeExecutions(executions);

        _expectRefundRevert(
            proof, permissionId, refund, operation, 110,
            abi.encodeWithSelector(
                HCAOwnerAndSessionValidator.ActionNotAllowed.selector,
                paymentToken,
                IERC20.transfer.selector
            )
        );
    }

    function test_lab_rejectsOldOwnerSessionProofAfterOwnershipChange() public {
        (
            SessionEnableProofFixture memory proof,
            bytes32 permissionId,
            HCAOwnerAndSessionValidator.GasRefund memory refund,
            bytes memory operation
        ) = _setupRefund();

        assertEq(_checkRefund(proof, permissionId, refund, operation, 111), ERC1271_MAGICVALUE);

        // Standalone mock stores owner (160 bits) and session nonce (96 bits)
        // in storage slot zero. Replace the owner without altering nonce.
        address newOwner = makeAddr("new-hca-owner");
        vm.store(address(hca), bytes32(uint256(0)), bytes32(uint256(uint160(newOwner))));
        assertEq(hca.owner(), newOwner);
        assertEq(hca.sessionNonce(), proof.sessionNonce);

        _expectRefundRevert(
            proof, permissionId, refund, operation, 112,
            abi.encodeWithSelector(HCAOwnerAndSessionValidator.InvalidSigner.selector)
        );
    }
}
