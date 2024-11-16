// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract NobleVoting {

    // Counters for the votes (now just 0, 1, and 2 to keep it simple)
    uint256[3] public votes;

    // A mapping to check or store addresses that have already voted
    mapping(address => bool) public hasVoted;

    mapping(address => uint256) public currentChoice;

    function vote(uint256 _userChoice) public {
        // check if user input is either 0, 1, or 2
        require(_userChoice < 3, "Invalid choice. Please vote for 0, 1, or 2.");

        // check if user has voted already
        if (hasVoted[msg.sender]){
            // Make sure to remove the previous choice
            uint256 previousChoice = currentChoice[msg.sender];
            votes[previousChoice]--;
        } else {
            // Make a record of the vote
            hasVoted[msg.sender] = true;
        }        
        
        // Record the new vote
        currentChoice[msg.sender] = _userChoice;

        // Update the number of votes with an increment of the chosen number
        votes[_userChoice]++;
    }

    function getVotesForNumber(uint256 _numberOfChoice) public view returns (uint256) {
        // Make sure that the input matches the choices and return the number of votes for the vote choice
        require(_numberOfChoice < 3, "It seems like this is not a choice, please search for 0, 1, or 2.");
        return votes[_numberOfChoice];
    }

    function getAllVotes() public view returns (uint256[3] memory) {
        return votes;
    }
}