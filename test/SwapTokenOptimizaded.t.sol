//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "lib/forge-std/src/Test.sol";
import "../src/SwapApp.sol";

contract SwapAppTest is Test {
    SwapApp app;
    
    // Arbitrum addresses (based on your previous contracts)
    address V2Router03 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address user = 0xffa8DB7B38579e6A2D14f9B347a9acE4d044cD54;
    address USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address DAI  = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    // New treasury address (can be arbitrary for testing purposes)
    address treasury = address(0x1234567890123456789012345678901234567890);

    function setUp() public {
        // FIX 1: The constructor now requires both Router AND Treasury
        app = new SwapApp(V2Router03, treasury);
        
        // Labels to identify addresses in console traces upon failure
        vm.label(V2Router03, "Router");
        vm.label(treasury, "Treasury");
        vm.label(USDT, "USDT");
        vm.label(DAI, "DAI");
        vm.label(user, "User");
    }

    function testHasBeenDeployedCorrectly() public view {
        assert(app.V2Router02() == V2Router03);
        // FIX 2: Verify that the treasury address was stored correctly
        assert(app.tesorery() == treasury);
    }

    function testSwapTokenCorrectly() public {
        uint256 amountIn = 5 * 1e6; // 5 USDT (remember USDT has 6 decimals)
        uint256 amountOutMin = 3 * 1e18; // 3 DAI

        // FIX 3: Magically mint tokens to the user for the test (using 'deal')
        deal(USDT, user, amountIn);

        vm.startPrank(user);
        
        IERC20(USDT).approve(address(app), amountIn);
        
        // Using block.timestamp is better than hardcoding old dates
        uint256 deadline = block.timestamp + 1000;
        
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        // FIX 4: Use the NEW function name
        app.swapTokensOptimizaded(amountIn, amountOutMin, path, deadline);
        
        vm.stopPrank();
    }
    
    // Bonus Test: Verify split logic works (Set a very low min to force surplus)
    function testSurplusDistribution() public {
        uint256 amountIn = 5 * 1e6; 
        uint256 amountOutMin = 1; // Request very little to ensure surplus
        
        deal(USDT, user, amountIn);
        
        vm.startPrank(user);
        IERC20(USDT).approve(address(app), amountIn);
        
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        uint256 treasuryBalanceBefore = IERC20(DAI).balanceOf(treasury);

        app.swapTokensOptimizaded(amountIn, amountOutMin, path, block.timestamp + 1000);
        
        uint256 treasuryBalanceAfter = IERC20(DAI).balanceOf(treasury);
        
        // If the "Surplus Splitter" works, the treasury must have gained funds
        assert(treasuryBalanceAfter > treasuryBalanceBefore);
        
        vm.stopPrank();
    }
}
