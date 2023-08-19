// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {DaoVaultImplementation, FactoryDao, IDaoVault} from "../src/7_crystalDAO/crystalDAO.sol";

/*////////////////////////////////////////////////////////////
//          DEFINE ANY NECESSARY CONTRACTS HERE             //
//    If you need a contract for your hack, define it below //
////////////////////////////////////////////////////////////*/

/*////////////////////////////////////////////////////////////
//                     TEST CONTRACT                        //
////////////////////////////////////////////////////////////*/
contract Challenge7Test is Test {
    FactoryDao factory;

    address public whitehat = makeAddr("whitehat");
    address public daoManager;
    uint256 daoManagerKey;

    IDaoVault vault;

    function setUp() public {
        (daoManager, daoManagerKey) = makeAddrAndKey("daoManager");
        factory = new FactoryDao();

        vm.prank(daoManager);
        vault = IDaoVault(factory.newWallet());

        // The vault has reached 100 ether in donations
        deal(address(vault), 100 ether);

        // console.log("----", vault.owner());
    }

    function testHack() public {
        bytes32 digest = keccak256(
            abi.encode(
                keccak256("Exec(address target,uint256 value,bytes memory execOrder,uint256 nonce,uint256 deadline)"),
                daoManager,
                100 ether,
                "",
                0,
                type(uint256).max
            )
        );

        bytes32 finalMessage = keccak256(abi.encodePacked("\x19\x01", vault.getDomainSeparator(), digest));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(daoManagerKey, finalMessage);

        // vm.expectRevert(bytes("Only owner can execute!"));
        vault.execWithSignature(v, r, 0, daoManager, 100 ether, "", type(uint256).max);

        vm.startPrank(whitehat, whitehat);
        /*////////////////////////////////////////////////////
        //               Add your hack below!               //
        //                                                  //
        // terminal command to run the specific test:       //
        // forge test --match-contract Challenge7Test -vvvv //
        ////////////////////////////////////////////////////*/

        //==================================================//
        vm.stopPrank();

        assertEq(daoManager.balance, 100 ether, "The Dao manager's balance should be 100 ether");
    }
}
