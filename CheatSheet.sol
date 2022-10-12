// SPDX-License-Identifier: GPL-3.0
// ^ Tells that source code is licensed under the GPL version 3.0. Machine-readable license

pragma solidity >=0.4.16 <0.9.0;

//^ Source code is written for Solidity version 0.4.16, or a newer version of the language up to, but not including version 0.9.0
//Versioning is to ensure that the contract is not compilable with a new (breaking) compiler version, where it could behave differently

//All identifiers (contract names, function names and variable names) are restricted to the ASCII character set(0-9,A-Z,a-z & special chars.).
contract CheatSheet {
    //Declares a state variable called storedData of type (unsigned integer of 256 bits).
    // State Variable is as a single slot in a database that you can query and alter by calling functions of the code that manages the database
    // Variable is private by default if access modifier is not mentioned
    uint256 storedData;

    // The keyword "public" automatically generates a function that allows to access the state variable from other contracts
    // Equivalent to -> function owner() external view returns (address) { return owner; }
    // The address type is a 160-bit value and is suitable for storing addresses of contracts, or external accounts.
    address public owner;

    //  Mappings are like hash tables which are virtually initialised such that every possible key is mapped to a value whose byte-representation is all zeros.
    // Not possible to obtain a list of all keys or all values of a mapping
    // maps addresses to unsigned integers.
    mapping(address => uint256) public balances;

    // Events allow clients to react to specific state change
    // Web app can listen for these events, the listener receives the arguments sender and value, to track transactions.
    // Eg. Listeners using web3js :
    // ContractName.Stored().watch({}, '', function(error, result) {
    // if (!error) {
    //     console.log("Number stored: " + result.args.value +
    //         " stored by " + result.args.sender +".");
    //     }
    // })
    event Stored(address sender, uint256 value);

    // Constructor code only runs when the contract is created
    constructor() {
        // "msg" is a special global variable that contains allow access to the blockchain.
        // msg.sender is always the address where the current (external) function call came from.
        owner = msg.sender;
    }

    // only the creator of the contract "owner" can call this function.
    function set(uint256 x) public {
        // The require defines that reverts all changes if defined condition not met.
        require(msg.sender == owner);
        storedData = x;

        //Stored event emitted
        emit Stored(msg.sender, x);
    }
}
