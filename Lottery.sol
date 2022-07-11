// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {

    //Public scope because it should be shown who the lottery manager is
    address public manager;

    //Same situation as for the manager variable
    address[] public players;

    uint public ticketPrice;

    constructor() {
        manager = msg.sender;
        ticketPrice = .001 ether;
    }

    //This function receives ether so it is of type payable
    function enter() public payable {
        require(msg.value >= ticketPrice, "You have to send 0.01 Ether minimum");
        players.push(msg.sender);
    }
    //This function is pseudo random, we should use Chainlink VRF Oracles
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }

    //The index variable will always be between 0 and players.length
    function pickWinner() public onlyOwner {
        uint256 index = random() % players.length;
        //Paying one player by transferring the prize pool to his address
        payable(players[index]).transfer(address(this).balance);
        //Reset the list of players
        players = new address[](0);
    }

    //For each class variable declared with the "public" scope, an implicit getter is created.
    //However, for arrays, not all elements can be returned, you have to fill in the index of the element you want.
    //We declare the function as view because it will not modify any data in the contract, just read
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
    
    modifier onlyOwner {
        require(msg.sender == manager,"Access denied! You have to be the manager of this lottery");
        _;
    }

    modifier notOwner()
    {
        require(msg.sender != manager, "Access denied. The manager cant participate in this lottery");
        _;
    }
}
