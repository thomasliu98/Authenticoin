pragma solidity ^0.5.16;
import "./ContractERC721.sol";
import "./SafeMath.sol";
import "./AddressUtils.sol";
import "./AuthenticoinMintControl.sol";

contract AuthenticoinBase is ContractERC721, AuthenticoinMintControl{
    using SafeMath for uint256;
    using AddressUtils for address;
    struct Authenticoin{
        uint256 companyID;
        uint256 productID;
        uint256 productMetadata;
    }

    /**
    *@dev Array containing all coins.
    *The coinID of each coin will map to the arrayIndex of the coin
     */
    Authenticoin [] coins;

    function _mint(
    address _to,
    uint256 _companyID,
    uint256 _productID,
    uint256 _productMetadata
  )
    internal
    onlyCreator
    returns (uint){
        Authenticoin memory _coin = Authenticoin({
            companyID: _companyID,
            productID: _productID,
            productMetadata: _productMetadata
        });
        uint256 newCoinID = coins.push(_coin) - 1;
        _transfer(_to, newCoinID);
        return newCoinID;
  }
}