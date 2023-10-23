const { networks } = require("../../networks");

task("deploy-axelar", "Deploys Axelar contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying Axelar contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const axelar = await ethers.getContractFactory("Axelar");
    const gateway = networks[network.name].AXELAR_GATEWAY;
    const gasService = networks[network.name].AXELAR_GAS_SERVICE;
    const wrappedNativeToken =
      networks[network.name].AXELAR_WRAPPED_NATIVE_TOKEN;
    const symbol = networks[network.name].WRAPPED_TOKEN_SYMBOL;
    const axelarContract = await axelar.deploy(
      gateway,
      gasService,
      wrappedNativeToken,
      symbol,
      {
        gasPrice: 50000,
      }
    );

    console.log(
      `\nWaiting 3 blocks for transaction ${axelarContract.deployTransaction.hash} to be confirmed...`
    );

    await axelarContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log(
      `Axelar deployed to ${axelarContract.address} on ${network.name}`
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: axelarContract.address,
        constructorArguments: [gateway, gasService, wrappedNativeToken, symbol],
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
  }
);
