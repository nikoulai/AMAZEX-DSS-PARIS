// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {VaultFactory} from "../src/4_RescuePosi/myVaultFactory.sol";
import {VaultWalletTemplate} from "../src/4_RescuePosi/myVaultWalletTemplate.sol";
import {PosiCoin} from "../src/4_RescuePosi/PosiCoin.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/


/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge4Test is Test {
    VaultFactory public FACTORY;
    PosiCoin public POSI;
    address public unclaimedAddress = 0x70E194050d9c9c949b3061CC7cF89dF9c6782b7F;
    address public whitehat = makeAddr("whitehat");
    address public devs = makeAddr("devs");

    function setUp() public {
        vm.label(unclaimedAddress, "Unclaimed Address");

        // Instantiate the Factory
        FACTORY = new VaultFactory();

        // Instantiate the POSICoin
        POSI = new PosiCoin();

        // OOPS transferred to the wrong address!
        POSI.transfer(unclaimedAddress, 1000 ether);
    }

    function deploy(bytes memory code, uint256 salt) public returns (address addr) {
        assembly {
            addr := create2(     // Deploys a contract using create2.
                0,               // wei sent with current call
                add(code, 0x20), // Pointer to code, with skip the assembly prefix
                mload(code),     // Length of code
                salt             // The salt used
            )
            if iszero(extcodesize(addr)) { revert(0, 0) } // Check if contract deployed correctly, otherwise revert.
        }
    }

    function testWhitehatRescue() public {
        vm.deal(whitehat, 10 ether);
        vm.startPrank(whitehat, whitehat);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge4Test -vvvv //
        ////////////////////////////////////////////////////*/

        // bytes memory walletBytecode = type(VaultWalletTemplate).creationCode;
        // bytes memory factoryBytecode = type(VaultFactory).creationCode;
        // console.logBytes(walletBytecode);

        // return abi.encodePacked(bytecode, abi.encode(_owner, _foo));
        // address factoryAddress = FACTORY.deploy(factoryBytecode, 11); 
        // console.logAddress(factoryAddress);

        // console.logAddress(address(FACTORY));
        // address walletAddress = FACTORY.deploy(walletBytecode, 11); 
        // console.logAddress(walletAddress);

        // bytes32 hash = keccak256(
        //     abi.encodePacked(0, address(this), _salt, keccak256(bytecode))
        // );

        // NOTE: cast last 20 bytes of hash to address
        // return address(uint160(uint(hash)));



        //==================================================//
        vm.stopPrank();

        assertEq(POSI.balanceOf(devs), 1000 ether, "devs' POSI balance should be 1000 POSI");
    }
}
