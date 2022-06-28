# Vote System With Unit testing

## Setup

Download the project workspace on your local machine.

```bash
git clone https://github.com/adnane-t/Developpeur-Ethereum-Template.git
cd Developpeur-Ethereum-Template/4.\ Truffle\ \&\ CI-CD/
```

```bash
npm install @openzeppelin/contracts --save-dev
npm install @openzeppelin/test-helpers --save-dev
npm install @truffle/hdwalletprovider --save-dev
npm install --save-dev eth-gas-reporter
```

Depending on your local settings you might need to update the truffle.congi.js file in order to let your environment variable matching the project config.

```bash
ganache
#Those commands need to be runed in a new terminal
truffle migrate
truffle test
```

## Voting.sol file

In order to devlope the test.js file I took the VotingPlus.sol file as a starting point.

In order to close the gap between the two version I did add one fucntion :

```JS
function getWinningProposalsID() external onlyVoters view returns (uint[] memory) {
  return winningProposalsID;
  }
```

This allow to have a public access to the winning proposal ID, which is offered in the voting.sol file by the following varaible declaration :

```
contract Voting is Ownable {

    uint public winningProposalID;
    ...
}
```

A second addition has been done :

```JS
function getAllProposals() external onlyVoters view returns (Proposal[] memory) {
    return proposalsArray;
}
```

It allows to try some extra assertion in the testing file.

## Test coverage

> Test have been organized with nested describe. Each describe focus on a specific state of the voting session.

> Hook before() and after() have been used to manage the configuration of the voting session in order to get revelant unit test without too much manipulation within the test functions itself.

### Registration

testing functions can be found under the following structure :

```JS
describe("REGISTRATION", function () {...}
```

#### List of test case

- AddVoter test list
  - [x] Only Admin can add voters
  - [x] Only add non registered voters
  - [x] Only add voter when voters registration is open
  - [x] Add a voter
- DeleteVoter
  - [x] Only Admin can delete voters
  - [x] Only delete non registered voters
  - [x] Only delete voter when voters registration is open
  - [x] delete a voter

---

### PROPOSAL

testing functions can be found under the following structure :

```JS
describe("PROPOSAL", function () {...}
```

#### List of test case

- AddProposal test list
  - [x] Only voters can add proposal
  - [x] Proposal can't be empty
  - [x] should emit event on addProposal
  - [x] Can add a proposal

---

### VOTING

testing functions can be found under the following structure :

```JS
describe("VOTING", function () {...}
```

#### List of test case

- Voting test list
  - [x] Only voters can vote
  - [x] Proposal has to exist
  - [x] should emit event on setVote
  - [x] Can vote

---

### STATUS

testing functions can be found under the following structure :

```JS
describe("STATUS", function () {...}
```

#### List of test case

- WorkflowStatus test list
  - [x] Can't get back to initial status
  - [x] Can't set inconsistent workflow status
  - [x] Can't begin tally before reaching correct status
  - [x] Only add voter when voters registration is open
  - [x] Only add proposal when proposals registration is open

---

### TALLY

testing functions can be found under the following structure :

```JS
describe("TALLY", function () {...}
```

#### List of test case

- Tally test list
  - [x] Only vote when voting session is open
  - [x] Last status can't be set outside of tally functions
  - [x] Only admin can tally vote
  - [x] Tally vote

---

### Result of eth-Gas-reporter

| Solc version: 0.8.13+commit.abaa5c0e |                   | Optimizer enabled: false |         |  Runs: 200 | Block limit: 6718946 gas |           |
| :----------------------------------- | :---------------- | :----------------------: | :-----: | ---------: | :----------------------: | :-------: |
| Methods                              |                   |                          |         |
|                                      |                   |                          |         |            |                          |
| Contract                             | Method            |           Min            |   Max   |        Avg |         # calls          | eur (avg) |
|                                      |                   |                          |         |            |                          |           |
| Voting                               | addProposal       |          59758           |  76822  |      71134 |            3             |     -     |
| Voting                               | addVoter          |            -             |    -    |      50196 |            9             |     -     |
| Voting                               | deleteVoter       |            -             |    -    |      28231 |            3             |     -     |
| Voting                               | setVote           |          60935           |  78035  |      65210 |            8             |     -     |
| Voting                               | setWorkflowStatus |          31487           |  48587  |      36617 |            10            |     -     |
| Voting                               | tallyDraw         |            -             |    -    |      83853 |            1             |     -     |
| Deployments                          |                   |                          |         | % of limit |                          |
| Voting                               | -                 |            -             | 2720822 |     40.5 % |            -             |
