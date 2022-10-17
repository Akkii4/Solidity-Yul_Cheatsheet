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
    fallback() or receive ()?

    Ether is sent to contract
            |
    is msg. data empty?
            /  \
          yes   no
          /       \
receive() exists?  fallback()
        /  \
      yes   no
      /      \
receive()   fallback()
*/
    // Fallback & recieve functions must be external.
    fallback() external payable {
        //returns remaining gas
        emit Log("fallback", gasleft());
    }

    receive() external payable {
        emit Log("receive", gasleft());
    }
     
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
    uint256 storedData; // unsigned integer of 256 bits
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

    // address holds 20 byte value and is suitable for storing addresses of contracts, or external accounts.
    address public owner;
    /*  
        ^ "public" autom generates a function that allows to access the state variable from other contracts
        Equivalent to -> function owner() external view returns (address) { return owner; }
    */ 
    //address with transfer and send functionality to recieve Ether
    address payable public treasury;

    // Boolean possible values are true and false
    bool public isEven;
    function boolTesting(bool _x, bool _y, bool _z) public pure returns (bool) {
        // Short-circuiting rule: full expression will not be evaluated
        // if the result is already been determined by previous variable
        return _x && (_y || _z);
    }
    

    // Fixed point numbers aren't yet supported and thus can only be declared
    fixed x;
    ufixed y;


    function literals() external pure returns (address, uint, int, uint, string memory, string memory, string memory, bytes20, int[2] memory){
        return(
        // Also Hexadecimal literals that pass the address checksum test are considered as address
        0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF,

        /*
        Division on integer literals eg. 5/2
        prior to version 0.4.0 is equal to  2
        but now it's rational number 2.5
        */
        5/2 + 1 + 0.5,  //  = 4
        // whereas uint x = 1;
        //         uint y = 5/2 + x + 0.5  returns compiler error, as operators works only on common value types

        //decimals fractional formed by . with at least one number after decimal point
        // .1, 1.3 but not 1. 
        -.2e10, //Scientific notation of type MeE ~= M * 10**E

        //Underscores have no meaning(just eases humman readibility)
        1_2e3_0, // = 12*10**30

        /*
        string literal represented in " " OR ' '
        */
        "yo" "lo", // can be splitted = "yolo"
        'abc\\def', // also supports various escape characters

        //unicode
        unicode"Hi there 👋",

        //Random Hexadecimal literal behve just like string literal
        hex"00112233_44556677",

        //array literals are comma-separated list of one or more expressions 
        // typed by that of it's first element & all it's elements can be converted this type
        [int(1), -1]
        );
    }


    /* 
    Enums are user-defined type of predefined constants 
    First values is default & starts from uint 0
    They can be stored even outside of Contract & in libraries as well
    */
    enum Status { Manufacturer, Wholesaler, Shopkeeper, User  }
    Status public status;
    /* 
    As enums are not stored in ABI
    thus in ABI 'updateStatus()' will have its input type as uint8 
    */
    function updateStatus(Status _status) public {
        status = _status;
    }
    //Accessing boundaries range values of an enum
    function enumsRange() public pure returns(Status, Status) {
        return (
                type(Status).max,   // return 3, indicating 'User'
                type(Status).min    // return 0, indicating 'Manufacturer'
        );
    }


    /* User Defined Value Types allows creating a zero cost abstraction over an elementary value type
    type C is V , C is new type & V is elementary type
    type conversion , operators aren't allowed 
    */
    type UFixed256x18 is uint256;   // Represent a 18 decimal, 256 bit wide fixed point.
    /// custom types only allows wrap and unwrap
    function customMul(UFixed256x18 _x, uint256 _y) internal pure returns (UFixed256x18) {
        return UFixed256x18.wrap(               // wrap (convert underlying type -> custom type)
                UFixed256x18.unwrap(_x) * _y      // unwrap (convert custom type -> underlying type)
        );
    }


/* 
Reference Types : Values can be modified through multiple different names unlike Value type
always have to define the data locations for the variables
*/
    
    /* Solidity stores data as :
    storage - stored on blockchain
    memory - it is modifiable & exists while a function is being called
    calldata - non-modifiable area where function arguments are stored and behaves mostly like memory
    Prior to v0.6.9 data location was limited to calldata in external functions
    */
    function dataLocations(uint[] memory memoryArray) public {
        dynamicSized = memoryArray; // Assignments betweem storage, memory & calldata always creates independent copies
        uint[] storage z = dynamicSized; // Assignments to a local storage from storage ,creates reference.
        z.pop(); // modifies array dynamicSized through y
        delete dynamicSized; // clears the array dynamicSized & y

        /*  
        Assigning memory to local storage doesn't work as
        it would need to create a new temporary / unnamed array in storage, 
        but storage is "statically" allocated
        // z = memoryArray;
        /*

        /* 
        Cannot "delete z" as
        referencing global storage objects can only be made from existing local storage objects.
        // delete z
        */
    }


    // Arrays
    uint[] public dynamicSized;
    uint[2**3] fixedSized; // array of 8 elements all initialized to 0
    uint[][4] nestedDynamic; // An array of 4 dynamic arrays
    bool[3][] triDynamic; // Dynamic Array of arrays of length 3
    uint[] public arr = [1, 2, 3]; // pre assigned array
    uint[][] freeArr; //Dynaic arrays of dynamic array
    function aboutArrays(uint _x, uint _y, uint _value, bool[3] memory _newArr, uint size) external {
        //Creating memeory arrays
        uint[] memory a = new uint[](7);          // Fixed size memory array
        uint[2][] memory b = new uint[2][](size); // Dynamic memory array 
        // fixed size array can't be converted/assigned to dynamic memory array
        // uint[] memory x = [uint(1), 3, 4]; // gives Error
        
        //assigning to arrays
        for(uint i =0; i<=7; i++){
            a[i] = i;               //assigning elements individually
        }
        triDynamic.push(_newArr);   //pushes array of 3 element to a Dynamic array

        //Accessing array's elemnts
        nestedDynamic[_x][_y]; //returns the element at index 'y' in the 'x' array
        nestedDynamic[_x];     //returns the array at index 'x'
        arr.length;     // number of elements in array

        // Only dynamic storage arrays are resizable
        //Adding elements 
        dynamicSized.push(_value);  // appends new element at end of array
        dynamicSized.push();        // appends zero-initialized element

        //Removing elements
        dynamicSized.pop();         // remove end of array element
        delete arr;                 // resets all values to default value w/o changing length
        triDynamic = new bool[3][](0); //similar to delete array
    }
    /*slicing of array[start:end] 
    start default is 0 & end is array's length 
    only works with calldata array as input
    */
    function slice(uint[] calldata _arr, uint start, uint end) public pure returns(uint[] memory){
        return _arr[start:end];
    }
    }


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

    // Constructor code only runs when the contract is created
    constructor() {
        // "msg" is a special global variable that contains allow access to the blockchain.
        // msg.sender is always the address where the current (external) function call came from.
        owner = msg.sender;
    }

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
    event Log(string func, uint gas);

    // Errors allow custom names and data for failure situations.
    // Are used in revert statement & are cheaper than using string in revert
    error invalidValue(uint value);

    // Modifier usage let only the creator of the contract "owner" can call this function
    function set(uint256 _value) public onlyOwner {
        if(_value < 10) revert invalidValue(_value);
        storedData = _value;

        //Stored event emitted
        emit Stored(msg.sender, _value);
    }

    // Payable Function requires Calling this function along with some Ether (as msg.value)
    function transferringFunds(address payable _to) external payable{
        /*
        'transfer' fails if sender don't have enough balance or trx rejected by reciever 
        reverts on failure & stops execution
        transfer/send has 2300 gas limit
        */
        treasury.transfer(1 wei);

        /*
        'send' returns a boolean value indicating success or failure.
        doesn't stops execution
        */
        bool sent = payable(0).send(1 wei); // payable(0) -> 0x0000000000000000000000000000000000000000
        require(sent, "Send failed");

        /*
        Call returns a boolean value indicating success or failure.
        is possible to adjust gas supplied
        most recommended method to transfer funds.
        */
        (bool res, bytes memory data) = _to.call{gas: 5000, value: msg.value}("");
        // do something with data...
        require(res, "Failed to send Ether");

        // Explicit conversion allowed from address to address payable  
        payable(owner).transfer(address(this).balance); //querying this contract ether balance 
    }

    //query the deployed code for any smart contract
    function accessCode(address _contractAddr) external view returns(bytes memory, bytes32){
        return (
            _contractAddr.code,     // gets the EVM bytecode of code
            _contractAddr.codehash  // Keccak-256 hash of that code
        );
    }
}

// Comments in Solidity :

// This is a single-line comment.

/*
This is a
multi-line comment.
*/
