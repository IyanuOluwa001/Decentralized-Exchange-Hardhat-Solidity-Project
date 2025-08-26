import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { DEX } from "../typechain-types/contracts/DEX";
import { Balloons } from "../typechain-types/contracts/Balloons";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // 1️ Deploy Balloons
  const balloonsDeploy = await deploy("Balloons", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
  });
  const balloons: Balloons = await hre.ethers.getContract("Balloons", deployer);
  const balloonsAddress = await balloons.getAddress();

  // 2 Deploy DEX
  await deploy("DEX", {
    from: deployer,
    args: [balloonsAddress],
    log: true,
    autoMine: true,
  });
  
  const dex = (await hre.ethers.getContract("DEX", deployer)) as DEX;
  const dexAddress = await dex.getAddress();

  // 3️ Send some Balloons to frontend test wallet
  await (await balloons.transfer("0xC602A9a0286F2E04A3Af8B51f652310b8Ed89a7E", hre.ethers.parseEther("10"))).wait();

  // 4️ Approve DEX to spend deployer's Balloons
  console.log(`Approving DEX (${dexAddress}) to take Balloons from main getAccountPath...`);
  const approveTx = await balloons.approve(dexAddress, hre.ethers.parseEther("100"));
  await approveTx.wait(); // ✅ Wait for mining

  // 5 Init DEX
  console.log("Initializing exchange...");
  const feeData = await hre.ethers.provider.getFeeData();
  const currentNonce = await hre.ethers.provider.getTransactionCount(deployer, "latest");

  const initTx = await dex.init(hre.ethers.parseEther("0.05"), {
    value: hre.ethers.parseEther("0.05"),
    gasLimit: 300000,
    maxFeePerGas: feeData.maxFeePerGas,
    maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
    nonce: currentNonce,
  });

  await initTx.wait();
  console.log("DEX Initialized!");
};

export default deployYourContract;
deployYourContract.tags = ["Balloons", "DEX"];