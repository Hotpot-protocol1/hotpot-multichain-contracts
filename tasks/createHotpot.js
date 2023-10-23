const { networks } = require("../networks");
task("create-hotpot", "Creates a hotpot using HotpotFactory")
  .addParam("factory", "Address of the Hotpot factory")
  .setAction(async (taskArgs, hre) => {
    if (network.name === "hardhat") {
      throw Error(
        'This command cannot be used on a local development chain.  Specify a valid network or simulate an Functions request locally with "npx hardhat functions-simulate".'
      );
    }

    try {
      const functionHash = ethers.utils
        .id(
          "deployHotpot((uint256,uint256,uint128,uint16,uint16,uint16,address,address))"
        )
        .slice(0, 10);
      console.log(functionHash);
      const encodedData = ethers.utils.defaultAbiCoder
        .encode(
          [
            [
              "uint256",
              "uint256",
              "uint128",
              "uint16",
              "uint16",
              "uint16",
              "address",
              "address",
            ],
          ],
          [
            [
              "1000000000000000000",
              "100000000000000000",
              "2592000",
              "1",
              "0",
              "100",
              "0x8d4d773df48cd3f827b5f1d3269bd5b057012631",
              "0x9cb889a00dca965d3276e8c5d5a5331b8fa4f089",
            ],
          ]
        )
        .slice(2);
      const data = functionHash + encodedData;
      console.log(data);

      const deployHotpotTx = await ethers.provider.sendTransaction({
        to: taskArgs.factory,
        data: data,
      });
      console.log(
        `\nWaiting 3 blocks for transaction ${deployHotpotTx.hash} to be confirmed...`
      );
      const deployHotpotTxHash = await deployHotpotTx.wait(3);
      console.log("Transaction hash: " + deployHotpotTxHash);
    } catch (error) {
      console.log(error);
    }
  });
