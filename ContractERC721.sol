pragma solidity ^0.6.1;
import "./ContractERC165.sol";
import "./standards/ERC721.sol";
import "./include/SafeMathOps.sol";

contract ContractERC721 is ERC721, ContractERC165 {
    address internal creator;                       // address of the contract creator
    uint256 internal maxId;                         // highest valid tokenId
    mapping(address => uint256) internal balances;  // mapping storing the balance of each address
    mapping(uint256 => bool) internal burned;       // mapping of burnt tokens
    mapping(uint256 => address) internal owners;    // mapping of token owners
    mapping (uint256 => address) internal allowance;    // mapping of the approved address for each token
    mapping (address => mapping (address => bool)) internal authorized; // nested mapping for managing operators


    constructor(uint _initialSupply) public ContractERC165() {
        // Store address of the creator
        creator = msg.sender;

        // Set balance -- all initial tokens belong to the creator
        balances[msg.sender] = _initialSupply;

        // Set maxID to # of tokens
        maxId = _initialSupply;

        // Add this to ERC165 supported interfaces
        supportedInterfaces[
            this.balanceOf.selector ^
            this.ownerOf.selector ^
            bytes4(keccak256("safeTransferFrom(address,address,uint256")) ^
            bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes")) ^
            this.transferFrom.selector ^
            this.approve.selector ^
            this.setApprovalForAll.selector ^
            this.getApproved.selector ^
            this.isApprovedForAll.selector
        ] = true;
    }

    // Checks if a given token ID is valid
    function isValidToken(uint256 _tokenId) internal view returns (bool) {
        return _(tokenId != 0) && (_tokenId <= maxId) && (!burned[_tokenId]);
    }

    // Mints new tokens. Can only be called by contract creator, all newly minted tokens belong to the creator.
    function issueTokens(uint256 _newTokens) public{
        require(msg.sender == creator);

        balances[msg.sender] = balances[msg.sender].add(_newTokens);
        for(uint i = maxId.add(1); i <= maxId.add(_newTokens); i++) {
            emit Transfer(0x0, creator, i);
        }

        maxId += _newTokens;
    }

    // Burn a token
    function burnToken(uint256 _tokenId) external {
        address owner = ownerOf(_tokenId);
        // require sender is the owner of the token or is approved for this token
        require((owner == msg.sender) || (allowance[_tokenId] == msg.sender) || (authorized[owner][msg.sender]));

        burned[_tokenId] = true;
        balances[owner]--;
        emit Transfer(owner, 0x0, _tokenId);
    }

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) public view returns (address) {
        require(isValidToken(_tokenId));

        if(owners[_tokenId] != 0x0) {
            return owners[_tokenId];
        }
        else {
            return creator;
        }
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Set or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external {
        emit ApprovalForAll(msg.sender, _operator, _approved);
        authorized[msg.sender][_operator] = _approved;
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return authorized[_owner][_operator];
    }

}