// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {console2 as console} from "forge-std/console2.sol";
import {MerkleDistributor} from "../src/MerkleDistributor.sol";
import {OwnedMulticall3} from "../src/OwnedMulticall3.sol";
import {Multicall3} from "../src/Multicall3.sol";

contract CounterTest is Test {
    MerkleDistributor merkleDistributor = MerkleDistributor(address(0x8A7E7eE5457DE6e58422040b78ED6A7eC0d5b83a));
    address constant tokenAddress = address(0xb2c5a37A4C37c16DDd21181F6Ddbc989c3D36cDC);
    uint256 constant tokenAmount = 500000000000000000000000;
    string constant ipfsHash = "QmULGPmJyo7rYseFEay3xiGbqFmqQ8qGVttfT5zz77Foq8";
    bytes32 constant merkleRoot = 0xe19c02af10030ebd0d06743d8be8953a09642fefff32e8e988a226b85a98d0e9;
    OwnedMulticall3 constant ownedMulticall = OwnedMulticall3(address(0x3082263EC78fa714a48F62869a77dABa0FfeF583));

    function setUp() public {
    }

    function test_setWindow() public {
        uint256 forkId = vm.createFork("https://mainnet.era.zksync.io");
        vm.selectFork(forkId);

        require(merkleDistributor.owner() == address(ownedMulticall), "merkleDistributor not set");
        require(IERC20(tokenAddress).balanceOf(address(ownedMulticall)) >= tokenAmount, "tokenAmount not available");
        require(IERC20(tokenAddress).allowance(address(ownedMulticall), address(merkleDistributor)) >= tokenAmount, "tokenAmount not approved");

        // l2 timelock alias
        vm.prank(address(0xddF3065C1Dc423451530bF7B493243234bA1F95A));
        Multicall3.Call[] memory calls;
        calls[0] = Multicall3.Call({
            target: address(merkleDistributor),
            callData: abi.encodeWithSignature("setWindow(uint256,address,bytes32,string)", tokenAmount, tokenAddress, merkleRoot, ipfsHash)
        });

        ownedMulticall.aggregate(calls);
        merkleDistributor.setWindow(tokenAmount, tokenAddress, merkleRoot, ipfsHash);
    }

}
