// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TokenVoting {
    IERC20 public token;
    uint256 public feeAmount;
    address public admin;

    struct Candidate {
        string name;
        uint age;
        string party;
        string constituency;
        bool isDisqualified;
    }

    Candidate[] public candidates;
    mapping(uint => uint256) public votes; 
    mapping(address => bool) public hasVoted;

    constructor(address _tokenAddress, uint256 _feeAmount) {
        token = IERC20(_tokenAddress);
        feeAmount = _feeAmount;
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this");
        _;
    }

    function addCandidate(
        string memory _name,
        uint _age,
        string memory _party,
        string memory _constituency
    ) external onlyAdmin {
        candidates.push(Candidate({
            name: _name,
            age: _age,
            party: _party,
            constituency: _constituency,
            isDisqualified: false
        }));
    }

    function disqualifyCandidate(uint index) external onlyAdmin {
        require(index < candidates.length, "Invalid candidate index");
        candidates[index].isDisqualified = true;
    }

    function vote(uint index) external {
        require(index < candidates.length, "Invalid candidate index");
        require(!hasVoted[msg.sender], "You already voted");
        require(!candidates[index].isDisqualified, "Candidate is disqualified");

        bool success = token.transferFrom(msg.sender, address(this), feeAmount);
        require(success, "Token payment failed");

        votes[index]++;
        hasVoted[msg.sender] = true;
    }

    function getWinner() external view returns (Candidate memory winner, uint winnerIndex, uint winnerVotes) {
        uint maxVotes = 0;
        bool found = false;

        for (uint i = 0; i < candidates.length; i++) {
            if (!candidates[i].isDisqualified && votes[i] > maxVotes) {
                maxVotes = votes[i];
                winner = candidates[i];
                winnerIndex = i;
                found = true;
            }
        }

        require(found, "No eligible winner found");
        winnerVotes = maxVotes;
    }

    function getCandidate(uint index) external view returns (
        string memory name,
        uint age,
        string memory party,
        string memory constituency,
        bool isDisqualified,
        uint256 voteCount
    ) {
        require(index < candidates.length, "Invalid index");
        Candidate memory c = candidates[index];
        return (c.name, c.age, c.party, c.constituency, c.isDisqualified, votes[index]);
    }

    function getTotalCandidates() external view returns (uint) {
        return candidates.length;
    }
}
