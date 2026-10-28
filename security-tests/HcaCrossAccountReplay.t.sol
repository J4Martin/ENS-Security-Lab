// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Local-only adversarial tests against the exact pinned ENS HCA validator.
// All accounts, keys and transactions belong to the Foundry test runtime.
// No production/public-chain transactions and no external RPC dependencies.
import {ERC1271_MAGICVALUE} from "nexus/types/Constants.sol";
import {HCAOwnerAndSessionValidator} from "~src/hca/HCAOwnerAndSessionValidator.sol";
import {MockStandaloneHCA} from "../../mocks/MockStandaloneHCAStack.sol";
import {HCAOwnerAndSessionValidatorTest} from "./HCAOwnerAndSessionValidator.t.sol";

contract HcaCrossAccountReplayLab is HCAOwnerAndSessionValidatorTest {
    function test_lab_rejectsCrossAccountProofSameOwnerPermit2() public {
        // Valid authorization is signed for HCA A (address(hca)).
        (SessionEnableProofFixture memory proof, bytes32 permissionId) = _multiChainEnableProof();
        bytes memory operation = _initialCommitOperation(permissionId, proof);
        (bytes memory claimData, bytes32 digest) = _claim(operation, address(hca), block.chainid);
        bytes memory envelope = _initialEnvelope(permissionId, proof, claimData, operation, digest);

        // Positive control: the real test envelope works for the account it was signed for.
        assertEq(hca.validate(validator, digest, envelope), ERC1271_MAGICVALUE);

        // Negative control: different HCA address but SAME owner EOA must not replay A's proof.
        MockStandaloneHCA hcaB = new MockStandaloneHCA(owner);
        vm.expectRevert(HCAOwnerAndSessionValidator.InvalidSessionData.selector);
        hcaB.validate(validator, digest, envelope);
    }

    function test_lab_rejectsCrossAccountProofSameOwnerRefundRoute() public {
        (SessionEnableProofFixture memory proof, bytes32 permissionId) = _multiChainEnableProof();
        HCAOwnerAndSessionValidator.GasRefund memory refund = HCAOwnerAndSessionValidator.GasRefund({
            token: proof.refundToken,
            exchangeRate: proof.maxRefundExchangeRate,
            overhead: (uint256(proof.maxRefundAmount) << 128) | proof.maxRefundGasOverhead
        });
        bytes memory operation = _initialRefundCommitOperation(permissionId, proof);
        uint256 nonce = 91;
        bytes32 digest = validator.singleChainDigestWithRefundHarness(
            address(hca), nonce, operation, refund
        );
        bytes memory envelope = _initialRefundEnvelope(
            permissionId, proof, nonce, refund, operation, digest
        );

        assertEq(hca.validate(validator, digest, envelope), ERC1271_MAGICVALUE);

        MockStandaloneHCA hcaB = new MockStandaloneHCA(owner);
        vm.expectRevert(HCAOwnerAndSessionValidator.InvalidSessionData.selector);
        hcaB.validate(validator, digest, envelope);
    }

    function test_lab_rejectsRevokedSessionNonceOnRefundRoute() public {
        (SessionEnableProofFixture memory proof, bytes32 permissionId) = _multiChainEnableProof();
        HCAOwnerAndSessionValidator.GasRefund memory refund = HCAOwnerAndSessionValidator.GasRefund({
            token: proof.refundToken,
            exchangeRate: proof.maxRefundExchangeRate,
            overhead: (uint256(proof.maxRefundAmount) << 128) | proof.maxRefundGasOverhead
        });
        bytes memory operation = _initialRefundCommitOperation(permissionId, proof);
        uint256 nonce = 92;
        bytes32 digest = validator.singleChainDigestWithRefundHarness(
            address(hca), nonce, operation, refund
        );
        bytes memory envelope = _initialRefundEnvelope(
            permissionId, proof, nonce, refund, operation, digest
        );

        // Control: it was valid before the account changed its session nonce.
        assertEq(hca.validate(validator, digest, envelope), ERC1271_MAGICVALUE);

        // The same previously authorized proof must become unusable.
        hca.setSessionNonce(proof.sessionNonce + 1);
        vm.expectRevert(HCAOwnerAndSessionValidator.InvalidSessionData.selector);
        hca.validate(validator, digest, envelope);
    }

    function test_lab_rejectsExpiredSessionProofOnRefundRoute() public {
        (SessionEnableProofFixture memory proof, bytes32 permissionId) = _multiChainEnableProof();
        HCAOwnerAndSessionValidator.GasRefund memory refund = HCAOwnerAndSessionValidator.GasRefund({
            token: proof.refundToken,
            exchangeRate: proof.maxRefundExchangeRate,
            overhead: (uint256(proof.maxRefundAmount) << 128) | proof.maxRefundGasOverhead
        });
        bytes memory operation = _initialRefundCommitOperation(permissionId, proof);
        uint256 nonce = 93;
        bytes32 digest = validator.singleChainDigestWithRefundHarness(
            address(hca), nonce, operation, refund
        );
        bytes memory envelope = _initialRefundEnvelope(
            permissionId, proof, nonce, refund, operation, digest
        );

        assertEq(hca.validate(validator, digest, envelope), ERC1271_MAGICVALUE);
        vm.warp(uint256(proof.validUntil) + 1);
        vm.expectRevert(HCAOwnerAndSessionValidator.InvalidSessionData.selector);
        hca.validate(validator, digest, envelope);
    }

}
