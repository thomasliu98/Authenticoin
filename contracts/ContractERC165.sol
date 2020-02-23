pragma solidity ^0.5.16;
import "./ERC165.sol";

contract ContractERC165 is ERC165 {
    // mapping to store supported interfaceIDs
    mapping(bytes4 => bool) internal supportedInterfaces;

    constructor() public {
        supportedInterfaces[this.supportsInterface.selector] = true;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return supportedInterfaces[interfaceID];
    }
}