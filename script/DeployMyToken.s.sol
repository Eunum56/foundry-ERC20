// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployMyToken is Script {
    uint256 private constant INITIAL_SUPPLY = 1000 ether;
    function run() external returns (MyToken) {
        vm.startBroadcast();
        MyToken myToken = new MyToken("MyToken", "MY", 8, 1000);
        vm.stopBroadcast();
        return myToken;
    }
}
