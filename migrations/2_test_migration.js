var ContractERC721 = artifacts.require("ContractERC721");

module.exports = function(deployer) {
    deployer.deploy(ContractERC721);
};