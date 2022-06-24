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
```

Depending on your local settings you might need to update the truffle.congi.js file in order to et your environment variable matching the project config.

```bash
truffle migrate
truffle test
```

## Test coverage

Test have been organized with nested describe. Each describe focus on a specific state of the voting session.
Hook before and after have been used to manage the configuration of the voting session in order to get revelant unit test without too much manipulation within the test functions.

### Registration

testing fucntions can be found under the following structure :

```JS
describe("registration", function () {...}
```

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

```

```
