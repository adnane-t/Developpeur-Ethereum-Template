const Voting = artifacts.require("./Voting.sol");

const { BN, expectRevert, expectEvent } = require("@openzeppelin/test-helpers");

const { expect } = require("chai");

contract("Voting", (accounts) => {
  const ownerAdmin = accounts[0];
  const voter1 = accounts[1];
  const voter2 = accounts[2];
  const voter3 = accounts[3];
  const voter4 = accounts[4];
  const voter5 = accounts[5];

  let VotingInstance;

  describe("registration", function () {
    before(async function () {
      VotingInstance = await Voting.new({ from: ownerAdmin });
      await VotingInstance.addVoter(ownerAdmin, { from: ownerAdmin });
      await VotingInstance.addVoter(voter1, { from: ownerAdmin });
      await VotingInstance.addVoter(voter2, { from: ownerAdmin });
    });

    //expect({b: 2}).to.have.a.property('b');

    // ::::::::::::: REGISTRATION TESTING ::::::::::::: //
    // ------------- REQUIRE -------------------------- //
    it("Only Admin can add voters", async () => {
      await expectRevert(
        VotingInstance.addVoter(voter3, { from: voter2 }),
        "Ownable: caller is not the owner"
      );
    });

    it("Only add non registered voters", async () => {
      await expectRevert(
        VotingInstance.addVoter(voter2, { from: ownerAdmin }),
        "Already registered"
      );
    });

    // ------------- EVENT ---------------------------- //
    it("should emit event on addVoter", async () => {
      expectEvent(
        await VotingInstance.addVoter(voter3, { from: ownerAdmin }),
        "VoterRegistered",
        { voterAddress: voter3 }
      );
    });
    it("should emit event on deleteVoter", async () => {
      expectEvent(
        await VotingInstance.deleteVoter(voter3, { from: ownerAdmin }),
        "VoterRegistered",
        { voterAddress: voter3 }
      );
    });

    // ------------- FUNCTIONS -------------------------- //
    it("Can add a voter.", async () => {
      await VotingInstance.addVoter(voter3, { from: ownerAdmin });

      let registeredVoter = await VotingInstance.getVoter(voter3, {
        from: ownerAdmin,
      });

      expect(registeredVoter.isRegistered).to.be.true;
    });

    it("Can delete a voter.", async () => {
      await VotingInstance.deleteVoter(voter3, { from: ownerAdmin });

      let registeredVoter = await VotingInstance.getVoter(voter3, {
        from: ownerAdmin,
      });

      expect(registeredVoter.isRegistered).to.be.false;
    });

    // ------------- REQUIRE -------------------------- //
    it("Only add voter when voters registration is open", async () => {
      await VotingInstance.setWorkflowStatus(1);
      await expectRevert(
        VotingInstance.addVoter(voter3, { from: ownerAdmin }),
        "Voters registration is not open yet"
      );
    });
  });
});
