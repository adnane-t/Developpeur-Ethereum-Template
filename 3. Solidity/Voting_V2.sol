// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
    /*
    /   Part 1 - First we set the differents objecte that will be used to organize the voting session
    /
    */
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        bool hasProposed;
        uint votedProposalId;
        //uint[] votedProposalId; //ultimately we would keep track of each vote for each session
    }

    struct Proposal {
        string description;
        uint voteCount;
        //address[] public proposalVoters //ultimately we would keep track of each voters for each proposal
        uint sessionId;
    }
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied,
        sessionOnHold //allow to end a specific period without jumping to the next one directly, this status could be handy when dealing with multiple session at the same time
    }
    /**
    * Strcuture dedeciated to voting session management
    * ultimately workflow status could have been managed from here allowing multiple session ongoing at the same time
    */
    struct Session {
        uint winningProposalId;
        bool winnerDefined;
        string sessionName;
    }

    mapping (address => Voter) authorizedVoters;

    Proposal[] public proposals;
    address [] private listOfVoters; //used to clean up the mapping of voter at the end of the voting session
    Session[] public sessions;
    uint sessionIdNonce = 0; //incremented each time a new session is declared
    WorkflowStatus public currentSessionState = WorkflowStatus.sessionOnHold; //Default state is on hold Admin has to start the registration for the vote

    event VoterRegistered(address voterAddress); 
    event VoterUnRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);


   /**
    *   Part 2 - We define the admin fucntions 
    *
    */

    /** 
     * Adding a voter to  the white list
     * @param _address of the voter
     */
    function authorizeVoters(address _address) public onlyOwner{
        require(currentSessionState == WorkflowStatus.RegisteringVoters, "Voters registration period not opened");
        require(!authorizedVoters[_address].isRegistered, "This address is already authorized to vote !");
        authorizedVoters[_address].isRegistered = true;
        listOfVoters.push(_address);
        emit VoterRegistered(_address);
    }
    /** 
     * remove a voter from the white list if needed
     * @param _address of the voter
     */
    function unAuthorizeVoters(address _address) public onlyOwner{
        require(currentSessionState == WorkflowStatus.RegisteringVoters, "Voters registration period not opened");
        require(authorizedVoters[_address].isRegistered, "This address is already not authorized to vote !");
        delete authorizedVoters[_address];
        uint index = uint(findElementInArray(_address));
        delete listOfVoters[index];
        emit VoterUnRegistered(_address);
    }
    /** 
     * check if a voter is allowed to vote
     * @param _address of the voter
     */
    function isWhitelisted(address _address) public view onlyOwner returns(bool) {
        return authorizedVoters[_address].isRegistered;
    }
    /** 
     * check current session status
     */
    function getCurrentSessionState() public view onlyOwner returns(WorkflowStatus) {
        return currentSessionState;
    }
    /** 
     * check current session ID
     */
    function getCurrentSessionId() public view onlyOwner returns(uint) {
        return sessionIdNonce;
    }
    /** 
     * Start voters registration
     */
    function startVotersRegistration() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.RegisteringVoters;

        sessions.push(Session(0, false,'test'));    //Session nam will be handled dynamicaly afterward  

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.VotesTallied);
    }
    /** 
     * Start proposal registration
     */
    function startProposalsRegistration() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.ProposalsRegistrationStarted;

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.VotesTallied);
    }
    /** 
     * End a proposal registration
     */
    function endProposalsRegistration() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.ProposalsRegistrationEnded;

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.VotesTallied);
    }
    /** 
     * Start a voting session
     */
    function startVotingSession() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.VotingSessionStarted;

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.VotesTallied);
    }
    /** 
     * End a voting session
     */
    function endVotingSession() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.VotingSessionEnded;

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.VotesTallied);
    }
    /** 
     * Compute winner ID for a session
     */
    function VotesTallied() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.VotesTallied;

        closeVotingSession(sessionIdNonce);
        //To prepare the next voting session we need to set the session id nonce to the next index and clean the voters list
        sessionIdNonce +=1;
        for(uint i; i<listOfVoters.length; i++){
                delete(authorizedVoters[listOfVoters[i]]);
                delete listOfVoters[i];
        }

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.VotesTallied);        
    }
    /** 
     * Set a votting session on hold
     */
    function onHoldSession() public onlyOwner {
        WorkflowStatus previousStatus = currentSessionState;
        currentSessionState = WorkflowStatus.sessionOnHold;

        emit WorkflowStatusChange(previousStatus, WorkflowStatus.sessionOnHold);
    }

    /**
     *   Part 3 - We define the public fucntions 
     *
     */

    /**
     * Allow voters to add a proposal.
     * @param _description of the proposal
     */
    function addProposal(string memory _description) external {
        require(currentSessionState == WorkflowStatus.ProposalsRegistrationStarted, "Proposition registration period not opened");
        require(authorizedVoters[msg.sender].isRegistered, "You have not been registered for this voting session");
        require(!authorizedVoters[msg.sender].hasProposed, "You have already pushed a proposal.");

        proposals.push(Proposal(_description, 0, sessionIdNonce));
        authorizedVoters[msg.sender].hasProposed = true;
        
        uint proposalId = proposals.length-1;

        emit ProposalRegistered(proposalId);
    }  

    /**
     * Allow voters to select a proposal.
     * @param _proposal index of proposal in the proposals array
     */
    
    function vote(uint _proposal) external {
        require(currentSessionState == WorkflowStatus.VotingSessionStarted, "Voting period not opened");
        require(authorizedVoters[msg.sender].isRegistered, "You have not been registered for this voting session");
        require(!authorizedVoters[msg.sender].hasVoted, "You have already voted.");
        require(_proposal <= proposals.length, "Please refere to an existing proposal");
        require(proposals[_proposal].sessionId == sessionIdNonce, "This proposal do not belong to the current voting session."); // With this check in place we also reject blank vote

        authorizedVoters[msg.sender].hasVoted = true;
        authorizedVoters[msg.sender].votedProposalId = _proposal;
        proposals[_proposal].voteCount ++;

        emit Voted (msg.sender, _proposal);
    }

    /** 
     * Calls getWinningProposalID() function to get the index of the winner contained in the proposals array and then
     * return Winning Proposal
     */
    function getWinner() public view returns(uint){
        uint currentIndex = sessions.length-1;
        return sessions[currentIndex].winningProposalId;
    }

    /** 
     * return Winning Proposal for a specific session
     */
    function getWinnerDetails(uint _sessionid) public view returns(string memory description, uint nbVoters){
        require(sessions[_sessionid].winnerDefined , "Voting winner has not been defined yet for this session");
        return (
            proposals[sessions[_sessionid].winningProposalId].description, 
            proposals[sessions[_sessionid].winningProposalId].voteCount
            ); 
    }

    /** 
     * return Winning Proposal for a specific session
     */
    function closeVotingSession(uint _sessionId) private{
        require(currentSessionState == WorkflowStatus.VotesTallied , "Session still not tallied");

        sessions[_sessionId].winnerDefined = true;
        setWinningProposalID(_sessionId); 
    }
    
    /** 
     * get voters details after the session ends
     */
    function getVotersDetails(address _address) public view returns(uint) {
        require(currentSessionState == WorkflowStatus.VotesTallied, "Voters result will be made available only at the end of the voting session");
        return  authorizedVoters[_address].votedProposalId;
    }
    /** 
     * set the winning proposal for the requested session.
     */
    function setWinningProposalID(uint _sessionid) public {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if(proposals[p].sessionId == _sessionid) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    sessions[_sessionid].winningProposalId = p;
                }
            }
        }
    }

    function findElementInArray(address element) public view returns(int) {
    /*bytes32 encodedElement = keccak256(abi.encode(element.id));
    for (int i = 0 ; i < arr.length; i++) {
        if (encodedElement == keccak256(abi.encode(element.id))) {
            return i;
        }
    listOfVoters
    }*/
    for (uint i = 0 ; i < listOfVoters.length; i++) {
        if (element == listOfVoters[i]) {
            return int(i);
        }
    }
    return -1;
    }

    function getProposal(uint _proposalId) public view returns(Proposal memory){
        return proposals[_proposalId];
    }
    function getSession() public view returns(Session memory){
        return sessions[sessionIdNonce];
    }
}
