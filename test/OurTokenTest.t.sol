// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public  ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether; 
    uint256 public constant TRANSFER_AMOUNT = 50 ether; 

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob,STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initalAllowance = 1000;

        // Bob approves alice to spend money on her behalf 
        vm.prank(bob);
        ourToken.approve(alice,initalAllowance);
        // Now alice will take all of bobs money

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice),transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE-transferAmount);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }


    function testTransferFailsIfInsufficientBalance() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(alice, STARTING_BALANCE + 1);
    }
 

}