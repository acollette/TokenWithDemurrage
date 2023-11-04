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
    uint256 decimals = 10 ** 6;
    uint256 initUserBalances = 100_000 * decimals;

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
        mintTokens(users.user1, initUserBalances);
        mintTokens(users.user2, initUserBalances);
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
        uint256 user1InitBalance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryInitBalance = brusselsCoin.balanceOf(users.creatorAddress);
        emit log_named_uint("Init balance user1", user1InitBalance);

        vm.warp(block.timestamp + 30 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        uint256 user1Balance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryBalance = brusselsCoin.balanceOf(users.creatorAddress);

        emit log_named_uint("Balance user1 after tax", user1Balance);
        emit log_named_uint("Balance treasury after tax", treasuryBalance);

        assert(user1Balance < user1InitBalance);
        assert(treasuryBalance > treasuryInitBalance);
    }

    function test_Success_Tax_90days() public {
        uint256 user1InitBalance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryInitBalance = brusselsCoin.balanceOf(users.creatorAddress);
        emit log_named_uint("Init balance user1", user1InitBalance);

        vm.warp(block.timestamp + 90 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        uint256 user1Balance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryBalance = brusselsCoin.balanceOf(users.creatorAddress);

        emit log_named_uint("Balance user1 after tax", user1Balance);
        emit log_named_uint("Balance treasury after tax", treasuryBalance);

        assert(user1Balance < user1InitBalance);
        assert(treasuryBalance > treasuryInitBalance);
    }

    function test_Success_Tax_180days() public {
        uint256 user1InitBalance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryInitBalance = brusselsCoin.balanceOf(users.creatorAddress);
        emit log_named_uint("Init balance user1", user1InitBalance);

        vm.warp(block.timestamp + 180 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        uint256 user1Balance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryBalance = brusselsCoin.balanceOf(users.creatorAddress);

        emit log_named_uint("Balance user1 after tax", user1Balance);
        emit log_named_uint("Balance treasury after tax", treasuryBalance);

        assert(user1Balance < user1InitBalance);
        assert(treasuryBalance > treasuryInitBalance);
    }

    function test_Success_Tax_365days() public {
        uint256 user1InitBalance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryInitBalance = brusselsCoin.balanceOf(users.creatorAddress);
        emit log_named_uint("Init balance user1", user1InitBalance);

        vm.warp(block.timestamp + 365 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        uint256 user1Balance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryBalance = brusselsCoin.balanceOf(users.creatorAddress);

        emit log_named_uint("Balance user1 after tax", user1Balance);
        emit log_named_uint("Balance treasury after tax", treasuryBalance);

        assert(user1Balance < user1InitBalance);
        assert(treasuryBalance > treasuryInitBalance);
    }

    function test_Success_Tax_730days() public {
        uint256 user1InitBalance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryInitBalance = brusselsCoin.balanceOf(users.creatorAddress);
        emit log_named_uint("Init balance user1", user1InitBalance);

        vm.warp(block.timestamp + 730 days);

        vm.prank(users.creatorAddress);
        brusselsCoin.tax(users.user1);

        uint256 user1Balance = brusselsCoin.balanceOf(users.user1);
        uint256 treasuryBalance = brusselsCoin.balanceOf(users.creatorAddress);

        emit log_named_uint("Balance user1 after tax", user1Balance);
        emit log_named_uint("Balance treasury after tax", treasuryBalance);

        assert(user1Balance < user1InitBalance);
        assert(treasuryBalance > treasuryInitBalance);
    }

    function testFuzz_Success_transfer(uint256 amount) public {
        uint256 user1InitBalance = brusselsCoin.balanceOf(users.user1);

        vm.warp(block.timestamp + 100 days);

        amount = bound(amount, 1,  initUserBalances - brusselsCoin.getDemurrage((users.user1)));

        vm.prank(users.user1);
        brusselsCoin.transfer(users.user2, amount);

        // The balance of user1 should have decreased more than transfered amount
        assert(brusselsCoin.balanceOf(users.user1) < user1InitBalance - amount);
        assert(brusselsCoin.balanceOf(users.creatorAddress) > 0);
    }
}