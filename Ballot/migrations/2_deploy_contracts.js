const Ballot = artifacts.require("Ballot");

module.exports = function (deployer){
    deployer.deploy(
        Ballot, 
        2
    );
};