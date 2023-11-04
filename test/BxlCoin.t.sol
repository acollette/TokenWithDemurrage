// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BrusselsCoin } from "../contracts/BxlCoinDemurrage.sol";
import { Test } from "../lib/forge-std/src/Test.sol";
import { Users } from "./Utils/Types.sol";

contract BxlCoinDemurrage_Test is Test {

     /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;
    uint256 public decimals = 10 ** 6;

     /*//////////////////////////////////////////////////////////////////////////
                                     TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    BrusselsCoin internal brusselsCoin;

     /*//////////////////////////////////////////////////////////////////////////
                                    SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/
    function setUp() public {

        // Create users for testing
        users = Users({
            creatorAddress: createUser("creatorAddress"),
            admin1: createUser("admin1"),
            admin2: createUser("admin2"),
            admin3: createUser("admin3"),
            user1: createUser("user1"),
            user2: createUser("user2")
        });

        address[] memory admins = new address[](3);
        admins[0] = users.admin1;
        admins[1] = users.admin2;
        admins[2] = users.admin3;

        vm.prank(users.creatorAddress);
        brusselsCoin = new BrusselsCoin(admins);

        // Mint BXL tokens to admins
        mintTokens(users.user1, 100_000 * decimals);
        mintTokens(users.user2, 100_000 * decimals);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal(user, 100 ether);
        return user;
    }

    function mintTokens(address to, uint256 amount) public {
        vm.prank(users.admin1);
        brusselsCoin.mint(to, amount, "");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      TESTS
    //////////////////////////////////////////////////////////////////////////*/

    function test_Success_Tax_30days() public {
        emit log_named_uint("Init balance user1", brusselsCoin.balanceOf(users.user1));

        vm.warp(block.timestamp + 30 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        emit log_named_uint("Balance user1 after tax", brusselsCoin.balanceOf(users.user1));
        emit log_named_uint("Balance treasury after tax", brusselsCoin.balanceOf(users.creatorAddress));
    }

    function test_Success_Tax_90days() public {
        emit log_named_uint("Init balance user1", brusselsCoin.balanceOf(users.user1));

        vm.warp(block.timestamp + 90 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        emit log_named_uint("Balance user1 after tax", brusselsCoin.balanceOf(users.user1));
        emit log_named_uint("Balance treasury after tax", brusselsCoin.balanceOf(users.creatorAddress));
    }

    function test_Success_Tax_180days() public {
        emit log_named_uint("Init balance user1", brusselsCoin.balanceOf(users.user1));

        vm.warp(block.timestamp + 180 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        emit log_named_uint("Balance user1 after tax", brusselsCoin.balanceOf(users.user1));
        emit log_named_uint("Balance treasury after tax", brusselsCoin.balanceOf(users.creatorAddress));
    }

    function test_Success_Tax_365days() public {
        emit log_named_uint("Init balance user1", brusselsCoin.balanceOf(users.user1));

        vm.warp(block.timestamp + 365 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        emit log_named_uint("Balance user1 after tax", brusselsCoin.balanceOf(users.user1));
        emit log_named_uint("Balance treasury after tax", brusselsCoin.balanceOf(users.creatorAddress));
    }

    function test_Success_Tax_730days() public {
        emit log_named_uint("Init balance user1", brusselsCoin.balanceOf(users.user1));

        vm.warp(block.timestamp + 730 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        emit log_named_uint("Balance user1 after tax", brusselsCoin.balanceOf(users.user1));
        emit log_named_uint("Balance treasury after tax", brusselsCoin.balanceOf(users.creatorAddress));
    }
}