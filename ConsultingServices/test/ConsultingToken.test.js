const ConsultingToken = artifacts.require("ConsultingToken");
const truffleAssert = require("truffle-assertions");
const BigNumber = require("bignumber.js");

contract("ConsultingToken", (accounts) => {
    //Enum of status
    const StatusExpected = {
        ForSale: { value: 0, name: "FOR_SALE" },
        Sold: { value: 1, name: "SOLD" },
        Release: { value: 2, name: "RELEASE" }
    };

    let consultingTokenInstance;
    const host = accounts[0];
    const hostName = "YYPL";
    const attendee1 = accounts[1];
    const attendee2 = accounts[2];
    const attendee3 = accounts[3];
    const topic1Expected = "Software Architecture";
    const topic2Expected = "Enterprise Architecture";
    const topic3Expected = "Security";
    const tokenId1 = 0;
    const tokenId2 = 1;
    const tokenId3 = 2;
    let price1Expected = 1;
    let price2Expected = 2;
    let price3Expected = 1;
    const startTime1Expected = 1612105258;
    const endTime1Expected = 1612115258;
    const startTime2Expected = 1611105258;
    const endTime2Expected = 1612105259;
    const startTime3Expected = 1612405258;
    const endTime3Expected = 1612955258;
    const hostcheckedIn = false;
    const statusForSale = StatusExpected.ForSale;
    const statusSold = StatusExpected.Sold;
    const statusRelease = StatusExpected.Release;
    const ownerInital = accounts[0];
    let totalConsultingServices = 3;


    before(async () => {
        consultingTokenInstance = await ConsultingToken.deployed();
    });

    it("create consulting services", async () => {
        //Create consultingService1
        await consultingTokenInstance.createConsultingService(topic1Expected, price1Expected, startTime1Expected, endTime1Expected, hostName, { from: host });

        //Consult information of the tokenId1 which has to be related to the consultingService1
        let consultingService1 = await consultingTokenInstance.tokens.call(tokenId1);

        assert.equal(topic1Expected, consultingService1[1], "The expected topic is wrong");
        assert.equal(price1Expected, consultingService1[2], "The expected price is wrong");
        assert.equal(startTime1Expected, consultingService1[3], "The expected start time is wrong");
        assert.equal(endTime1Expected, consultingService1[4], "The expected end time is wrong");
        assert.equal(hostName, consultingService1[5], "The expected host name is wrong");
        assert.equal(hostcheckedIn, consultingService1[6], "The expected host cheking in flag is wrong");
        assert.equal(statusForSale.value, consultingService1[7], `The expected status ${statusForSale.name} is wrong`);
        assert.equal(host, consultingService1[8], "The expected host chekedin flag is wrong");
        assert.equal(ownerInital, consultingService1[9], `The expected owner is wrong`);

        //Create consultingService2
        await consultingTokenInstance.createConsultingService(topic2Expected, price2Expected, startTime2Expected, endTime2Expected, hostName, { from: host });

        //Consult information of the tokenId1 which has to be related to the consultingService1
        let consultingService2 = await consultingTokenInstance.tokens.call(tokenId2);

        assert.equal(topic2Expected, consultingService2[1], "The expected topic is wrong");
        assert.equal(price2Expected, consultingService2[2], "The expected price is wrong");
        assert.equal(startTime2Expected, consultingService2[3], "The expected start time is wrong");
        assert.equal(endTime2Expected, consultingService2[4], "The expected end time is wrong");
        assert.equal(hostName, consultingService2[5], "The expected host name is wrong");
        assert.equal(hostcheckedIn, consultingService2[6], "The expected host cheking in flag is wrong");
        assert.equal(statusForSale.value, consultingService2[7], `The expected status ${statusForSale.name} is wrong`);
        assert.equal(host, consultingService2[8], "The expected host chekedin flag is wrong");
        assert.equal(ownerInital, consultingService2[9], `The expected owner is wrong`);

        //Create consultingService3
        await consultingTokenInstance.createConsultingService(topic3Expected, price3Expected, startTime3Expected, endTime3Expected, hostName, { from: host });

        //Consult information of the tokenId1 which has to be related to the consultingService1
        let consultingService3 = await consultingTokenInstance.tokens.call(tokenId3);

        assert.equal(topic3Expected, consultingService3[1], "The expected topic is wrong");
        assert.equal(price3Expected, consultingService3[2], "The expected price is wrong");
        assert.equal(startTime3Expected, consultingService3[3], "The expected start time is wrong");
        assert.equal(endTime3Expected, consultingService3[4], "The expected end time is wrong");
        assert.equal(hostName, consultingService3[5], "The expected host name is wrong");
        assert.equal(hostcheckedIn, consultingService3[6], "The expected host cheking in flag is wrong");
        assert.equal(statusForSale.value, consultingService3[7], `The expected status ${statusForSale.name} is wrong`);
        assert.equal(host, consultingService3[8], "The expected host chekedin flag is wrong");
        assert.equal(ownerInital, consultingService3[9], `The expected owner is wrong`);
    });

    it("consult total consulting services", async () => {
        let totalC = await consultingTokenInstance.totalConsultingServices();
        assert.equal(totalConsultingServices, totalC, `The total consulting services expected was ${totalConsultingServices} is wrong`);
    });

    it("consult owner of a token", async () => {
        let ownerToken1 = await consultingTokenInstance.ownerOfToken(tokenId1);
        assert.equal(ownerInital, ownerToken1, "The initial owner is wrong");
    });

    it("Consult balance of an address", async () => {
        let balanceInitialOwner = await consultingTokenInstance.balanceOfAddress(ownerInital);
        assert.equal(totalConsultingServices, balanceInitialOwner, "The balance of the initial owner is wrong");
    });

    //Approve tokenId1 to attendee1 by ownerInitial 
    it("Approve a token by owner with status: for sale", async () => {
        let tx = await consultingTokenInstance.approveTransferToken(attendee1, tokenId1, { from: ownerInital });

        //validate event approve
        truffleAssert.eventEmitted(tx, "Approval", event => (
            new BigNumber(event.tokenId).isEqualTo(new BigNumber(tokenId1))
            && event.approved === attendee1
            && event.owner === ownerInital
          ));

        //validate approve
        let approved = await consultingTokenInstance.getApproved(tokenId1);
        assert.equal(attendee1, approved, "The attendee has not been approved");
    });

    //Attendee1 buys the tokenId1 that was approved by ownerInitial
    it("Buy a token for an attendee", async () => {
        //Consult the owner of token1 before being buying by attendee1
        let ownerToken1 = await consultingTokenInstance.ownerOfToken(tokenId1);
        assert.equal(ownerInital, ownerToken1, "The initial owner is wrong");

        //Consult balance of attendee before buying tokenId1
        let balanceAttendee1 = await consultingTokenInstance.balanceOfAddress(attendee1);
        assert.equal(0, balanceAttendee1, "The balance of the attendee1 is wrong");

        let tx= await consultingTokenInstance.buyConsultingService(tokenId1, { from: attendee1, value: price1Expected });

        //validate the event Transfer
        truffleAssert.eventEmitted(tx, "Transfer", event => (
            new BigNumber(event.tokenId).isEqualTo(new BigNumber(tokenId1))
            && event.to === attendee1
          ));

        //Consult the owner of token1 after attendee1 bought the token1
        ownerToken1 = await consultingTokenInstance.ownerOfToken(tokenId1);
        assert.equal(attendee1, ownerToken1, `The owner should be ${attendee1}`);

        //Consult balance of attendee after buying tokenId1
        balanceAttendee1 = await consultingTokenInstance.balanceOfAddress(attendee1);
        assert.equal(1, balanceAttendee1, "The balance of the attendee1 is wrong");

        //Consult the new balance of owner initial
        let balanceOwnerInitial = await consultingTokenInstance.balanceOfAddress(ownerInital);

        //update the number of consulting services of the initial owner
        totalConsultingServices = totalConsultingServices - 1;

        assert.equal(totalConsultingServices, balanceOwnerInitial, "The balance of the owner initial is wrong");

    });

    //Approved the rest of the tokens (2) of owner initial to attendee2
    it("Approve all tokens by owner to an attendee", async () => {
        let tx = await consultingTokenInstance.approvalTransferTokenForAll(attendee2, { from: ownerInital });

        //validate event approveForAll
        truffleAssert.eventEmitted(tx, "ApprovalForAll", event => (
            event.approved === true
            && event.operator === attendee2
            && event.owner === ownerInital
          ));

        let approved = await consultingTokenInstance.isApprovedForAll(ownerInital, attendee2);
        assert.equal(true, approved, "The attendee has not been approved for all the tokens");
    });

    //Attendee2 buys the tokenId2 and tokenId3 that were approvedAll by ownerInitial
    it("Buy a token for an attendee that was approvedAll", async () => {
        //Consult the owner of token2 before to buy by attendee2
        let ownerToken2 = await consultingTokenInstance.ownerOfToken(tokenId2);
        assert.equal(ownerInital, ownerToken2, "The initial owner is wrong");

        //Consult the owner of token3 before to buy by attendee2
        let ownerToken3 = await consultingTokenInstance.ownerOfToken(tokenId3);
        assert.equal(ownerInital, ownerToken3, "The initial owner is wrong");

        //Consult balance of attendee2 before buying tokenId2 and tokenId3
        let balanceAttendee2 = await consultingTokenInstance.balanceOfAddress(attendee2);
        assert.equal(0, balanceAttendee2, "The balance of the attendee2 is wrong");

        await consultingTokenInstance.buyConsultingService(tokenId2, { from: attendee2, value: price2Expected });
        await consultingTokenInstance.buyConsultingService(tokenId3, { from: attendee2, value: price3Expected });

        //Consult the owner of token2 after attendee2 bought the token2
        ownerToken2 = await consultingTokenInstance.ownerOfToken(tokenId2);
        assert.equal(attendee2, ownerToken2, `The owner should be ${attendee2}`);

        //Consult the owner of token3 after attendee2 bought the token3
        ownerToken3 = await consultingTokenInstance.ownerOfToken(tokenId3);
        assert.equal(attendee2, ownerToken3, `The owner should be ${attendee2}`);

        //Consult balance of attendee2 after buying tokenId2 and tokenId3
        balanceAttendee2 = await consultingTokenInstance.balanceOfAddress(attendee2);
        assert.equal(2, balanceAttendee2, "The balance of the attendee2 is wrong");

        //Consult the new balance of owner initial
        //update the number of consulting services of the initial owner
        totalConsultingServices = totalConsultingServices - 2;
        let balanceOwnerInitial = await consultingTokenInstance.balanceOfAddress(ownerInital);
        assert.equal(totalConsultingServices, balanceOwnerInitial, "The balance of the owner initial is wrong");

    });

    //Attendee2 resell the tokenId2 
    it("resell a consulting service", async () => {

        //Previous status:SOLD
        let consultingService2 = await consultingTokenInstance.tokens.call(tokenId2);
        assert.equal(statusSold.value, consultingService2[7], `The expected status ${statusSold.name} is wrong`);

        //Previous price
        assert.equal(price2Expected, consultingService2[2], "The previous price is wrong");

        //Increase the price of tokenId2
        price2Expected++;

        await consultingTokenInstance.resellConsultingService(tokenId2, price2Expected, {from:attendee2});

        //New status:FOR_SALE
        consultingService2 = await consultingTokenInstance.tokens.call(tokenId2);
        assert.equal(statusForSale.value, consultingService2[7], `The expected status ${statusForSale.name} is wrong`);

        //New price = previous price+1
        assert.equal(price2Expected, consultingService2[2], "The new price is wrong");

        //attendee2 aproves attendee3 for buying tokenId2
        await consultingTokenInstance.approveTransferToken(attendee3, tokenId2, { from: attendee2 });

        //attendee3 buys tokenId2
        await consultingTokenInstance.buyConsultingService(tokenId2, { from: attendee3, value: price2Expected });

        //Consult the owner of token2 after being buying by attendee3
        let ownerToken2 = await consultingTokenInstance.ownerOfToken(tokenId2);
        assert.equal(attendee3, ownerToken2, "The new owner of the token2 is wrong");

        //New status:SOLD
        consultingService2 = await consultingTokenInstance.tokens.call(tokenId2);
        assert.equal(statusSold.value, consultingService2[7], `The expected status ${statusSold.name} is wrong`);

    });

    //Attendee3 release the tokenId2 
    it("release a consulting service", async () => {
        await consultingTokenInstance.releaseStatus(tokenId2, {from: attendee3});

        //New status:RELEASE
        let consultingService2 = await consultingTokenInstance.tokens.call(tokenId2);
        assert.equal(statusRelease.value, consultingService2[7], `The expected status ${statusRelease.name} is wrong`);

        //Validate hostCheckedIn 
        assert.equal(true, consultingService2[6], "The expected host chekedin flag is wrong");
    });

});