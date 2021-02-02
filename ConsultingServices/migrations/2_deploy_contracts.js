const ConsultingToken = artifacts.require("ConsultingToken");

module.exports = function (deployer){
    deployer.deploy(ConsultingToken);
};