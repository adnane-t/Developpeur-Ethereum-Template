## About The Project

First challenge of my blockchain dev training

Goals was to set up a working votting dapps matching some specific requirement


### Built With

* [solidity]
* [remix]
* [Ganache]
* [MateMaks]


<p align="right">(<a href="#top">back to top</a>)</p>




## Usage

I did try to set up the contract in a way so different session can be managed at the same time. Therefore in addition to the requested structure I did add a specific struct :
```
 struct Session {
      uint winningProposalId;
      bool winnerDefined;
  }
  ```
 
 This would have make it easier to upgrade the dapp in order to have multiple sessions at the same time or to have differents voters liste based on the voting session.
 Also it would have allowed to add some specific rules based on the session (allo blank vote for instance).


## Roadmap of expected features (and achievement based on my testing session)

- [x] Admin register a white list of voters
- [x] Voters suggest proposals
- [x] Voter can vote for they prefered proposal
- [ ] A winning proposal is determined based on the vote calculation
- [ ] Everyone can check the voting resulst and voters details
- [x] Only the admin can manage the voting session


Unfortunately I did not manage to make the calculation works so I haven't been able to make sure that the check of the vote is working propoerly.
I haven' been able to sort it out on time but I suspect the issue to be linked to my object sessions that might not be well initialised when I call it for voting calculation registration.




