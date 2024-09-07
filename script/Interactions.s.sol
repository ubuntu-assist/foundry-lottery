// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract CreateSubscription is Script {
    function run() public {
        createSubscriptionUsingConfig();
    }

    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig config = new HelperConfig();
        address vrfCoordinator = config.getConfig().vrfCoordinator;
        (uint256 subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256, address) {
        console.log("Creating subscription on chainId: ", block.chainid);

        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();

        console.log("Your subscription id is: ", subId);
        console.log(
            "Please update the subscription id your HelperConfig.s.sol"
        );

        return (subId, vrfCoordinator);
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether; // 3 LINK

    function run() public {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public payable {
        HelperConfig config = new HelperConfig();
        address vrfCoordinator = config.getConfig().vrfCoordinator;
        uint256 subscriptionId = config.getConfig().subscriptionId;
        address linkToken = config.getConfig().link;
        fundSubscription(linkToken, vrfCoordinator, subscriptionId);
    }

    function fundSubscription(
        address linkToken,
        address vrfCoordinator,
        uint256 subscriptionId
    ) public payable {
        console.log("Funding subscription: ", block.chainid);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On chainid: ", block.chainid);

        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }
}
