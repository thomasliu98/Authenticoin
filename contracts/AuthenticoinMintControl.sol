pragma solidity ^0.5.16;
import "./SafeMath.sol";
import "./AddressUtils.sol";

contract AuthenticoinMintControl{
    using SafeMath for uint256;
    using AddressUtils for address;

    address public creatorAddress;


    modifier onlyCreator() {
        require(msg.sender == creatorAddress);
        _;
    }

}