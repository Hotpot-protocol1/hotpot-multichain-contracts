
// File: contracts/hotpot/interface/IHotpot.sol


pragma solidity ^0.8.20;

interface IHotpot {
    struct Prize {
        uint128 amount;
        uint128 deadline;
    }

    struct InitializeParams {
        uint256 potLimit;
        uint256 raffleTicketCost;
        uint128 claimWindow;
        uint16 numberOfWinners;
        uint16 fee;
        uint16 tradeFee;
        address marketplace;
        address operator;
    }

    struct RequestStatus {
        bool fullfilled;
        bool exists;
        uint256 randomWord;
    }

    event GenerateRaffleTickets(
        address indexed _buyer,
        address indexed _seller,
        uint32 _buyerTicketIdStart,
        uint32 _buyerTicketIdEnd,
        uint32 _sellerTicketIdStart,
        uint32 _sellerTicketIdEnd,
        uint256 _buyerPendingAmount,
        uint256 _sellerPendingAmount
    );
    event WinnersAssigned(address[] _winners, uint128[] _amounts);
    event RandomWordRequested(
        uint256 requestId,
        uint32 fromTicketId,
        uint32 toTicketId
    );
    event RandomnessFulfilled(uint16 indexed potId, uint256 randomWord);
    event Claim(address indexed user, uint256 amount);
    event MarketplaceUpdated(address _newMarketplace);
    event OperatorUpdated(address _newOperator);
  event AirdropAddressUpdated(address _newAidrop);   
   event GenerateAirdropTickets(
        address indexed user, 
        uint32 ticketIdStart,
        uint32 ticketIdEnd
    );
    function initialize(
        address _owner,
        InitializeParams calldata params
    ) external;

    function executeTrade(
        uint256 _amount,
        address _buyer,
        address _seller,
        uint256 _buyerPendingAmount,
        uint256 _sellerPendingAmount
    ) external payable;

    function executeRaffle(
        address[] calldata _winners,
        uint128[] calldata _amounts
    ) external;

    function claim() external payable;

    function fulfillRandomWords(uint256 _requestId, uint256 _salt) external;
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation = 0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner) internal onlyInitializing {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/hotpot/Hotpot.sol


pragma solidity ^0.8.20;




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
        __Ownable_init(_owner);
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