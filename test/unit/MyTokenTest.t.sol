// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    uint256 public constant STARTING_BALANCE = 10 ether;

    address OWNER = makeAddr("OWNER");
    address USER = makeAddr("USER");

    // EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function setUp() external {
        vm.prank(OWNER);
        myToken = new MyToken("MyToken", "MY", 8, 1000);
    }

    // CONSTRUCTOR TESTS
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

    function testConstructorRevertsMaxSupplyReverts() public {
        vm.expectRevert(MyToken.MyToken__MaxSupplyExceeds.selector);
        MyToken localMyToken = new MyToken("MyToken", "MY", 8, 1_000_000_0 * 10 ** 18);
    }

    function testConstructorEmitAndSetsOwnerAndBalance() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), address(USER), 1000);
        vm.prank(USER);
        MyToken localMyToken = new MyToken("MyToken", "MY", 8, 1000);

        address expectedOwner = localMyToken.getOwner();
        assertEq(expectedOwner, address(USER));

        assertEq(localMyToken.balanceOf(USER), 1000);
    }

    // MINT FUNCTION TESTS
    function testMintFunctionAllReverts() public {
        vm.prank(OWNER);
        vm.expectRevert(MyToken.MyToken__MaxSupplyExceeds.selector);
        myToken.mint(OWNER, 1_000_000 * 10 ** 18);

        vm.prank(OWNER);
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        myToken.mint(address(0), 1000);

        vm.expectRevert(MyToken.MyToken__NotOwner.selector);
        myToken.mint(address(0), 1000);
    }

    function testMintUpdateBalanceAndTotalSupplyAndEmitEvent() public {
        vm.prank(OWNER);
        myToken.mint(USER, 1000);
        assertEq(myToken.balanceOf(USER), 1000);
        assertEq(myToken.totalSupply(), 2000);

        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), OWNER, 1000);
        myToken.mint(OWNER, 1000);
    }

    function testMintMoreTokensToExistingAddress() public {
        vm.prank(OWNER);
        myToken.mint(OWNER, 1000);
        assertEq(myToken.balanceOf(OWNER), 2000);
        assertEq(myToken.totalSupply(), 2000);
    }

    // BURN FUNCTION TESTS
    function testBurnReverts() public {
        vm.prank(OWNER);
        vm.expectRevert(MyToken.MyToken__NotEnoughTokens.selector);
        myToken.burn(2000);
    }

    function testBurnUpdatesBalancesAndTotalSupplyAndEmitEvent() public {
        vm.prank(OWNER);
        myToken.burn(200);
        assertEq(myToken.balanceOf(OWNER), 800);
        assertEq(myToken.totalSupply(), 800);

        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(OWNER, address(0), 300);
        myToken.burn(300);
    }

    function testBurnToZero() public {
        vm.prank(OWNER);
        myToken.burn(1000);
        assertEq(myToken.balanceOf(OWNER), 0);
        assertEq(myToken.totalSupply(), 0);
    }

    // TRANSFER FUNCTION TESTS
    function testTransferAllReverts() public {
        vm.prank(OWNER);
        vm.expectRevert(MyToken.MyToken__NotEnoughTokens.selector);
        myToken.transfer(USER, 1200);

        vm.prank(OWNER);
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        myToken.transfer(address(0), 200);
    }

    function testTransferUpdatesBalancesAndEmitEvent() public {
        vm.prank(OWNER);
        myToken.transfer(USER, 300);
        assertEq(myToken.balanceOf(OWNER), 700);
        assertEq(myToken.balanceOf(USER), 300);

        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(OWNER, USER, 100);
        myToken.transfer(USER, 100);
    }

    function testTransferOwnerBalanceReachZero() public {
        vm.prank(OWNER);
        myToken.transfer(USER, 1000);
        assertEq(myToken.balanceOf(OWNER), 0);
        assertEq(myToken.balanceOf(USER), 1000);
    }

    // APPROVE FUNCTION TESTS
    function testApproveReverts() public {
        vm.prank(OWNER);
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        myToken.approve(address(0), 100);
    }

    function testApproveUpdatesAllowanceAndEmitEvent() public {
        vm.prank(OWNER);
        myToken.approve(USER, 400);
        assertEq(myToken.allowance(OWNER, USER), 400);

        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Approval(OWNER, USER, 400);
        myToken.approve(USER, 400);
    }

    function testApproveZero() public {
        vm.prank(OWNER);
        myToken.approve(USER, 0);
        assertEq(myToken.allowance(OWNER, USER), 0);
    }

    function testApproveOverwrite() public {
        vm.prank(OWNER);
        myToken.approve(USER, 500);
        assertEq(myToken.allowance(OWNER, USER), 500);

        vm.prank(OWNER);
        myToken.approve(USER, 300);
        assertEq(myToken.allowance(OWNER, USER), 300);
    }

    function testApproveEmitEventWhenReapproveWithSameAmmount() public {
        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Approval(OWNER, USER, 500);
        myToken.approve(USER, 500);

        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Approval(OWNER, USER, 500);
        myToken.approve(USER, 500);
    }

    // TRANSFERFROM FUNCTION TESTS
    function testTransferFromAllReverts() public {
        vm.prank(OWNER);
        myToken.approve(USER, 500);
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        vm.startPrank(USER);
        myToken.transferFrom(address(0), USER, 100);
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        myToken.transferFrom(OWNER, address(0), 100);
        vm.stopPrank();

        vm.prank(OWNER);
        myToken.approve(USER, 500);
        vm.expectRevert(MyToken.MyToken__AllowanceExceeds.selector);
        vm.prank(USER);
        myToken.transferFrom(OWNER, USER, 2000);

        vm.prank(OWNER);
        myToken.approve(USER, 3000);
        vm.expectRevert(MyToken.MyToken__NotEnoughTokens.selector);
        vm.prank(USER);
        myToken.transferFrom(OWNER, USER, 2500);
    }

    function testTransferFromUpdateBalances() public {
        vm.prank(OWNER);
        myToken.approve(USER, 300);

        vm.prank(USER);
        myToken.transferFrom(OWNER, USER, 200);

        assertEq(myToken.balanceOf(OWNER), 800);
        assertEq(myToken.balanceOf(USER), 200);
    }

    function testTransferFromUpdateAllowanceAndEmitEvent() public {
        vm.prank(OWNER);
        myToken.approve(USER, 500);

        vm.prank(USER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(OWNER, USER, 300);
        myToken.transferFrom(OWNER, USER, 300);

        assertEq(myToken.allowance(OWNER, USER), 200);
    }

    // INCREASEALLOWANCE FUNCTION TESTS
    function testIncreaseAllowanceReverts() public {
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        myToken.increaseAllowance(address(0), 200);
    }

    function testIncreaseAllowanceuUpdateAllowanceAndEmitEvent() public {
        vm.prank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Approval(OWNER, USER, 100);
        myToken.increaseAllowance(USER, 100);
        assertEq(myToken.allowance(OWNER, USER), 100);
    }

    // DECREASEALLOWANCE FUNCTION TESTS
    function testDecreaseAllowanceAllReverts() public {
        vm.expectRevert(MyToken.MyToken__InvalidAddress.selector);
        myToken.decreaseAllowance(address(0), 200);

        vm.expectRevert(MyToken.MyToken__NotEnoughAllowance.selector);
        vm.prank(OWNER);
        myToken.decreaseAllowance(USER, 100);
    }

    function testDecreaseAllowanceUpdateAllowanceAndEmitEvent() public {
        vm.startPrank(OWNER);
        myToken.approve(USER, 500);
        vm.expectEmit(true, true, false, true);
        emit Approval(OWNER, USER, 400);
        myToken.decreaseAllowance(USER, 100);
        assertEq(myToken.allowance(OWNER, USER), 400);
        vm.stopPrank();
    }
}
