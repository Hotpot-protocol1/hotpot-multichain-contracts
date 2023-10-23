const { networks } = require("../../networks");

task("deploy-marketplace", "Deploys Marketplace contract").setAction(
  async (taskArgs, hre) => {
    console.log(`Deploying Marketplace contract to ${network.name}`);

    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }
    const marketplace = await ethers.getContractFactory("Marketplace");
    const marketplaceContract = await marketplace.deploy();

    console.log(
      `\nWaiting 3 blocks for transaction ${marketplaceContract.deployTransaction.hash} to be confirmed...`
    );

    await marketplaceContract.deployTransaction.wait(
      networks[network.name].WAIT_BLOCK_CONFIRMATIONS
    );
    console.log(
      `Marketplace deployed to ${marketplaceContract.address} on ${network.name}`
    );
    console.log("\nVerifying contract...");
    try {
      await run("verify:verify", {
        address: marketplaceContract.address,
        constructorArguments: [],
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
