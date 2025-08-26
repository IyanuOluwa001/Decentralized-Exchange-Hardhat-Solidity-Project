// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    /* ========== GLOBAL VARIABLES ========== */
    
    IERC20 token;

    uint256 public totalLiquidity; // Tracks total LPTs
    mapping(address => uint256) public liquidity; //  Tracks user LPTs

    /* ========== EVENTS ========== */

    event EthToTokenSwap(address swapper, uint256 tokenOutput, uint256 ethInput);
    event TokenToEthSwap(address swapper, uint256 tokensInput, uint256 ethOutput);
    event LiquidityProvided(address liquidityProvider, uint256 liquidityMinted, uint256 ethInput, uint256 tokensInput);
    event LiquidityRemoved(address liquidityRemover, uint256 liquidityWithdrawn, uint256 tokensOutput, uint256 ethOutput);

    /* ========== CONSTRUCTOR ========== */

    constructor(address tokenAddr) {
        token = IERC20(tokenAddr);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function init(uint256 tokens) public payable returns (uint256) {
        require(totalLiquidity == 0, "DEX already initialized");
        require(msg.value > 0 && tokens > 0, "Must provide ETH and tokens");

        totalLiquidity = address(this).balance;
        liquidity[msg.sender] = totalLiquidity;


        bool success = token.transferFrom(msg.sender, address(this), tokens);
        require(success, "Token transfer failed");

        return totalLiquidity;
    }

    function price(uint256 xInput, uint256 xReserves, uint256 yReserves)
        public pure returns (uint256 yOutput) {
        require(xReserves > 0 && yReserves > 0, "No liquidity");
        uint256 inputWithFee = xInput * 997;
        uint256 numerator = inputWithFee * yReserves;
        uint256 denominator = (xReserves * 1000) + inputWithFee;
        return numerator / denominator;
    }

    function getLiquidity(address lp) public view returns (uint256) {
        return liquidity[lp]; // ✅ Required for frontend compatibility
    }

    function ethToToken() public payable returns (uint256 tokenOutput) {
        require(msg.value > 0, "Send ETH to swap");

        uint256 tokenReserves = token.balanceOf(address(this));
        uint256 ethReserves = address(this).balance - msg.value;

        tokenOutput = price(msg.value, ethReserves, tokenReserves);

        bool success = token.transfer(msg.sender, tokenOutput);
        require(success, "Token transfer failed");

        emit EthToTokenSwap(msg.sender, tokenOutput, msg.value);
    }

    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {
        require(tokenInput > 0, "Must input tokens");

        uint256 tokenReserves = token.balanceOf(address(this));
        uint256 ethReserves = address(this).balance;

        ethOutput = price(tokenInput, tokenReserves, ethReserves);

        bool success = token.transferFrom(msg.sender, address(this), tokenInput);
        require(success, "Token transfer failed");

        (bool sent, ) = payable(msg.sender).call{value: ethOutput}("");
        require(sent, "ETH transfer failed");

        emit TokenToEthSwap(msg.sender, tokenInput, ethOutput);
    }

    function deposit() public payable returns (uint256 tokensDeposited) {
        require(msg.value > 0, "Must send ETH");

        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenAmount = (msg.value * tokenReserve) / ethReserve;

        tokensDeposited = tokenAmount;

        bool success = token.transferFrom(msg.sender, address(this), tokenAmount);
        require(success, "Token transfer failed");

        uint256 liquidityMinted = (msg.value * totalLiquidity) / ethReserve;
        liquidity[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;

        emit LiquidityProvided(msg.sender, liquidityMinted, msg.value, tokenAmount);
    }

    function withdraw(uint256 amount) public returns (uint256 ethAmount, uint256 tokenAmount) {
        require(amount > 0, "Must withdraw > 0");
        require(liquidity[msg.sender] >= amount, "Insufficient liquidity");
     uint256 ethReserve = address(this).balance;
        uint256 tokenReserve = token.balanceOf(address(this));

        ethAmount = (amount * ethReserve) / totalLiquidity;
        tokenAmount = (amount * tokenReserve) / totalLiquidity;

        liquidity[msg.sender] -= amount;
        totalLiquidity -= amount;

        (bool sentEth, ) = payable(msg.sender).call{value: ethAmount}("");
        require(sentEth, "ETH transfer failed");

        bool sentToken = token.transfer(msg.sender, tokenAmount);
        require(sentToken, "Token transfer failed");

        emit LiquidityRemoved(msg.sender, amount, tokenAmount, ethAmount);
        }
}