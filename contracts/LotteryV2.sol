//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract LotteryV2 is Initializable {
    address owner;

    uint256 public firstPrizeMax;
    uint256 public secondPrizeMax;
    uint256 public betMin;
    uint256 public jackpot;
    
    uint256 public thirdPrizeMax;

    event YouWin(address indexed user, uint256 indexed lotNumber, uint256 indexed prize, uint256 amount);
    event YouLose(address indexed user, uint256 indexed lotNumber);

    function initialize() initializer public {
        firstPrizeMax = 100*10**6;
        secondPrizeMax = 10*10**6;
        thirdPrizeMax = 1*10**6;
        betMin = 1*10**3;
    }

    function lotNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 1000;
    }

    function placeBet(uint256 _placeNumber) public payable {
        require(msg.value == betMin, "Invalid bet amount!");
        require(_placeNumber > 0 && _placeNumber < 10000, "Invalid place number!");

        jackpot += msg.value;
        uint256 _lotNumber = lotNumber();

        if (_placeNumber == _lotNumber) {
            uint256 _winAmount = jackpot > firstPrizeMax ? firstPrizeMax : jackpot;
            payable(msg.sender).transfer(_winAmount);
            jackpot -= _winAmount;
            emit YouWin(msg.sender, _lotNumber, 1, _winAmount);
        } else {
            uint256[2] memory _placePatterns = [_placeNumber % 1000, _placeNumber / 10];
            uint256[2] memory _lotPatterns = [_lotNumber % 1000, _lotNumber / 10];
            uint256 _isWin = 0;

            for (uint256 i=0; i<_placePatterns.length; i++) {
                if (_isWin != 0) break;
                for (uint256 j=0; j<_lotPatterns.length; j++) {
                    if (_isWin != 0) break;
                    if (_placePatterns[i] == _lotPatterns[j]) {
                        _isWin = i+2;
                    }
                }
            }
            if (_isWin != 0) {
                uint256 _winAmount = 0;
                if (_isWin == 2) 
                    _winAmount = jackpot > secondPrizeMax ? secondPrizeMax : jackpot;
                else 
                    _winAmount = jackpot > thirdPrizeMax ? thirdPrizeMax : jackpot;
                payable(msg.sender).transfer(_winAmount);
                jackpot -= _winAmount;
                emit YouWin(msg.sender, _lotNumber, _isWin+2, _winAmount);
            } else {
                emit YouLose(msg.sender, _lotNumber);
            }
        }
    } 

    function resetBet(uint _betMin) public {
        betMin = _betMin * 10**18;
    }
}