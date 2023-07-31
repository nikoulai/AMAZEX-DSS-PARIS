// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {USDC} from "./USDC.sol";
// import {LendingPool} from './LendingPool.sol';

/**
 * @title LendingPool
 */
contract LendingHack is Ownable {
    /*//////////////////////////////
    //    Add your hack below!    //
    //////////////////////////////*/
    USDC public usdc;

    /**
     * @dev Constructor that sets the owner of the contract
     * @param _usdc The address of the USDC contract to use
     * @param _owner The address of the owner of the contract
     */
    constructor(address _owner, address _usdc) {
        // change me pls :)
        _transferOwnership(_owner);
        usdc = USDC(_usdc);
    }

    function hack() external {
        uint256 usdcPoolBalance = usdc.balanceOf(address(this));
        usdc.transfer(owner(), usdcPoolBalance);

    }
    function name() external view returns (string memory){
        return "LendingPool hack";
    }
    //============================//
}