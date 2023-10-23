const { networks } = require("../../networks");

task("deploy-hotpot-factory", "Deploys Hotpot Factory contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying Hotpot Factory contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const hotpotFactory = await ethers.getContractFactory("HotpotFactory");
    const hotpotImplementation = "0xf04a238705B726Bcb1eeC39d8B7529944376C6c3";
    const hotpotFactoryContract = await hotpotFactory.deploy(
      hotpotImplementation
    );

    console.log(
      `\nWaiting 3 blocks for transaction ${hotpotFactoryContract.deployTransaction.hash} to be confirmed...`
    );

    await hotpotFactoryContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log(
      `Hotpot Factory deployed to ${hotpotFactoryContract.address} on ${network.name}`
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: hotpotFactoryContract.address,
        constructorArguments: [hotpotImplementation],
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
