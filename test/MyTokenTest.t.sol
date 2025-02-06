// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployMyToken;
    uint256 public constant STARTING_BALANCE = 10 ether;

    address USER = makeAddr("USER");
    address PLAYER = makeAddr("PLAYER");

    function setUp() external {
        deployMyToken = new DeployMyToken();
        myToken = deployMyToken.run();

        vm.prank(msg.sender);
        myToken.transfer(USER, STARTING_BALANCE);
    }

    function testUserBalance() public view {
        assertEq(STARTING_BALANCE, myToken.balanceOf(USER));
    }

    function testAllowenceWorks() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // USER apprives PLAYER to spent tokens on his behalf
        vm.prank(USER);
        myToken.approve(PLAYER, initialAllowance);

        vm.prank(PLAYER);
        myToken.transferFrom(USER, PLAYER, transferAmount);

        assertEq(myToken.balanceOf(PLAYER), transferAmount);
        assertEq(myToken.balanceOf(USER), STARTING_BALANCE - transferAmount);
    }
}
