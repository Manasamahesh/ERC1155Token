const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const MarketPlace = artifacts.require('MarketPlace');

module.exports = async function (deployer) {
  const instance = await deployProxy(MarketPlace, [42], { deployer });
  console.log('Deployed', instance.address);
};