
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

    // File: @openzeppelin/contracts/utils/Context.sol


    // OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

    pragma solidity ^0.8.0;

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
    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes calldata) {
            return msg.data;
        }
    }

    // File: @openzeppelin/contracts/access/Ownable.sol


    // OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

    pragma solidity ^0.8.0;


    /**
    * @dev Contract module which provides a basic access control mechanism, where
    * there is an account (an owner) that can be granted exclusive access to
    * specific functions.
    *
    * By default, the owner account will be the one that deploys the contract. This
    * can later be changed with {transferOwnership}.
    *
    * This module is used through inheritance. It will make available the modifier
    * `onlyOwner`, which can be applied to your functions to restrict their use to
    * the owner.
    */
    abstract contract Ownable is Context {
        address private _owner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
        constructor() {
            _transferOwnership(_msgSender());
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
            return _owner;
        }

        /**
        * @dev Throws if the sender is not the owner.
        */
        function _checkOwner() internal view virtual {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            _transferOwnership(newOwner);
        }

        /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Internal function without access restriction.
        */
        function _transferOwnership(address newOwner) internal virtual {
            address oldOwner = _owner;
            _owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
        }
    }

    // File: @openzeppelin/contracts/security/ReentrancyGuard.sol


    // OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

    pragma solidity ^0.8.0;

    /**
    * @dev Contract module that helps prevent reentrant calls to a function.
    *
    * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
    * available, which can be applied to functions to make sure there are no nested
    * (reentrant) calls to them.
    *
    * Note that because there is a single `nonReentrant` guard, functions marked as
    * `nonReentrant` may not call one another. This can be worked around by making
    * those functions `private`, and then adding `external` `nonReentrant` entry
    * points to them.
    *
    * TIP: If you would like to learn more about reentrancy and alternative ways
    * to protect against it, check out our blog post
    * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
    */
    abstract contract ReentrancyGuard {
        // Booleans are more expensive than uint256 or any type that takes up a full
        // word because each write operation emits an extra SLOAD to first read the
        // slot's contents, replace the bits taken up by the boolean, and then write
        // back. This is the compiler's defense against contract upgrades and
        // pointer aliasing, and it cannot be disabled.

        // The values being non-zero value makes deployment a bit more expensive,
        // but in exchange the refund on every call to nonReentrant will be lower in
        // amount. Since refunds are capped to a percentage of the total
        // transaction's gas, it is best to keep them low in cases like this one, to
        // increase the likelihood of the full refund coming into effect.
        uint256 private constant _NOT_ENTERED = 1;
        uint256 private constant _ENTERED = 2;

        uint256 private _status;

        constructor() {
            _status = _NOT_ENTERED;
        }

        /**
        * @dev Prevents a contract from calling itself, directly or indirectly.
        * Calling a `nonReentrant` function from another `nonReentrant`
        * function is not supported. It is possible to prevent this from happening
        * by making the `nonReentrant` function external, and making it call a
        * `private` function that does the actual work.
        */
        modifier nonReentrant() {
            _nonReentrantBefore();
            _;
            _nonReentrantAfter();
        }

        function _nonReentrantBefore() private {
            // On the first call to nonReentrant, _status will be _NOT_ENTERED
            require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

            // Any calls to nonReentrant after this point will fail
            _status = _ENTERED;
        }

        function _nonReentrantAfter() private {
            // By storing the original value once again, a refund is triggered (see
            // https://eips.ethereum.org/EIPS/eip-2200)
            _status = _NOT_ENTERED;
        }

        /**
        * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
        * `nonReentrant` function in the call stack.
        */
        function _reentrancyGuardEntered() internal view returns (bool) {
            return _status == _ENTERED;
        }
    }

    // File: @openzeppelin/contracts/utils/introspection/IERC165.sol


    // OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

    pragma solidity ^0.8.0;

    /**
    * @dev Interface of the ERC165 standard, as defined in the
    * https://eips.ethereum.org/EIPS/eip-165[EIP].
    *
    * Implementers can declare support of contract interfaces, which can then be
    * queried by others ({ERC165Checker}).
    *
    * For an implementation, see {ERC165}.
    */
    interface IERC165 {
        /**
        * @dev Returns true if this contract implements the interface defined by
        * `interfaceId`. See the corresponding
        * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
        * to learn more about how these ids are created.
        *
        * This function call must use less than 30 000 gas.
        */
        function supportsInterface(bytes4 interfaceId) external view returns (bool);
    }

    // File: @openzeppelin/contracts/token/ERC721/IERC721.sol


    // OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

    pragma solidity ^0.8.0;


    /**
    * @dev Required interface of an ERC721 compliant contract.
    */
    interface IERC721 is IERC165 {
        /**
        * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
        */
        event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

        /**
        * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
        */
        event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

        /**
        * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
        */
        event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

        /**
        * @dev Returns the number of tokens in ``owner``'s account.
        */
        function balanceOf(address owner) external view returns (uint256 balance);

        /**
        * @dev Returns the owner of the `tokenId` token.
        *
        * Requirements:
        *
        * - `tokenId` must exist.
        */
        function ownerOf(uint256 tokenId) external view returns (address owner);

        /**
        * @dev Safely transfers `tokenId` token from `from` to `to`.
        *
        * Requirements:
        *
        * - `from` cannot be the zero address.
        * - `to` cannot be the zero address.
        * - `tokenId` token must exist and be owned by `from`.
        * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
        * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
        *
        * Emits a {Transfer} event.
        */
        function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

        /**
        * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
        * are aware of the ERC721 protocol to prevent tokens from being forever locked.
        *
        * Requirements:
        *
        * - `from` cannot be the zero address.
        * - `to` cannot be the zero address.
        * - `tokenId` token must exist and be owned by `from`.
        * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
        * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
        *
        * Emits a {Transfer} event.
        */
        function safeTransferFrom(address from, address to, uint256 tokenId) external;

        /**
        * @dev Transfers `tokenId` token from `from` to `to`.
        *
        * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
        * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
        * understand this adds an external call which potentially creates a reentrancy vulnerability.
        *
        * Requirements:
        *
        * - `from` cannot be the zero address.
        * - `to` cannot be the zero address.
        * - `tokenId` token must be owned by `from`.
        * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
        *
        * Emits a {Transfer} event.
        */
        function transferFrom(address from, address to, uint256 tokenId) external;

        /**
        * @dev Gives permission to `to` to transfer `tokenId` token to another account.
        * The approval is cleared when the token is transferred.
        *
        * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
        *
        * Requirements:
        *
        * - The caller must own the token or be an approved operator.
        * - `tokenId` must exist.
        *
        * Emits an {Approval} event.
        */
        function approve(address to, uint256 tokenId) external;

        /**
        * @dev Approve or remove `operator` as an operator for the caller.
        * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
        *
        * Requirements:
        *
        * - The `operator` cannot be the caller.
        *
        * Emits an {ApprovalForAll} event.
        */
        function setApprovalForAll(address operator, bool approved) external;

        /**
        * @dev Returns the account approved for `tokenId` token.
        *
        * Requirements:
        *
        * - `tokenId` must exist.
        */
        function getApproved(uint256 tokenId) external view returns (address operator);

        /**
        * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
        *
        * See {setApprovalForAll}
        */
        function isApprovedForAll(address owner, address operator) external view returns (bool);
    }

    // File: contracts/hotpot/Marketplace.sol


    pragma solidity ^0.8.4;





    contract Marketplace is ReentrancyGuard, Ownable {
        // Variables
        uint128 public itemCount;
        uint128 public activeItemCount;
        /* 
        Hotpot variables
        */
        address public raffleContract;
        uint256 public raffleTradeFee = 1000;
        uint256 constant HUNDRED_PERCENT = 10000;

        struct Item {
            uint itemId;
            IERC721 nft;
            uint tokenId;
            uint price;
            address payable seller;
            bool sold;
        }

        // itemId -> Item
        mapping(uint => Item) public items;

        event Offered(
            uint itemId,
            address indexed nft,
            uint tokenId,
            uint price,
            address indexed seller
        );
        event Bought(
            uint itemId,
            address indexed nft,
            uint tokenId,
            uint price,
            address indexed seller,
            address indexed buyer
        );

        // Make item to offer on the marketplace
        function makeItem(
            IERC721 _nft,
            uint _tokenId,
            uint _price
        ) external nonReentrant {
            require(_price > 0, "Price must be greater than zero");
            // increment itemCount
            itemCount++;
            activeItemCount++;
            // transfer nft
            _nft.transferFrom(msg.sender, address(this), _tokenId);
            // add new item to items mapping
            items[itemCount] = Item(
                itemCount,
                _nft,
                _tokenId,
                _price,
                payable(msg.sender),
                false
            );
            // emit Offered event
            emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
        }

        function purchaseItem(uint _itemId) external payable nonReentrant {
            uint _totalPrice = getTotalPrice(_itemId);
            Item storage item = items[_itemId];
            require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
            require(
                msg.value >= _totalPrice,
                "not enough ether to cover item price and market fee"
            );
            require(!item.sold, "item already sold");
            // pay seller and feeAccount
            item.seller.transfer(item.price);
            // update item to sold
            item.sold = true;
            // transfer nft to buyer
            item.nft.transferFrom(address(this), msg.sender, item.tokenId);
            activeItemCount--;

            /* 
                Hotpot Execute Trade
            */
            address _raffleContract = raffleContract;

            if (_raffleContract != address(0)) {
                uint256 fee = msg.value - item.price; // the rest of the value goes to the pot
                IHotpot(_raffleContract).executeTrade{value: fee}(
                    _totalPrice,
                    msg.sender,
                    item.seller,
                    0,
                    0
                );
            }
            // emit Bought event
            emit Bought(
                _itemId,
                address(item.nft),
                item.tokenId,
                item.price,
                item.seller,
                msg.sender
            );
        }

        function setRaffleAddress(address raffle) external onlyOwner {
            raffleContract = raffle;
        }

        function setRaffleTradeFee(uint256 _newTradeFee) external onlyOwner {
            raffleTradeFee = _newTradeFee;
        }

        function getTotalPrice(uint _itemId) public view returns (uint) {
            return ((items[_itemId].price * (HUNDRED_PERCENT + raffleTradeFee)) /
                HUNDRED_PERCENT);
        }

        function getAllListedNfts() external view returns (Item[] memory) {
            Item[] memory nfts = new Item[](activeItemCount);
            uint256 totalCount = itemCount;
            uint256 nftCount = 0;
            for (uint i = 0; i < totalCount; i++) {
                Item memory item = items[i + 1];
                if (!item.sold) {
                    nfts[nftCount] = item;
                    nftCount++;
                }
            }
            return nfts;
        }
    }
