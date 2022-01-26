const MarketPlace = artifacts.require('./ERC1155MarketPlace.sol');

module.exports = function (deployer) {
    deployer.deploy(MarketPlace);
  };
