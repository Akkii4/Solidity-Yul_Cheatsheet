// SPDX-License-Identifier: GPL-3.0
// ^ Tells that source code is licensed under the GPL version 3.0. Machine-readable license
// It is included as string in the bytecode metadata.

// "pragma" keyword is used to enable certain compiler features or checks
// Source code is written for Solidity version 0.4.16, or a newer version of the language up to, but not including version 0.9.0
// another eg. pragma solidity ^0.4.16; -> doesn't compile with a compiler earlier than version 0.4.16, and `^` represnts it neither compiles on compiler 0.x.0(where x > 4).
// Versioning is to ensure that the contract is not compilable with a new (breaking) compiler version, where it could behave differently
pragma solidity >=0.4.16 <0.9.0;

//ABI coder (v2) is able to encode and decode arbitrarily nested arrays and structs
// Default since Solidity 0.8.0
// Has all feature of v1
pragma abicoder v2;

//imports all global symbols from “filename” (and symbols imported there) into current global scope
// not recommended as any items added to the “filename” auto appears in the files
import "./Add.sol";
// & to import specific symbols explicitly
// equivalent to -> import * as multiplier from "./Mul.sol";
import "./Mul.sol" as multiplier;
//to avoid naming collision
import {divide2 as div, name} from "./Div.sol";

//External imports are also allowed from github -> import "github/filepath/url"

/*
Functions are the executable units of code. 
They are usually defined inside a contract, 
but they can also be defined outside of contracts.
*/
function outsider(uint256 x) pure returns (uint256) {
    return x * 2;
}

//All identifiers (contract names, function names and variable names) are restricted to the ASCII character set(0-9,A-Z,a-z & special chars.).
contract CheatSheet {
    /*
    State Variable is like a single slot in a database that are accessible by functions
    and there values are permanently stored in contract storage.
    */

/* 
Value Types : These variables are always be passed by value, 
i.e they are always copied when used as function arguments or in assignments.
*/
    // Integers exists in sizes(from 8 up to 256 bits) in steps of 8
    // uint and int are aliases for uint256 and int256, respectively

    // unsigned integer of 256 bits
    // Variable is private by default if access modifier is not mentioned
    uint256 storedData;

    // address holds 20 byte value and is suitable for storing addresses of contracts, or external accounts.
    address public owner;
    /*  
        ^ "public" autom generates a function that allows to access the state variable from other contracts
        Equivalent to -> function owner() external view returns (address) { return owner; }
    */ 

    // Boolean possible values are true and false
    bool public isEven;

    // Fixed point numbers aren't yet supported and thus can only be declared
    fixed x;
    ufixed y;

    //  Mappings are like hash tables which are virtually initialised such that every possible key is mapped to a value whose byte-representation is all zeros.
    // Not possible to obtain a list of all keys or all values of a mapping
    // maps addresses to unsigned integers.
    mapping(address => uint256) public balances;

    //Structs are group of multiple related variables 
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    // Enums are special set of predefined constants 
    enum State { Created, Locked, Inactive }

    /* 
    Modifiers can be used to change the behaviour of functions 
    in a declarative way(abstract away control flow for logic)
    */
    // Overloading (same modifier name with different parameters) is not possible.
    // Like functions, modifiers can be overridden.
    modifier onlyOwner() {
        // The require defines that reverts all changes if defined condition not met.
        require(msg.sender == owner, "Not Owner");
        _;
    }

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

    // Errors allow custom names and data for failure situations.
    // Are used in revert statement & are cheaper than using string in revert
    error invalidValue(uint value);

    // Constructor code only runs when the contract is created
    constructor() {
        // "msg" is a special global variable that contains allow access to the blockchain.
        // msg.sender is always the address where the current (external) function call came from.
        owner = msg.sender;
    }

    // Modifier usage let only the creator of the contract "owner" can call this function
    function set(uint256 x) public onlyOwner {
        if(x < 10) revert invalidValue();
        storedData = x;

        //Stored event emitted
        emit Stored(msg.sender, x);
    }

    function boolTesting(bool x, bool y, bool z) public pure returns (bool) {
        // Short-circuiting rule: full expression will not be evaluated
        // if the result is already been determined by previous variable
        return x && (y || z);
    }

    // access the minimum and maximum value representable by the integer type
    function integersRange() external pure returns(uint ,uint ,int , int) {
        return (
                //uintX range
                type(uint8).max, // 2**8 - 1
                type(uint16).min, // 0

                // int : Signed Integer
                // intX range
                type(int32).max, // (2**32)/2 - 1
                type(int64).min  // (2**64)/2 * -1
        );
    }
}

/*
// Comments in Solidity :

// This is a single-line comment.

/*
This is a
multi-line comment.
*/
/*