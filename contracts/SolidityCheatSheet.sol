// SPDX-License-Identifier: GPL-3.0
/**
 * SPDX tells that source code is licensed under the GPL version 3.0. Machine-readable license
 * It is included as string in the bytecode metadata.
 */

/**
 * pragma solidity x.y.z 
 * "pragma" keyword is used to enable certain compiler features or checks
    - where x.y.z indicates the version of the compiler 
        a different y in x.y.z indicates breaking changes & z indicates bug fixes.
    - Versioning is to ensure that the contract is not compatible with a new (breaking) compiler version, to avoid behaving differently
 * another e.g. pragma solidity ^0.4.16; -> doesn't compile with a compiler earlier than version 0.4.16, and 
    - floating pragma `^` represents it neither compiles on compiler 0.y.0(where y > 4).
    - Locking the pragma (for e.g. by not using ^ ahead of pragma) ensures that contracts do not accidentally get deployed using any other compiler version
*/
pragma solidity >=0.4.16 <0.9.0;
// ^ Source code is written for Solidity version 0.4.16, or a newer version of the language up to, but not including version 0.9.0

/**
 * ABI coder (v2) is able to encode and decode arbitrarily nested arrays and structs, 
    can also return multi-dimensional arrays & structs in functions.
 * Default since Solidity 0.8.0 & has all features of v1 
*/
pragma abicoder v2;

/**
 *  imports all global symbols from “filename” (and symbols imported there) into current global scope
    not recommended as any items added to the “filename” auto appears in the files
*/
import "./Add.sol";

/**
 * & to import specific symbols explicitly
 * equivalent to -> import * as multiplier from "./Mul.sol";
 */
import "./Mul.sol" as multiplier;

/**
 * External imports are also allowed from github -> import "github/filepath/url"
 * using 'as' keyword while importing to avoid naming collision
 */
//
import {divide2 as div, name} from "./Div.sol";

/**
 * Functions are the executable units of code, usually defined inside a contract, 
    but can also be defined outside of contracts(called Free Functions).
    Free function's visibility cannot be set(and are internal by default).
*/
function outsider(uint256 x) pure returns (uint256) {
    return x * 2;
}

// struct can be declared outside contract
struct User {
    address addr;
    string task;
}

/**
 * Contract is marked as abstract when at least one of it's function is not implemented
 * Abstract contracts cannot be deployed on their own but can be inherited by other contracts.
 * Allows for code reuse and helps to reduce the amount of code duplication in smart contracts.
 */
abstract contract Tesseract {
    function retVal(uint256 x) public virtual returns (uint256);

    function get() external view virtual returns (uint) {
        return 5;
    }
}

/** 
 * Interfaces are similar to abstract, but :
    - They cannot have any functions implemented. 

    - They can inherit from other interfaces but not from contracts

    - All declared functions must be external, even if they are public in the contract.

    - They cannot declare state variables, modifiers or constructor
*/
interface IERC20 {
    enum Type {
        Useful,
        Useless
    }
    struct Demo {
        string dummy;
        uint256 num;
    }

    function transfer(address, uint) external returns (bool);
}

// contract inheriting from abstract contract must implement all non-implemented to avoid itself being marked as abstract.
contract Token is Tesseract {
    uint public totalSupply;
    uint private _anon = 3;

    constructor(uint x) payable {
        require(x >= 100, "Insufficient Supply");
        totalSupply = x;
    }

    function transfer(address, uint) external {}

    /**
     * `virtual` means the function & modifiers can change its behavior in derived class
     * `override` means this function, modifier or state variables has changed its behavior from the base class
     * private function or state variables can't be marked as virtual or override
     */
    function retVal(uint a) public virtual override returns (uint) {
        return a + 10;
    }

    function updateSupply(uint _x) external payable {
        totalSupply = _x + msg.value;
    }

    function _add(uint val) internal view returns (uint) {
        return _anon + val;
    }

    function _mulPriv(uint val) private view returns (uint) {
        return _anon * val;
    }

    function get() external view virtual override returns (uint) {
        return _anon;
    }
}

contract Coin {
    constructor(uint coinAmount) {}

    function retVal(uint c) public pure virtual returns (uint) {
        return c % 10;
    }
}

contract SpecialCoin is Coin {
    constructor(uint coinAmount) Coin(coinAmount) {}

    function retVal(uint spC) public pure virtual override returns (uint) {
        return spC - 10;
    }
}

/**
 * Inheritance means that components of the parent contracts are "merged" into the child contract
    The parent contracts do not need to be deployed, as everything can be accessed through the child.
    Order of "merging" is that the right most contracts override those on the left.
 *  Example Graph of inheritance :
         A
        / \
       B   C
      / \ /
     F  D,E
    
    here 'A' is Base contract, 'B' & 'C' inherits from 'A' and 'F' derives from 'B', 
    while 'D' & 'E' derives both from 'B' and 'C'
 * The order of inheritance should start from “most base-like”(contract that inherits least, usually an interface) to “most derived” (that inherits other contract most)
    A -> B,C -> F -> D,E
 * Use of 'is' to derive from another contract
 * Constructors of contracts are executed in the order of their inheritance, e.g. here : Coin, Token & then that of Currency
*/
contract Currency is
    Coin,
    Token(100), // if arguments is known at time of writitng code, parent's constructor can be called here
    SpecialCoin
{
    constructor(uint _amnt) SpecialCoin(_amnt) {} // if arguments are determined while contract deployement then argument can be passed through a "modifier" of the parent contract

    function intTest() public view returns (uint) {
        return _add(5); // access to internal member (from derived to parent contract)
    }

    /// @inheritdoc Coin Copies all missing tags from the base function (must be followed by the contract name)
    /**
     * Functions can be overridden with the same name, number & types of inputs,  
        change in output parameters causes an error.
     * Override functions can change mutability
        - external to public
        - nonpayable to view/pure
        - view to pure 
     * specify the `virtual` keyword again indicates this function can be overridden again.
     * during muliple inheritance parents contract are serached from right to left
     * since SpecialCoin is the right most parent contract with this function thus it will internal call SpecialCoin.retVal
    */
    function retVal(
        uint a
    ) public pure virtual override(Coin, Token, SpecialCoin) returns (uint) {
        // super keyword calls the function one level higher up in the flattened inheritance hierarchy
        return super.retVal(a);
    }

    // Public state variables can override external getter functions of the variable
    uint public override get;
}

/**
 * Libraries are similar to contracts, but :
        - no state variable 
        - no inheritance
        - cannot hold ether
        - cannot be destroyed
 * A library is embedded into the contract if all library functions are internal 
    and EVM uses JUMP for calling its function similar to a internal function calls
 * External library :
        - are deployed to unique address and 
        - need to be linked with calling contract at the time of deployment (takes up space in bytecode)
        - uses DELEGATECALL which also prevents libraries from killing by SELFDESTRUCT() as it would brick contracts using the library.
 * A library can be attached to a data type inside a contract (only active within that contract:
        - using Root for uint256            attaches all functions of Root to uint256
        - using Root for *                  attaches all functions of Root to all types
        - using { Root.sqrt } for uint256   attaches just sqrt functions of Root to uint256
 * These functions will receive the object they are called on as their first parameter.
*/
library Root {
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) external pure returns (bool, uint256) {
        // after v0.8 unchecked does not let code revert and allows over/under flow arithmetic operations inside it's block
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
}

/**
 * NatSpec is for formatting for contract, interface, library, function & event comments which are understood by Solidity compiler.
 * @title Title describing contract/interface
 * @author Name of author
 * @notice Explain the functionality
 * @dev any extra details for the developer
 * @custom:custom-name tag's explanation
 */
contract SolidityCheatSheet {
    // All identifiers (contract names, function names and variable names) are restricted to the ASCII character set(0-9,A-Z,a-z & special chars.)

    /**
     * contract instance of "Token" to interact with it
     * variable of contract type can be Explicitly converted to and from the address payable type
     */
    Token _tk;

    /**
    fallback() or receive ()?

    Ether is sent to contract
            |
    is msg.data empty?
            /  \
          yes   no
          /       \
receive() exists?  fallback()
        /  \
      yes   no
      /      \
receive()   fallback()
*/
    /**
     * Fallback & receive functions must be external.
     * Both can rely on just 2300 gas being available to prevent re-entry
        as this gas is not enough to modify any state
     */
    receive() external payable {
        emit Log("receive", gasleft());
    }

    /**
     * Fallback are executed if none of other function signature is matched,
        can even be defined as non-payable to only receive message call
     * fallback can be virtual, override & have modifiers 
    */
    fallback(bytes calldata data) external payable returns (bytes memory) {
        // after v0.8.0, fallback can optionally take bytes as input & also return
        (bool success, bytes memory res) = address(0).call{value: msg.value}(
            data
        );
        require(success, "call failed");
        //returns remaining gas
        return res;
    }

    /**
     * State Variable is like a single slot in a database that are accessible by functions
        and there values are permanently stored in contract storage.
     * Visibility : 
            - public : auto. generates a function that allows to access the state variables even externally
            - internal : can't be accessed externally but only in there defined & derived contracts
            - private : similar to internal but not accessible in derived contracts 
     * private or internal variables only prevents other contracts from accessing the data stored, 
        but it can still be accessible via blockchain
    * State variables can also declared as constant or immutable, values can't modified after contract is constructed
    */

    /** 
     * constants doesn't take storage space but is included in contract's bytecode
     * values need to be fixed at compile time 
     * Not allowed any expression :
            - that accesses storage
            - blockchain data (e.g. block.timestamp, address(this).balance) or 
            - execution data (msg.value or gasleft()) or 
            - making calls to external contracts is disallowed
    */
    string public constant THANOS = "I am inevitable";

    // value can assigned to immuatble variable in constructor but isn't accessible during time of contract's construction
    uint public immutable senderBalance;

    /**
     * Variable Packing
     * Multiple state variables depending on their type(that needs less than 32 bytes) can be packed into one slot
     * Packing reduces storage slot usage but increases opcodes necessary to read/write to them.
     */

    uint248 _right; // 31 bytes, Doesn't fit into the previous slot, thus starts with a new one
    uint8 _left; // 1 byte, There's still 1 byte left out of 32 byte slot
    //^ one storage slot will be packed from right to left with the above two variables (lower-order aligned)

    /**
     * Structs, mappings and array data always start a new slot
     
     * Dynamically-sized array's length is stored as the first slot at location p, 
        it's values start being stores at keccak256(p) one element after the other, 
        potentially sharing storage slots if the elements are not longer than 16 bytes.

     * Mappings leave their slot p empty (to avoid clashes), 
        the values corresponding to key k are stored at keccak(h(k) + p) 
        with h() padding value to 32 bytes or hashing reference types.

     * Bytes and Strings 
        - stored like array elements and data area is computed using a keccak256 hash of the slot's position.
        - Bytes are stored in continuous memory locations while strings are stored as a sequence of pointers to memory locations
        - For values less than 32 bytes, elements are stored in higher-order bytes (left aligned) and the lowest-order byte stores value (length * 2)
            whereas bytes of 32 bytes or more, the main slot stores (length * 2 + 1) and the data is stored as usual in keccak256(p).
     
     * In case of inheritance, order of variables is starting with the most base-ward contract & do share same slot

     * Layout in Memory(Reserves certain areas of memory) :
        -First 64 bytes (0x00 to 0x3f) used for storing temporarily data while performing hash calculations
        - Next 32 bytes (0x40 to 0x5f) also known as "free memory pointer" keeps track of next available location in memory where new data can be stored
        - Next 32 bytes (0x60 to 0x7f) is a zero slot that is used as starting point for dynamic memory arrays that is initialized with 0 and should never be written to.
     * New objects in Solidity are always placed at the free memory pointer and memory is never freed.

     * There's no packing in memory, calldata or function arguments as they are always padded to 32 bytes
        e.g., following array occupies 32 bytes (1 slot) in storage, but 128 bytes (4 items with 32 bytes each) in memory.
     */
    uint8[4] _slotA;

    // Following struct occupies 96 bytes (3 slots of 32 bytes) in storage, but 128 bytes (4 items with 32 bytes each) in memory.
    struct S {
        uint a;
        uint b;
        uint8 c;
        uint8 d;
    }

    function packing()
        external
        view
        returns (
            uint256 leftSlot,
            uint256 rightSlot,
            bytes32 value,
            uint256 leftOffset,
            uint256 leftValue
        )
    {
        assembly {
            /**
             * returns the slot position in storage at which the variable is stored
             * both would return the same slot(because of variable packing sharing same slot)
             */
            leftSlot := _left.slot
            rightSlot := _right.slot

            /**
             * fetches value stored at the slot where variable 'right' & 'left'
                returned value will be concatenated representation of both values (in bytes)
                e.g. bytes32: value 0x0000000000000000000000000000000200000000000000000000000000000001
                considering if right = 2 & left = 1
             */
            value := sload(rightSlot)

            // offset tells the exact position (in terms of bytes) in a slot where the variable values start
            leftOffset := _left.offset // will return 31 as the start of variable 'left' will begin where the previous ('right' of 31 bytes) stops

            /**
             * To get the value on the leftmost side of the slot, it need to be shifted to right.
                During shifting the rightmost value will "fall out" of the slot leaving the leftSide filled with zeros.
                leftOffset of 31 bytes (248 bits) that will be shifted:
             */
            leftValue := shr(mul(leftOffset, 8), value) // 0x0000000000000000000000000000000000000000000000000000000000000002
        }
    }

    /** 
        Value Types : These variables are always be passed by value, 
        i.e. they are always copied when used as function arguments or in assignments.
    */

    /**
     * Integers exists in sizes(from 8 up to 256 bits) in steps of 8
     * uint and int are aliases for uint256 and int256, respectively
     */
    uint256 _storedData; // unsigned(only positive) integer of 256 bits

    // access the minimum and maximum value representable by the integer type
    function integersRange() external pure returns (uint, uint, int, int) {
        return (
            //uintX range
            type(uint8).max, // 2**8 - 1
            type(uint16).min, // 0
            // int : Signed Integer
            // intX range
            type(int32).max, // (2**32)/2 - 1
            type(int64).min // (2**64)/2 * -1
        );
    }

    /**
     * Address holds 20 byte(160 bits) value and is suitable for storing addresses of contracts, or external accounts.
     * address(0) aka zero addresses private key is unknown
     * thus Ether and tokens sent to this address cannot be retrieved and setting access control roles to this address also won’t work
     */
    address public owner; // ^ Equivalent to -> function owner() public view returns (address) { return owner; }
    /**
     * address with transfer and send functionality to receive Ether
     * Implicit conversions from address payable to address are allowed
     */
    address payable public treasury;

    // Boolean holds 1 byte value (0 or 1) possible values are true and false
    bool public isEven;

    function boolTesting(bool _x, bool _y, bool _z) public pure returns (bool) {
        // Short-circuiting rule: full expression will not be evaluated
        // if the result is already been determined by previous variable
        return _x && (_y || _z);
    }

    /**
     * bytesN is value data type Fixed size byte array of size N bytes (range : 1 to 32)
     * bytes store every data as hexadecimal format (0x...)
     */
    bytes2 public k;

    function fixedByte() public returns (bytes1) {
        // hex is 4 bits , thus 2 hex characters makes 1 bytes
        k = 0x5661;
        k = "ab"; // stored as 0x6162

        bytes3 j = hex"32"; // stored as 0x320000
        j = "abc";
        // j[0] = "d"; Single bytes in Fixed sized bytes array cannot be modified

        // can access particular element of byte array
        return (k[0]);
    }

    // Fixed point numbers aren't yet supported and thus can only be declared
    fixed _xFix;
    ufixed _yUfx;

    function literals()
        external
        pure
        returns (
            address,
            uint,
            int,
            uint,
            string memory,
            string memory,
            string memory,
            bytes20,
            int[2] memory
        )
    {
        return (
            // Hexadecimal literals that pass the address checksum test are considered as address
            0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF,
            /** 
             * Division on integer literals e.g. 5/2 prior to version 0.4.0 is equal to 2 but now it's rational number 2.5
             * but consider an e.g. where,
                uint x = 1;
                uint y = 5/2 + x + 0.5;  
                this will returns compiler error, as operators works only on common value types
            */
            5 / 2 + 1 + 0.5, //  = 4
            /**
             * decimals fractional formed by . with at least one number after decimal point
             * .1, 1.3 are correct but not 1.
             * Scientific notation of type MeE means M * 10**E
             */
            -.2e10,
            // Underscores have no meaning (just eases human readability)
            1_2e3_0, // = 12*10**30
            // string literal can be represented in " " or ' '
            "yo"
            "lo", // can be split = "yolo"
            "abc\\def", // also supports various escape characters
            //unicode
            unicode"Made by Akshit 👨‍💻 with ❤️",
            //Random Hexadecimal literal behave just like string literal
            hex"00112233_44556677",
            /**
             * array literals are comma-separated list of one or more expressions
             * typed by that of its first element & all its elements can be converted to this type
             */
            [int(1), -1] // int type array literal
        );
    }

    /**
     * Container Type : Are the data types which is used to store and organize data.
     * e.g. are enums, arrays, mappings & Struct
     */

    /**
     * Enums are user-defined type of predefined constants which holds uint8 values (max 256 values)
     * First value is default & starts from 0
     * They can even be stored outside of Contract & in libraries as well
     */
    enum Status {
        Manufacturer,
        Wholesaler,
        Shopkeeper,
        User
    }
    Status public status;

    /**
     * enums are not stored in ABI
     * thus in ABI 'updateStatus()' will have its input type as uint8
     */
    function updateStatus(Status _status) public {
        status = _status;
    }

    // Accessing boundaries range values of an enum
    function enumsRange() public pure returns (Status, Status) {
        return (
            type(Status).max, // return 3, indicating 'User'
            type(Status).min // return 0, indicating 'Manufacturer'
        );
    }

    /**
     * User Defined Value Types allows creating a zero cost abstraction over an elementary value type
     * type C is V , C is new type & V is elementary type
     * type conversion, operators aren't allowed
     */
    type UFixed256x18 is uint256; // Represent a 18 decimal, 256 bit wide fixed point

    /**
     * custom types only allows wrap and unwrap
     * wrap converts underlying type -> custom type
     * unwrap converts custom type -> underlying type
     */
    function _customMul(
        UFixed256x18 _x,
        uint256 _y
    ) internal pure returns (UFixed256x18) {
        return UFixed256x18.wrap(UFixed256x18.unwrap(_x) * _y);
    }

    /**
     * Function Types is a variable that is pointing to a function 
        and parameter of these variable can be used to pass a function as an argument to another function 
        or return a function from a function call.

     * variants : 
        - Internal : can only be called inside the current contract(including internal library and inherited functions)
            internal/private/public functions are assignable to internal function type 
        - External : calls originated from other contract, containing address and a function signature 
            external/public functions are assignable to external function type (excluding libraries function as they use delegatecall)

     * Conversion function type A is implicitly convertible to a function type B if :
        - their parameter, return types & visibility are identical
        - state mutability of A is more restrictive than the state mutability of B. 
            - pure functions can be converted to view and non-payable functions
            - view functions can be converted to non-payable functions
            - payable functions can be converted to non-payable functions

     * External functions and function types with calldata parameters are incompatible with each other at least one should have memory parameters
     */

    // External & public functions has members
    function f() public payable returns (bytes4) {
        assert(this.f.address == address(this)); //address of the contract where function is located
        this.transferringFunds{gas: 10, value: 800}(payable(address(0))); // specifies amount of gas or ether sent to a function
        return this.f.selector; // returns function selector
    }

    /**
     * Reference Types : Values can be modified through multiple different names unlike Value type
        when passed as an argument or returned in a function, a reference to the value is passed or returned and not a copy.
        always have to define the data locations for the variables
    */

    /**
     * Structs is a group of multiple related variables
     * can even be passed as parameters in functions
     */
    struct Todo {
        uint[] steps;
        bool initialized;
        address owner;
        uint numTodo;
        User user; // can contain other struct but not itself
        // mapping(uint => address) reader;
    }
    Todo[] public todoArr; // arrays of struct

    function onStruct(uint[] memory _arr, uint _index) external {
        // Initializing structs values

        // 1. initializing individually as reference
        Todo storage t = todoArr[_index];
        t.steps = _arr;
        t.initialized = true;
        t.owner = msg.sender;
        t.user = User(msg.sender, "foo");

        // 2. key: value mapping by creating a struct in memory
        todoArr.push(
            Todo({
                steps: _arr,
                initialized: true,
                owner: msg.sender,
                numTodo: _index,
                user: User({addr: msg.sender, task: "foo"})
            })
        );

        // 3. passing as arguments through struct memory
        todoArr.push(
            Todo(_arr, true, msg.sender, _index, User(msg.sender, "foo"))
        );

        // 4. adds new element to end of array and then set the value of a particular field in that element leaving all other fields to there default
        todoArr.push().numTodo = 45;

        // accessing struct
        t.owner; // returns the value stored 'owner'

        /**
         * Struct containing a nested mapping can't be constructed though memory
         * t.reader[_index] = tx.origin;         mapping can be initialized by storage reference to struct
                              ^ gives source sender's address of the transaction as transactions can originate only from Externally Owned Account (EOA)
         * Todo({reader[_index]: tx.origin;})  will give Error
         */
    }

    // Arrays
    uint[] public dynamicSized; // length of a dynamic array is stored at the first slot of array and followed by its elements
    uint[2 ** 3] _fixedSized; // array of 8 elements all initialized to 0
    uint[][4] _nestedDynamic; // an array of 4 dynamic arrays
    bool[3][] _triDynamic; // Dynamic Array of a fixed sized arrays each of length 3
    uint[] public arr = [1, 2, 3]; // pre assigned array
    uint[][] _freeArr; // Dynamic array of multi dynamic arrays

    function aboutArrays(
        uint _x,
        uint _y,
        uint _value,
        bool[3] memory _newArr,
        uint size
    ) external {
        // Creating memory arrays
        uint[] memory a = new uint[](7); // Fixed size memory array
        uint[2][] memory b = new uint[2][](size); // Dynamic memory array
        /**
         * fixed size array can't be converted/assigned to dynamic memory array
         * uint[] memory x = [uint(1), 3, 4];  gives Error
         * Unlike storage arrays, memory or fixed size array can't be resized i.e. push or pop is invalid
         */

        // assigning to arrays
        for (uint i = 0; i <= 7; i++) {
            a[i] = i; // assigning elements individually
        }
        _triDynamic.push(_newArr); // pushes a array of 3 element to a Dynamic array

        // arrays in struct
        Todo storage g = todoArr[0]; // reference of 'Todo' in 'g'
        g.steps = a; // changes in 'Todo' also

        // Accessing array's elements
        b[_x][_y]; // returns the element at index 'y' in the 'x' array
        _nestedDynamic[_x]; // returns the array at index 'x'
        arr.length; // returns number of elements of an array

        // Only dynamic storage arrays are resizable

        // adding elements
        dynamicSized.push(_value); // appends new element at end of array , equivalent dynamicSized.push() = _value;
        dynamicSized.push(); // appends zero-initialized element

        // removing elements
        dynamicSized.pop(); // remove end of array element
        delete arr; // removes all elements of array
        _triDynamic = new bool[3][](0); // similar to delete array
    }

    /**
     * slicing of array[start:end]
     * 'start' default is 0 & 'end' is upto array's length
     * only works with calldata array as input
     */
    function slice(
        uint[] calldata _arr,
        uint startIndex,
        uint endIndex
    ) public pure returns (uint[] memory) {
        return _arr[startIndex:endIndex];
    }

    // Special arrays of Reference type are dynamic sized bytes array and string

    /**
     * bytes represents arbitrary length raw byte data
     * bytes are similar to bytes1[] but tightly packed (w/o padding)
     */
    bytes _tps;

    // String represents dynamic array of UTF-8 characters
    string _kmp;

    function bytesNstring(
        bytes memory _bc,
        string memory _tmc
    ) public returns (uint) {
        _tps = _bc;
        _kmp = _tmc;

        // like array, only storage bytes can be resized
        _tps.push(0x61);
        _tps.push("b");

        _tps.pop();

        /**
         * only 1 byte can be pushed at a time
         * Error: 
                _tps.push('bcd');
                _tps.push(0x6162);
         */

        return _tps.length;
    }

    function bytesOperations(
        string calldata _str,
        bytes2 sm
    ) public pure returns (uint, bytes1, bool, string memory, bytes memory) {
        return (
            // string length & element cannot be accessed directly thus accessing byte-representation of string
            bytes(_str).length, // length of bytes of UTF-8 representation
            bytes(_str)[2], // access element of UTF-8 representation
            keccak256(abi.encodePacked("foo")) ==
                keccak256(abi.encodePacked("Foo")), //compare two strings
            // concatenate
            string.concat("foo", "bar"),
            bytes.concat(bytes(_str), sm)
        );
    }

    /**
     * Mappings are like hash tables which are virtually initialized such that, 
        every possible key is mapped to a value whose byte-representation is all zeros.
     * Not possible to obtain a list of all keys or values of a mapping, 
        as keccak256 hash of keys is used to look up value.
     * only allowed as state variables but can be passed as parameters only for library functions 
     * Key Type can be inbuilt value types, bytes, string, enum but not user-defined, mappings, arrays or struct
     * while the Values of mappings can be of any type
    */
    mapping(address => uint256) public balances;

    /**
     * Solidity stores data as :
        1. storage - stored on blockchain as 256-bit to 256-bit key-value store 
        2. memory 
            - is a linear byte-array, addressable at a byte-level 
            - is modifiable & exists while a function is being called 
            - can store either 1 or 32 bytes at a time in memory, but can only read in chunks of 32 bytes
        3. calldata - non-modifiable area where function arguments are stored and behaves mostly like memory
     * Prior to v0.6.9 data location was limited to calldata in external functions
     */
    function dataLocations(
        uint[] memory memoryArray,
        uint[3] memory secArray
    ) public {
        dynamicSized = memoryArray; // Assignments between storage & memory or from calldata always creates independent copies
        uint[] storage z = dynamicSized; // Assignments to a local storage from global storage, creates reference.
        z.pop(); // also modifies array "dynamicSized" via "z"

        // Assignment from memory to memory only create references
        uint[3] memory kl = secArray;
        uint[3] memory j = kl;
        // change to one memory variable are visible in all other memory variable referring same data
        delete j[1];
        assert(kl[1] == j[1]);

        /**
         * delete resets to the default value of that type
         * it doesn't works on mappings (unless deleting a individual key)
         */
        delete dynamicSized; // clears the array "dynamicSized" & "z"
        delete dynamicSized[2]; // resets third element of array w/o changing its length

        /**
         * Assigning memory to local storage doesn't work as
            it would need to create a new temporary/unnamed array in global storage, 
            but storage is allocated at compile time & not runtime.
            z = memoryArray; gives out error

         * Cannot "delete z" as referencing global storage objects can only be made from existing local storage objects.
        */
    }

    /**
     * Operators result type of operation determined based on type of operand to which other operand can be implicitly converted to
     * '==' operator is not directly compatible with dynamically-sized types, as the length of these arrays can vary.
     * equality operator can only be used to compare values of certain types, such as integers and fixed-size byte arrays.
     */

    // Ternary Operator : if <expression> true ? then evaluate <true Expression>: else evaluate <false Expression>
    uint _tern = 2 + (block.timestamp % 2 == 0 ? 1 : 0);

    // _tern = 1.5 + (true ? 1.5 : 2.5); is NOT valid, as rational number aren't convertible to uint

    // pre and post fix increment or decrement operators are used to increase or decrease the value of a variable by 1.
    function postPreFix()
        external
        pure
        returns (uint r, uint s, uint t, uint u)
    {
        uint p = 10;
        // PostFix : returns the value of the variable before it has been incremented/decremented
        r = p++; // 10
        // now p = 11
        s = p--; // 11
        // now p = 10

        uint q = 20;
        // PreFix : returns the value of the variable after it has been incremented/decremented
        t = ++q; // 21
        // now q = 21
        u = --q; // 20
    }

    // Bitwise Operator
    function bitwiseOperate(
        uint a,
        uint c
    ) external pure returns (uint, uint, uint, uint, uint, uint) {
        return (
            /**
             * AND
             * a     = 1110 = 8 + 4 + 2 + 0 = 14
             * c     = 1011 = 8 + 0 + 2 + 1 = 11
             * a & c = 1010 = 8 + 0 + 2 + 0 = 10
             */
            a & c,
            /**
             * OR
             * a     = 1100 = 8 + 4 + 0 + 0 = 12
             * c     = 1001 = 8 + 0 + 0 + 1 = 9
             * a | c = 1101 = 8 + 4 + 0 + 1 = 13
             */
            a | c,
            /**
             * NOT
             * a  = 00001100 =   0 +  0 +  0 +  0 + 8 + 4 + 0 + 0 = 12
             * ~a = 11110011 = 128 + 64 + 32 + 16 + 0 + 0 + 2 + 1 = 243
             */
            ~a,
            /**
             * XOR -> if bits are same then 0, if different then 1
             * a     = 1100 = 8 + 4 + 0 + 0 = 12
             * c     = 0101 = 0 + 4 + 0 + 1 = 5
             * a ^ c = 1001 = 8 + 0 + 0 + 1 = 9
             */
            a ^ c,
            /**
             * shift left
             * 1 << 0 = 0001 --> 0001 = 1
             * 1 << 1 = 0001 --> 0010 = 2
             * 1 << 2 = 0001 --> 0100 = 4
             * 3 << 2 = 0011 --> 1100 = 12
             */
            a << c,
            /**
             * shift right
             * 8  >> 1 = 1000 --> 0100 = 4
             * 8  >> 4 = 1000 --> 0000 = 0
             * 12 >> 1 = 1100 --> 0110 = 6
             */
            a >> c
        );
    }

    function _typeConversion()
        internal
        pure
        returns (uint32 foobar, uint j, uint16 m, bytes1 p)
    {
        /**
         * Implicit Conversions
            - compiler auto tries to convert one type to another
            - conversion is possible if makes sense semantically & no information is lost
        */
        uint8 foo;
        uint16 bar;
        foobar = foo + bar; // during addition uint8 is implicitly converted to uint16 and then to uint32 during assignment

        /**
         * Explicit Conversions
            - if you are confident and forcefully do conversion
            - converting to a smaller type, higher-order bits are cut off
            - converting to a larger type, it is padded on the left
        */
        int kt = -3;
        j = uint(kt);

        // when uint is converted to a smaller size uint the high order bytes are cut off and only taken from right end
        uint32 l = 0x12345678;
        m = uint16(l); // m will be 0x5678 now

        // If an integer is explicitly converted to a larger type, it is padded on the left (i.e., at the higher order end)
        uint32 t = uint32(m); // t would become 0x00005678

        // uint16 c = uint16(0x123456); gives out error, since it would have to truncate to 0x3456 and since v0.8 only hexadecimal to integer conversion allowed if in resulting range

        // when byte is converted to a smaller size byte its taken from the left end
        bytes2 n = 0x1234;
        p = bytes1(n); // b will be 0x12

        // If a fixed-size bytes type is explicitly converted to a larger type, it is padded on the right.
        bytes2 za = 0x1234;
        bytes4 zb = bytes4(za); // b will be 0x12340000
    }

    // Units works only with literal number
    function _units() internal pure {
        // Ether units
        assert(1 wei == 1);
        assert(1 gwei == 1e9);
        assert(1 ether == 1e18);

        // Time
        assert(1 seconds == 1);
        assert(1 minutes == 60 seconds);
        assert(1 hours == 60 minutes);
        assert(1 days == 24 hours);
        assert(1 weeks == 7 days);
        uint t = 5;
        t * 1 days; // as t days doesn't work
    }

    function _blockProperties(
        uint _blockNumber
    )
        internal
        view
        returns (
            bytes32,
            uint,
            uint,
            address,
            uint,
            /**uint,*/ uint,
            uint,
            uint,
            uint,
            uint
        )
    {
        return (
            blockhash(_blockNumber), // hash of block(one of the 256 most recent blocks)
            block.basefee, // current block's base fee
            block.chainid, // returns the ID of the blockchain that the current transaction is executing on
            block.coinbase, // current block miner’s address
            block.difficulty, // deprecated for EVM versions previous Paris
            // block.prevrandao(_blockNumber),     random number provided by the beacon chain (EVM >= Paris)
            block.gaslimit, // current block's gas limit
            block.number, // block number in which the current transaction is mined
            block.timestamp, // timestamp as seconds of when block is mined
            gasleft(), // remaining gas
            tx.gasprice // gas price of transaction
        );
    }

    function _encodeDecode(
        uint f1,
        uint[3] memory g,
        bytes memory h
    )
        internal
        pure
        returns (bytes memory, bytes memory, bytes memory, bytes32)
    {
        // Encoding
        bytes memory encodedData = abi.encode(f1, g, h); // encodes given arguments

        /**
         * This method has no padding, thus one variable can merge into other resulting in Hash collision, 
            only useful if types and length of parameters are known
            e.g. encodePacked   (AAA, BBB) -> AAABBB
                                (AA, ABBB) -> AAABBB
            use abi.encode to solve it
        */
        abi.encodePacked(f1, g, h);

        // Decoding
        uint _f;
        uint[3] memory _g;
        bytes memory _h;
        (_f, _g, _h) = abi.decode(encodedData, (uint, uint[3], bytes)); // decodes the encoded bytes data back to original arguments
        assert(_f == f1);

        return (
            // encodes arguments from the second parameter and prepends the given four-byte selector
            abi.encodeWithSelector(this.bitwiseOperate.selector, 12, 5), // arguments type is not checked
            abi.encodeWithSignature("bitwiseOperate(uint,uint)", 14, 10), // typo error & arguments is not validated
            abi.encodeCall(IERC20.transfer, (address(0), 12)), // ensures any typo and arguments types match the function signature
            // Hashing
            keccak256(abi.encodePacked("Solidity"))
            /**
             * similarly :
                - sha256(bytes memory)
                - ripemd160(bytes memory) 
            */
        );
    }

    // Loops in solidity
    function loopingLoop(
        uint8 val
    ) external pure returns (uint256 forLooped, uint256 whileLooped) {
        for (uint i = 0; i <= val; i++) {
            if (i % 5 == 0) {
                continue; // skip the remaining block of code and starts the next iteration of the loops
            }
            if (i == 20) {
                break;
            }
            forLooped = i;
        }

        uint j;
        while (j <= val) {
            // Runs until the condition is true
            j++;
            if (j % 5 == 0) {
                continue;
            }
            if (j == 20) break; // terminates the loop & exits out of the block of present loop code
            whileLooped = j - 1;
        }
    }

    function contractInfo()
        external
        pure
        returns (string memory, string memory, bytes4)
    {
        return (
            // Name of Contract / Interface.
            type(Token).name,
            type(IERC20).name,
            // EIP-165 interface identifier of the given interface
            type(IERC20).interfaceId

            /**
             * type(Test).creationCode :
                    deployed contract creation/deployement time bytecode, especially which are created using the create2 opcode.
             * type(Test).runtimeCode :
                    runtime bytecode of contract that deployed through constructor(assembly code) of other contract.
             */
        );
    }

    /**
     * Constructor(is optional) code only runs during the contract deployment
     * State variables are initialized before the constructor code is executed
     * After execution of constructor the final code deployed on chain does not include :
                                                                                - constructor code or 
                                                                                - any internal functions call through it
    */
    constructor(bytes32 _salt) payable {
        /**
         * "msg" is a special global variable that allow access to the blockchain data
         * msg.sender: is always the address where the current (external) function call came from.
         * msg.value: The amount of Ether/Wei deposited or withdrawn by the msg.sender.
         * msg.sig: Returns the first 4 bytes of the call data of any function i.e function signature which helps to identify the function which is being called.
         * msg.data: Complete calldata.
         * msg.gas: Remaining gas.
         */
        owner = msg.sender;
        senderBalance = owner.balance; // .balance is used to query the balance of address in Wei
        balances[owner] = 100; // assigning value to mapping "balances"
        _createContract(_salt);
    }

    /**
     * Modifiers can be used to change the behavior of functions 
        in a declarative way(take away control flow for logic)

     * Modifier Overloading (same modifier name with different parameters) is not possible.
     * Like functions, modifiers can be overridden via derived contract(if marked 'virtual')
     * Multiple modifiers in functions are evaluated in the order presented (left to right)
    */
    modifier onlyOwner() /** can even pass arguments */ {
        require(msg.sender == owner, "Not Owner");
        _; // The function body is inserted where the underscore is placed(can be multiple),
        // any logic mentioned after underscore is executed afterwards full function code is executed
    }

    /**
     * Events allow clients to react to specific state change
     * Web app can listen for these events, the listener receives the arguments sender and value, to track transactions.
     * E.g. Listeners using web3js :
        ContractName.Stored().watch({}, '', function(error, result) {
        if (!error) {
             console.log("Number stored: " + result.args.value +
                 " stored by " + result.args.sender +".");
             }
         })
     */
    event Stored(address sender, uint256 value);

    /**
     * for filtering certain logs 'indexed'(stores parameter as "topics") attribute can be added up to 3 params
     * All parameters without the indexed attribute are ABI-encoded into the data part of the log
     * Filtering of events can also be done via the address of contract
     */
    event Log(string func, uint indexed gas);

    /**
     * 'anonymous' events can support up to 4 indexed parameters
            - does not stores event's signature as topic
            - not possible to filter for anonymous events by name, but only by the contract address 
            - should be used when contract has only one event such that all logs are known to be from this event 
    */
    event Privacy(
        string indexed rand1,
        string indexed rand2,
        string indexed rand3,
        string indexed rand4
    ) anonymous;

    bytes32 _eventSelector = Log.selector; // stores keccak256 hash of non-anonymous event signature

    /**
     * Custom Errors allow customised names and data for failure situations.
     * Are used in revert statement & are cheaper than using string in revert
     */
    error LowValueProvided(uint value);

    function _createContract(bytes32 _salt) internal {
        // Send ether along with the new contract "Token" creation and () means passing arguments to the contract's constructor
        _tk = new Token{value: msg.value}(3e6);

        /**
         * contract address is computed from creating contract address and nonce 
         * while if salt value is given, address is computed from :
            - creating contract address, 
            - salt & 
            - creation bytecode of the created contract and it's constructor arguments.
        */
        address preComputeAddress = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            _salt,
                            keccak256(
                                abi.encodePacked(
                                    type(Token).creationCode,
                                    abi.encode(3e6)
                                )
                            )
                        )
                    )
                )
            )
        );

        // Create2 opcode is method to deploy a new contract with a deterministic address
        address c = address(new Token{value: msg.value, salt: _salt}(3e6));

        assert(address(c) == preComputeAddress);
    }

    // Modifier usage let only the creator of the contract "owner" can call this function
    function set(uint256 _value) public onlyOwner {
        if (_value < 10) revert("Low value provided");
        _storedData = _value;

        // Block scoping
        uint insideout = 5;
        {
            insideout = 35; // will assign to the outer variable
            uint insideout; // Warning : Shadow declaration but it's visibility is limited only to this block
            insideout = 1000;
            assert(insideout == 1000);
        }
        assert(insideout == 35); // will check for outer variable

        // Stored event emitted
        emit Stored(msg.sender, _value);
    }

    // Payable Function requires calling the function along with some Ether (as msg.value)
    function transferringFunds(address payable _to) external payable {
        /**
         * 'transfer' fails if sender don't have enough balance or if transaction rejected by receiver
         * reverts on failure & stops execution
         * transfer/send has 2300 gas limit to prevent re-entrancy attack
         */
        treasury.transfer(1 wei);

        /**
         * 'send' returns a boolean value indicating success or failure.
         * doesn't stops execution
         * transfer of tokens via 'send' can failed if call stack depth reaches 1024 or if the recipient run out of gas
         */
        bool sent = payable(0).send(1 wei); // payable(0) -> 0x0000000000000000000000000000000000000000
        require(sent, "Send failed");

        /**
         * Call returns a boolean value indicating success or failure and a response data if received.
         * Possible to adjust gas supplied
         * most recommended method to transfer funds, if handled carefully due to complexities of response and gas
         */
        (bool res, bytes memory data) = _to.call{gas: 5000, value: msg.value}(
            ""
        );
        require(res, "Failed to send Ether");

        /**
         * Explicit conversion allowed : 
            - from address to address payable &
            - from uint160, bytes20, contract types to address 
        */
        payable(owner).transfer(address(this).balance); // querying current contract balance in wei
    }

    /**
     * low level call to interact with other contract especially with
        the source code of the called contract is not available in the calling contract
     *  ether and custom gas amount can be sent along
     *  low level calls are not recommended as: 
            - bypasses type checking, function existence check, and argument packing
            - on "revert" cause entire transaction to be reverted (including any changes made prior to low-level call)
    */
    function lowLevelCall(
        address payable _contract
    ) external payable returns (bool success, bytes memory data) {
        // call method to modify any state in calling contract, forwards all remaining gas by default
        (success, data) = _contract.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("dummy(string,uint256)", "hello there", 200)
        );

        // STATICCALL opcode is used when view/pure functions are called such that modifications to the state are prevented

        /**
         * delegatecall to other contract execute it's function but preserves calling contract's state (storage, contract address & balance)
         * i.e. delegatecall from contract A to B : while the code executed is that of contract B, but execution happens in the context of contract A. 
                Such that any reads or writes to storage affect the storage of A, not B.
         * The purpose of delegatecall is to use library code which is stored in another contract as well as used in proxy pattern.
         * Prior to v0.5.0 delegatecall is called callcode
        */
        (success, data) = _contract.delegatecall(
            abi.encodeWithSignature("setVar(uint256)", 35)
        );
        /**
         * ^ If state variables are modified via a low-level delegatecall, 
            the storage layout of the two contracts must be in same order for the called contract,
            to correctly access the storage variables of the calling contract by name. 
        */
    }

    // query the deployed code for any smart contract
    function accessCode(
        address _contractAddr
    ) external view returns (bytes memory, bytes32) {
        return (
            _contractAddr.code, // gets the bytecode of contract
            _contractAddr.codehash // Keccak-256 hash of contract's code
        );
    }

    /**
     * Function Visibility : 
        - external : these calls create an actual EVM message call, 
            they can be called from other contracts and via transactions; 
            and can be accessed internally via this.extFunc()
        - public : can be either called internally eg. pubFunc() or via message calls(externally) like this.pubFunc() 
        - internal : can only be accessed from within the current contract or contracts deriving from it & neither exposed via ABI
        - private : similar to internal but not accessible in derived contracts 
    */
    function canUSeeMe() public view returns (uint) {
        /**
         * _tk._anon() , _tk._mulPriv() will not be accessible due to private visibility and
         * also as this contract doesn't derives from contract Token, _tk._add() (internal func.) will also not be accessible
         */
        return _tk.get();
    }

    function funcCalls(uint[] calldata _data, uint _x, uint _y) public payable {
        /**
         * in external contract call, we can specify value & gas
         * NOTE : calling contractInstance.{value, gas} w/o () at end, 
            will not call the function, resulting in loss of value & gas 
        */
        _tk.updateSupply{value: msg.value, gas: 3000}(5);

        // arguments can be given by name in any order, if they are enclosed in { }
        slice({endIndex: _y, _arr: _data, startIndex: _x});
    }

    /** Functions Mutability :
     * view : functions which can read state & environment variables but cannot modify it
     * Following are considered as state modifying :
        - Writing to state variables 
        - Emitting events 
        - Creating other contracts 
        - Using selfdestruct 
        - Sending Ether via calls 
        - Calling any function not marked view or pure 
        - Using low-level calls 
        - Using inline assembly that contains certain opcodes.
      * pure : functions can neither read or modify state and even can't access environment variables (except msg.sig & msg.data),
                these functions can also use revert as its not considered 'state modification'
    */

    /**
     * Contract can have multiple functions of the same name but with different parameter types called 'overloading'
     * Returns parameters are not taken into consideration for overload resolution
     */
    function twins(uint256 j) public view returns (uint km) {
        km = j * block.timestamp;
    }

    function twins(uint8 j) public pure returns (uint km) {
        km = j * 2;
        // function code could also be the same as that of it's overloaded twin
    }

    function arithmeticFlow(
        uint a,
        uint b
    ) public pure returns (uint u, uint o) {
        // This subtraction will wrap (allows) on underflow.
        unchecked {
            u = a - b;
        }

        o = a - b; // will revert on underflow
    }

    /**
     * Solidity throws an exception if an condition evaluates to false,
     * resulting in revert to previous state via rolling back all changes made to the state so far.
     */
    function errorFound(address payable addr) public payable {
        /**
         * Require validates for :
                - invalid inputs
                - conditions that cannot be detected until time of execution
                - return values from calls made to other functions
        */
        require(msg.value % 2 == 0, "Value sent is not even");

        /**
         * A direct revert can be triggered using the revert statement or the revert function.
         * revert statement -: revert CustomError(args)
         * revert function -:  revert() or revert("error description")
         */
        if (msg.value < 1 ether) revert LowValueProvided(msg.value);

        uint balBeforeTransfer = address(this).balance;
        addr.transfer(msg.value / 2);

        /**
         * Assert should be used at end of function to prevent severe error,
            especially at statement which should never evaluate to 'false' under normal circumstances in bug free code

         * Assert used for:
            - checking Internal errors & invariants
            - validate contract state after making changes
            - check for overflow/underflow
        */
        assert(address(this).balance == balBeforeTransfer - msg.value / 2); // it will fail only if there is any exception while transferring funds

        /**
         * Error(string) is used for regular error conditions
         * Error exception is generated :
                - require() and revert() uses 0xfd(REVERT) error code, this refunds any unused gas until now 

                - If require(statement) evaluates to false.

                - If you use revert() or revert("description").

                - If you perform an external function call targeting a contract that contains no code.

                - If your contract receives Ether via a public function without payable modifier (including the constructor and the fallback function).

                - If your contract receives Ether via a public getter function.
        */

        /**
         * Panic(uint256) is used for errors that should not be present in bug-free code
         * Panic error generated with error code :
                0x00: Used for generic compiler inserted panics.

                0x01: If you call assert with an argument that evaluates to false.
                assert() uses 0xfe(INVALID) opcode which uses up all gas included in transaction

                0x11: If an arithmetic operation results in underflow or overflow outside of an unchecked { ... } block.

                0x12; If you divide or modulo by zero (e.g. 5 / 0 or 23 % 0).

                0x21: If you convert a value that is too big or negative into an enum type.

                0x22: If you access a storage byte array that is incorrectly encoded.

                0x31: If you call .pop() on an empty array.

                0x32: If you access an array, bytesN or an array slice at an out-of-bounds or negative index (i.e. x[i] where i >= x.length or i < 0).

                0x41: If you allocate too much memory or create an array that is too large.

                0x51: If you call a zero-initialized variable of internal function type.
        */

        /**
         * Cases when it can either cause an Error or a Panic (or whatever else was given):
                - If a .transfer() fails.

                - If calling a function via a message call fails 

                - If the contract creation does not finish properly that was created using 'new'
        */
    }

    /**
     * A failure in an external call or while creating contract can be caught using a try/catch statement
     * whenever a "revert" call is executed an exception is generated that propagates up the function call stack until caught by try/catch.
     */
    function tryNcatch(
        address _extContract,
        address _recipient
    ) public returns (bool) {
        try IERC20(_extContract).transfer(_recipient, 100) returns (
            bool success
        ) {
            return (success);
        } catch Error(
            string memory desc // while creating new contract -> try new Token(_totalSupply) returns (Token t)
        ) {
            // This is executed in case revert("string description")
            emit Log(desc, gasleft());
            return (false);
        } catch Panic(uint /**errorCode*/) {
            // executed in case of a panic
            return (false);
        } catch (bytes memory /**lowLevelData*/) {
            // executed in case revert() was used.
            return (false);
        }
    }

    /**
     * Selfdestruct :
     * sends contract ether balance to the designated address
     * then removes contract code from the blockchain
     * but can be retained as it's part of the blockchain's history
     * ether can still be sent to the removed contract but would be lost
     */
    function boom() external {
        // some other code ....

        // if boom() reverts before selfdestruct, it undo the destruction
        selfdestruct(payable(owner)); // Warning : SELFDESTRUCT is deprecated opcode
        /** 
         * When the SELFDESTRUCT opcode is called, ether from the callee contract are sent to the address on the stack, 
            and execution is immediately halted and functions blocking the receipt of Ether will not be executed.

         * self destruct forcefully send eth to a contract even if:
            - the receiving contract has no payable, receive or fallback functions
            - the receiving contract has revert() in receive()
        */
    }

    // accessing library
    function testRoot(uint256 _num) public pure returns (uint) {
        return Root.sqrt(_num);
    }

    /**
     * Inline assembly is way to access EVM at low level(via OPCODES) by passing important safety features & checks of solidity
     * it uses Yul as it's language
     */
    function assemblyTinker(address _addr) public returns (bool) {
        uint256 size;
        // retrieve the size of the code, through assembly
        assembly {
            // variables declared outside assembly block can be manipulated inside
            // assign to variable by :=
            size := extcodesize(_addr) // extcodesize is opcode for length of the contract bytecode(in bytes) store at address _addr

            // no semicolon or new line required
            let a := mload(0x40) // reads and assign (u)int256 from memory at location 0x40
            mstore(a, 2) // writes (u)int256 value 2 as memory to variable 'a'
            sstore(a, 10) // writes (u)int256 value 2 as storage to variable 'a'

            // Supports for loops, if and switch statements and function calls.
            if eq(size, 0) {
                revert(0, 0)
            }

            {
                function switchPower(base, exponent) -> result {
                    switch exponent
                    case 0 {
                        result := 1
                    }
                    case 1 {
                        result := base
                    }
                    default {
                        result := switchPower(mul(base, base), div(exponent, 2))
                        switch mod(exponent, 2)
                        case 1 {
                            result := mul(base, result)
                        }
                    }
                }
            }

            {
                function forPower(base, exponent) -> result {
                    result := 1
                    // variable declarations by let
                    for {
                        let i := 0
                    } lt(i, exponent) {
                        i := add(i, 1)
                    } {
                        // lt opcode is for comparing if i<exponent
                        result := mul(result, base)
                    }
                }
            }
        }
        return (size > 0);
    }

    /**
     * Function Encoded Paramaters
     * Function signature is a string that consists of the function's name and the types of its input parameters. 
            also used to distinguish between overloaded function.
            e.g. a function "transfer" with two input parameters address & uint256, signature is calculated: "transfer(address,uint256)".
        
     * Function selector is a first(left aligned) four-byte of keccak256 hash of function's signature 
            used to identify a specific function in a contract. 
     * Function's selector and signature are used together to call a specific function within a contract. 
     * Function selector is included in the data field of the transaction when a call is made to contract.
     * The contract uses the function selector to determine which function should be executed, 
            and then checks the signature of the function to ensure that the correct input parameters have been provided.

     * Function parsed data is represented as :
            - 4 + 32*N where N is the number of arguments in the function in case of static variables 
            - Static variables are uints, ints, address, bool, bytes1 to bytes32 (including function selector), and tuples (however they can have dynamic variables in them)
            
            - while if dynamic variables are also present 4 + 32*N + 2*(32*D) , here D is number of dynamic variables
            - Dynamic variables are non-fixed-size types, including bytes, string, and dynamic arrays, as well as fixed sized arrays.
            - Dynamic variables encoding are represented by :
                - offset : first 32 bytes representing location of where the variable begins from
                - length : second 32 bytes representing length of the variable
        
     * Argument encoding : Process of encoding function arguments into byte array that serves as input data to contract's function call,
            this input data is later decoded by the contract and are passed to functions in correct format.

        for eg. calling following function with arguments : 
            (53, ["abc", "def"], "dave", true, [1,2,3]) we would pass total 388 bytes as follows :

            - prefix we discard
                0x
            -  function selector/ Method ID (first 4 bytes of selector)
                566145fd
        NOTE : All arguments will be padded to 32 bytes, each arguments are 64 characters(32 bytes) long
            -  uint32  "53" as first parameter 
                0000000000000000000000000000000000000000000000000000000000000035
            -  bytes3  "abc" (left-aligned) as first part of second parameter
                6465660000000000000000000000000000000000000000000000000000000000
            -  "def" (left-aligned) as second part of second parameter
                6162630000000000000000000000000000000000000000000000000000000000
            -  dynamic byte, location of data part of third parameter (dynamic type), measured in bytes from the start of argument block
                00000000000000000000000000000000000000000000000000000000000000c0 // 192th Byte
            -  Boolean ‘true’ as fourth parameter
                0000000000000000000000000000000000000000000000000000000000000001
            -  dynamic array, location of data part of fifth parameter (dynamic type), measured in bytes
                0000000000000000000000000000000000000000000000000000000000000100 // 256th Byte
            -  data part of third argument, starts with length of byte array, in this case, 4
                0000000000000000000000000000000000000000000000000000000000000004
            -  data of third argument UTF-8 (equal to ASCII in this case) encoding of "dave", padded on right to 32 bytes
                6461766500000000000000000000000000000000000000000000000000000000
            -  data part of fifth argument, starts with length of array, in this case, 3
                0000000000000000000000000000000000000000000000000000000000000003
            -  first element of fifth parameter
                0000000000000000000000000000000000000000000000000000000000000001
            -  second element of fifth parameter
                0000000000000000000000000000000000000000000000000000000000000002
            -  third element of fifth parameter
                0000000000000000000000000000000000000000000000000000000000000003

    0    4        36          68         100          132    164           196          228           260           292       324       356      388
    0x-ID|-uint32-|-bytes3[0]-|-bytes3[1]-|-bytes(loc)-|-bool-|-uint[](loc)-|-bytes(len)-|-bytes(data)-|-uint[](len)-|-uint[0]-|-uint[1]-|-uint[2] 
         ^start of the arguments block......................................^(192th Byte location).....^(256th Byte location).....
    */
    function selectorJSL(
        uint32 par1,
        bytes3[2] memory,
        bytes memory,
        bool,
        uint[] memory
    ) external pure returns (bool r) {
        r = par1 > 32 ? true : false;
    }
}

// Comments in Solidity :

// This is a single-line comment.

/// single line NatSpec comment

/**
 * This is a
 * multi-line comment.
 */
