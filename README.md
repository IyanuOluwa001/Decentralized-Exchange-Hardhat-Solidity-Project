# Decentralized-Exchange-Hardhat-Solidity-Project
Welcome to my Decentralized Exchange (DEX) project, a Uniswap V1-style automated market maker (AMM), with full swap function, wallet connectivity, and a graph representing the swap relationship between tokens. Deployed on the Sepolia testnet, this DEX enables users to swap ETH for $BAL tokens, add/remove liquidity, and view transaction events in a Next.js frontend. This project showcases a secure, functional DeFi application with robust smart contracts and a user-friendly interface.

🚀 Features
Token Swaps: Seamlessly swap ETH for $BAL (Balloons token) and vice versa using a constant product AMM formula (x * y = k).
Liquidity Provision: Add or remove liquidity (ETH and $BAL) to the pool, earning liquidity provider tokens (LPTs).
Event Tracking: View real-time transaction events (e.g., LiquidityProvided, EthToTokenSwap, TokenToEthSwap) on the /events page.
Debug Interface: Interact directly with contract functions via the /debug page for testing and manual calls.
Responsive Frontend: Built with Next.js, the UI is deployed on Vercel for a smooth, accessible experience.
Sepolia Integration: Fully connected to the Sepolia testnet for safe, cost-effective testing.
Wallet Support: Integrates with MetaMask and WalletConnect for secure user interactions.

🛠 Smart Contract Functions
The DEX contract (0x9957706d499aB3F2945321e78154Ae704EA29d65) is paired with the Balloons ERC20 token (0x678596a0B16d7E547d54F8fD7Ada198f22F568ac). Key functions include:

init(uint256 _tokenAmount): Initializes the liquidity pool with an initial deposit of ETH and $BAL, setting the pool’s ratio (e.g., 0.05 ETH and 0.05 BAL).
deposit(uint256 _tokenAmount) payable: Adds liquidity by depositing ETH (msg.value) and $BAL tokens at the pool’s current ratio. Mints LPTs proportional to the contribution and tracks them via liquidity[provider] and totalLiquidity.
withdraw(uint256 _amount): Removes liquidity, burning LPTs and returning proportional ETH and $BAL to the provider.
ethToToken(uint256 _minTokens): Swaps ETH for $BAL tokens, ensuring the user receives at least _minTokens (slippage protection).
tokenToEth(uint256 _tokenAmount, uint256 _minEth): Swaps $BAL for ETH, with slippage protection.
getLiquidity(address _provider) view: Returns the LPT balance for a provider.
price(uint256 _inputAmount, uint256 _inputReserve, uint256 _outputReserve) view: Calculates swap output based on reserves and fees.

Events emitted:
LiquidityProvided(address provider, uint256 ethAmount, uint256 tokenAmount, uint256 liquidityMinted)
EthToTokenSwap(address swapper, uint256 ethAmount, uint256 tokenAmount)
TokenToEthSwap(address swapper, uint256 tokenAmount, uint256 ethAmount)

🔒 Security Measures:
Security is a top priority to protect users and maintain trust in the DEX:

Environment Variable Protection: .env files (packages/hardhat/.env, packages/nextjs/.env.local) are excluded from version control via .gitignore to safeguard private keys and API keys.
Contract Verification: Both Balloons and DEX contracts are verified on Sepolia Etherscan for transparency and auditability.
Safe Token Transfers: Uses OpenZeppelin’s IERC20 for secure $BAL token interactions (e.g., approve, transferFrom).
Ratio Enforcement: The deposit function enforces the pool’s ETH/$BAL ratio to prevent manipulation.
Gas Optimization: Functions are designed to minimize gas costs while maintaining functionality.
Frontend Security: Environment variables (NEXT_PUBLIC_ALCHEMY_API_KEY, NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID) are securely managed via Vercel’s dashboard.

🏗 Setup and Installation
To run or test the DEX locally or deploy your own instance:

Prerequisites:
Node.js (v16+)
Yarn
MetaMask (configured for Sepolia)
Sepolia ETH (get from https://sepoliafaucet.com)
Alchemy account (for Sepolia RPC)

Testing

Swap Tokens: Use the main page to swap ETH for $BAL or vice versa.
Add Liquidity: Deposit ETH and $BAL via the UI or /debug page.
View Events: Check /events for transaction history (optimized with fromBlock).
Debug: Use /debug to interact with contract functions directly.

📍 Live Deployment

Frontend: https://dex-challenge-beta.vercel.app
Balloons Contract: 0x678596a0B16d7E547d54F8fD7Ada198f22F568ac
DEX Contract: 0x9957706d499aB3F2945321e78154Ae704EA29d65

🤝 Contributing
Contributions are welcome! Fork the repo, make changes, and submit a pull request. Ensure .env files remain secure and test on Sepolia before deploying.
📜 License
This project is licensed under the MIT License.
