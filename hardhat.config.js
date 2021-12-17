require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');

module.exports = {
    solidity: {
        version: "0.8.3",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    defaultNetwork: "localhost",
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    }, 
    mocha: {
        timeout: 20000
    }
}
