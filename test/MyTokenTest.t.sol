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
    }

    function testConstructorParamsSetsSuccess() public view {
        string memory expectedName = "MyToken";
        string memory expectedSymbol = "MY";
        uint8 expectedDecimals = 8;

        string memory name = myToken.name();
        string memory symbol = myToken.symbol();
        uint8 decimals = myToken.decimals();

        assertEq(expectedName, name);
        assertEq(expectedSymbol, symbol);
        assertEq(expectedDecimals, decimals);
    }
}
