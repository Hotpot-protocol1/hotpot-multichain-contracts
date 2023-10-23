// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {IHotpot} from "./interface/IHotpot.sol";

contract Hotpot is 
    IHotpot, 
    OwnableUpgradeable, 
    PausableUpgradeable
{
    uint256 public potLimit;
    uint256 public currentPotSize;
    uint256 public raffleTicketCost;
    mapping(address => Prize) public claimablePrizes;
    mapping(uint256 => RequestStatus) public randomRequests;
    mapping(uint16 => uint32[]) public winningTicketIds;
    uint256 public lastRequestId;
    uint128 private claimWindow;
    uint16 public numberOfWinners;
    uint16 public fee; // 100 = 1%, 10000 = 100%;
    uint16 public tradeFee; // the percent of a trade amount that goes to the pot as pure ether
    uint32 public lastRaffleTicketId;
    uint32 public potTicketIdStart; // start of current pot ticket range
    uint32 public potTicketIdEnd; // end of current pot ticket range
    uint32 public nextPotTicketIdStart;
    uint16 public currentPotId;
    address private marketplace;
    address private operator;  
    address public airdrop; // airdrop contract
    uint256 constant MULTIPLIER = 10000;

    modifier onlyMarketplace() {
        require(msg.sender == marketplace, "Caller is not the marketplace contract");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Caller must be the operator");
        _;
    }

    modifier onlyAirdrop() {
        require(msg.sender == airdrop, "Anauthorized call - not an airdrop contract");
        _;
    }

    constructor() {
        _disableInitializers();
    }
    
    function initialize(address _owner, InitializeParams calldata params) external initializer {
        __Ownable_init();
        __Pausable_init();
        transferOwnership(_owner);

        potLimit = params.potLimit;
        raffleTicketCost = params.raffleTicketCost;
        claimWindow = params.claimWindow;
        numberOfWinners = params.numberOfWinners;
        fee = params.fee;
        tradeFee = params.tradeFee;
        lastRaffleTicketId = 1;
        potTicketIdStart = 1;
        potTicketIdEnd = 1;
        lastRequestId = 1;
        currentPotId = 1;
        nextPotTicketIdStart=2; // first ticket of the first pot
        marketplace = params.marketplace;
        operator = params.operator;
    }

    function executeTrade(
        uint256 _amountInWei, 
        address _buyer, 
        address _seller, 
        uint256 _buyerPendingAmount, 
        uint256 _sellerPendingAmount
    ) external payable onlyMarketplace whenNotPaused {
		require(msg.value > 0, "No trade fee transferred (msg.value)");
        uint256 potValueDelta = msg.value * (MULTIPLIER - fee) / MULTIPLIER;
        uint256 _currentPotSize = currentPotSize;
		uint256 _potLimit = potLimit;
		uint256 _raffleTicketCost = raffleTicketCost;
        uint32 _lastRaffleTicketIdBefore = lastRaffleTicketId;

        _executeTrade(
            _amountInWei,
            _buyer,
            _seller,
            _buyerPendingAmount,
            _sellerPendingAmount,
            _raffleTicketCost
        );

        /*
            Request Chainlink random winners if the Pot is filled 
         */
		if(_currentPotSize + potValueDelta >= _potLimit) {
            _finishRaffle(
                potValueDelta, 
                _lastRaffleTicketIdBefore,
                _potLimit,
                _currentPotSize
            );
        }
		else {
			currentPotSize += potValueDelta;
		}
    }


    function executeRaffle(
        address[] calldata _winners,
        uint128[] calldata _amounts
    ) external onlyOperator {
        uint _potLimit = potLimit;
        require(
            _winners.length == _amounts.length,
            "Winners and their amounts mismatch"
        );
        require(
            _winners.length == numberOfWinners,
            "Must be equal to numberofWinners"
        );
        // for testing
        // require(address(this).balance >= _potLimit, "The pot is not filled");

        uint sum = 0;
        for (uint i; i < _amounts.length; i++) {
            Prize storage userPrize = claimablePrizes[_winners[i]];
            userPrize.deadline = uint128(block.timestamp + claimWindow);
            userPrize.amount = userPrize.amount + _amounts[i];
            sum += _amounts[i];
        }
        require(sum <= _potLimit);

        emit WinnersAssigned(_winners, _amounts);
    }

      function claim() external payable whenNotPaused {
        address payable user = payable(msg.sender);
        Prize memory prize = claimablePrizes[user];
        require(prize.amount > 0, "No available winnings");
        require(block.timestamp < prize.deadline, "Claim window is closed");

        claimablePrizes[user].amount = 0;
        user.transfer(prize.amount);
        emit Claim(user, prize.amount);
    }

    function canClaim(address user) external view returns(bool) {
        Prize memory prize = claimablePrizes[user];
        return prize.amount > 0 && block.timestamp < prize.deadline;
    }

    function getWinningTicketIds(uint16 _potId) external view returns(uint32[] memory) {
        return winningTicketIds[_potId];
    }

    function claimAirdropTickets(
        address user,
        uint32 tickets
    ) external onlyAirdrop {
        if (tickets == 0) {
            return;
        }
        uint32 ticketIdStart = lastRaffleTicketId + 1;
        uint32 ticketIdEnd = ticketIdStart + tickets - 1;
        lastRaffleTicketId = ticketIdEnd;
        emit GenerateAirdropTickets(
            user,
            ticketIdStart,
            ticketIdEnd
        );
    }

    /* 

        ***
        SETTERS
        ***

     */

    function setMarketplace(address _newMarketplace) external onlyOwner {
        require(marketplace != _newMarketplace, "Address didn't change");
        marketplace = _newMarketplace;
        emit MarketplaceUpdated(_newMarketplace);
    }

    function setOperator(address _newOperator) external onlyMarketplace {
        operator = _newOperator;
    }

    function setAirdropContract(address _newAirdropContract) external onlyOwner {
        require(airdrop != _newAirdropContract, "Address didn't change");
        airdrop = _newAirdropContract;
        emit AirdropAddressUpdated(_newAirdropContract);
    }

    function setRaffleTicketCost(uint256 _newRaffleTicketCost) external onlyOwner {
        require(raffleTicketCost != _newRaffleTicketCost, "Cost must be different");
        require(_newRaffleTicketCost > 0, "Raffle cost must be non-zero");
        raffleTicketCost = _newRaffleTicketCost;
    }

    function setPotLimit(uint256 _newPotLimit) external onlyOwner {
        require(potLimit != _newPotLimit, "Pot limit must be different");
        potLimit = _newPotLimit;
    }

    function setTradeFee(uint16 _newTradeFee) external onlyMarketplace {
        tradeFee = _newTradeFee;
    }



    function _executeTrade(
        uint256 _amountInWei, 
        address _buyer, 
        address _seller, 
        uint256 _buyerPendingAmount, 
        uint256 _sellerPendingAmount,
        uint256 _raffleTicketCost
    ) internal returns(
        uint256 _newBuyerPendingAmount,
        uint256 _newSellerPendingAmount
    ) {
        require(_buyer != _seller, "Buyer and seller must be different");
        uint32 buyerTickets = uint32((_buyerPendingAmount + _amountInWei) / _raffleTicketCost);
		uint32 sellerTickets = uint32((_sellerPendingAmount + _amountInWei) / _raffleTicketCost);
		_newBuyerPendingAmount = (_buyerPendingAmount + _amountInWei) % _raffleTicketCost;
		_newSellerPendingAmount = (_sellerPendingAmount + _amountInWei) % _raffleTicketCost;
        
        _generateTickets(_buyer, _seller, buyerTickets, sellerTickets,
            _newBuyerPendingAmount, _newSellerPendingAmount);
    }
    
    function _generateTickets(
        address _buyer,
        address _seller,
        uint32 buyerTickets, 
        uint32 sellerTickets,
        uint256 _newBuyerPendingAmount,
        uint256 _newSellerPendingAmount
    ) internal {
        uint32 buyerTicketIdStart;
        uint32 buyerTicketIdEnd;
        uint32 sellerTicketIdStart;
        uint32 sellerTicketIdEnd;

        if(buyerTickets > 0) {
            buyerTicketIdStart = lastRaffleTicketId + 1;
            buyerTicketIdEnd = buyerTicketIdStart + buyerTickets - 1; 
        }
        if (sellerTickets > 0) {
            bool buyerGetsNewTickets = buyerTicketIdEnd > 0;
            sellerTicketIdStart = buyerGetsNewTickets ? 
                buyerTicketIdEnd + 1 : lastRaffleTicketId + 1;
            sellerTicketIdEnd = sellerTicketIdStart + sellerTickets - 1;
        }
        lastRaffleTicketId += buyerTickets + sellerTickets;

        emit GenerateRaffleTickets(
			_buyer, 
			_seller, 
			buyerTicketIdStart, 
			buyerTicketIdEnd,
            sellerTicketIdStart,
            sellerTicketIdEnd,
			_newBuyerPendingAmount,
			_newSellerPendingAmount
		);
    }

    function _calculateTicketIdEnd(
        uint32 _lastRaffleTicketIdBefore
    ) internal view returns(uint32 _ticketIdEnd) {
		uint256 _raffleTicketCost = raffleTicketCost;
        uint256 _ethDeltaNeededToFillPot = (potLimit - currentPotSize) * MULTIPLIER / (MULTIPLIER - fee);
        uint256 _tradeAmountNeededToFillPot = _ethDeltaNeededToFillPot * MULTIPLIER / tradeFee;
        // First calculate tickets needed to fill the pot
        uint32 ticketsNeeded = uint32(_tradeAmountNeededToFillPot / _raffleTicketCost) * 2;
        
        if(_tradeAmountNeededToFillPot % _raffleTicketCost > 0) {
            ticketsNeeded += 1;
        }
        
        return _lastRaffleTicketIdBefore + ticketsNeeded;
    }

    function _finishRaffle(
        uint256 potValueDelta,
        uint32 _lastRaffleTicketIdBefore,
        uint256 _potLimit,
        uint256 _currentPotSize
    ) internal {
        uint32 _potTicketIdEnd = _calculateTicketIdEnd(_lastRaffleTicketIdBefore);
        potTicketIdEnd = _potTicketIdEnd;
        potTicketIdStart = nextPotTicketIdStart; 
        nextPotTicketIdStart = _potTicketIdEnd + 1; // starting ticket of the next Pot
        // The remainder goes to the next pot
        currentPotSize = (_currentPotSize + potValueDelta) % _potLimit; 
        _requestRandomWinners();
    }

    function _requestRandomWinners() internal {
        uint256 requestId = ++lastRequestId;
         randomRequests[requestId].exists = true;
        emit RandomWordRequested(requestId, potTicketIdStart, potTicketIdEnd);
    }

    function fulfillRandomWords(uint256 _requestId, uint256 _salt) external onlyOperator{
       uint32 rangeFrom = potTicketIdStart;
        uint32 rangeTo = potTicketIdEnd;

        randomRequests[_requestId] = RequestStatus({
            fullfilled: true,
            exists: true,
            randomWord: _salt
        });

        uint256 n_winners = numberOfWinners;
        uint32[] memory derivedRandomWords = new uint32[](n_winners);
        uint256 randomWord = _generateRandomFromSalt(_salt);
        derivedRandomWords[0] = _normalizeValueToRange(
            randomWord,
            rangeFrom,
            rangeTo
        );
        uint256 nextRandom;
        uint32 nextRandomNormalized;
        for (uint256 i = 1; i < n_winners; i++) {
            nextRandom = uint256(keccak256(abi.encode(randomWord, i)));
            nextRandomNormalized = _normalizeValueToRange(
                nextRandom,
                rangeFrom,
                rangeTo
            );
            derivedRandomWords[i] = _incrementRandomValueUntilUnique(
                nextRandomNormalized,
                derivedRandomWords
            );
        }

        winningTicketIds[currentPotId] = derivedRandomWords;
        currentPotId++;
        emit RandomnessFulfilled(currentPotId, _salt);
    }

    function _normalizeValueToRange(
        uint256 _value, uint32 _rangeFrom, uint32 _rangeTo
    ) internal pure returns(uint32 _scaledValue) {
        _scaledValue = uint32(_value) % (_rangeTo - _rangeFrom) + _rangeFrom; // from <= x <= to
    }

    function _generateRandomFromSalt(
        uint256 _salt
    ) internal view returns (uint256 _random) {
        return uint256(keccak256(abi.encode(_salt, block.timestamp)));
    }
    function _incrementRandomValueUntilUnique(
        uint32 _random,
        uint32[] memory _randomWords
    ) internal pure returns (uint32 _uniqueRandom) {
        _uniqueRandom = _random;
        for (uint i = 0; i < _randomWords.length; ) {
            if (_uniqueRandom == _randomWords[i]) {
                unchecked {
                    _uniqueRandom++;
                    i = 0;
                }
            } else {
                unchecked {
                    i++;
                }
            }
        }
    }

}