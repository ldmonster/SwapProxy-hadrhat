//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../contracts/ShadowClone.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IShadowClone {
    function initialize(address _owner) external;
}

contract ShadowCloneFactory is Ownable {

    bool public debug = true;
    address public operator = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    mapping(address => address) private contracts;
    address[] public allContracts;

    event ContractCreated(address _owner, address _contract);


    constructor() {
        operator = msg.sender;
    }

    function createShadowCloner() external returns (address clone) {
        require(contracts[_msgSender()] == address(0), 'ShadowCloner: Owner already has a contract');
        bytes memory bytecode = type(ShadowClone).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_msgSender()));
        assembly {
            clone := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IShadowClone(clone).initialize(_msgSender());
        contracts[_msgSender()] = clone;
        allContracts.push(clone);
        emit ContractCreated(_msgSender(), clone);
    }

    function GetOperator() external view returns(address){
        return operator;
    }

    function GetShadowCloner(address _owner) external view returns(address){
        address clone = contracts[_owner];
        require(clone != address(0), 'ShadowCloner: Owner has no contract');
        return clone;
    }
}
