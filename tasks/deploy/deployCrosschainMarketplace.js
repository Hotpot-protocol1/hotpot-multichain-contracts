const { networks } = require("../../networks");

task(
  "deploy-crosschain-marketplace",
  "Deploys CrosschainMarketplace contract"
).setAction(async (taskArgs, hre) => {
  console.log(`Deploying CrosschainMarketplace contract to ${network.name}`);

  if (network.name === "hardhat") {
    throw Error(
      'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
    );
  }
  const crosschainMarketplace = await ethers.getContractFactory(
    "CrosschainMarketplace"
  );
  const gateway = networks[network.name].AXELAR_GATEWAY;
  const gasService = networks[network.name].AXELAR_GAS_SERVICE;
  const wrappedNativeToken = networks[network.name].AXELAR_WRAPPED_NATIVE_TOKEN;
  const symbol = networks[network.name].WRAPPED_TOKEN_SYMBOL;
  const hotpotDeployment = "0x30b5db47421Fc8Db08d1d2a5CD2fC1437378f66b";

  const crosschainMarketplaceContract = await crosschainMarketplace.deploy(
    gasService,
    gateway,
    hotpotDeployment,
    symbol,
    wrappedNativeToken
  );

  console.log(
    `\nWaiting 3 blocks for transaction ${crosschainMarketplaceContract.deployTransaction.hash} to be confirmed...`
  );

  await crosschainMarketplaceContract.deployTransaction.wait(
    networks[network.name].WAIT_BLOCK_CONFIRMATIONS
  );
  console.log(
    `CrosschainMarketplace deployed to ${crosschainMarketplaceContract.address} on ${network.name}`
  );
  console.log("\nVerifying contract...");
  try {
    await run("verify:verify", {
      address: crosschainMarketplaceContract.address,
      constructorArguments: [
        gasService,
        gateway,
        hotpotDeployment,
        symbol,
        wrappedNativeToken,
      ],
    });
    console.log("Contract verified");
  } catch (error) {
    if (!error.message.includes("Already Verified")) {
      console.log(
        "Error verifying contract.  Delete the build folder and try again."
      );
      console.log(error);
    } else {
      console.log("Contract already verified");
    }
  }
});
