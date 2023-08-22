// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * Yul is a low-level language that can be compiled to bytecode
 *  and can be used stand-alone(use --strict-assembly) or as inline assembly inside Solidity.
 * Used for granular optimisation.
 */

contract InlineYul {
    uint256 _random = 256; // slot 0
    address _owner = address(1); // all these 3 elements are in slot 1
    uint16 _numX = 44;
    uint8 _ran2 = 22;
    uint72 _ran3 = 5;

    event UnIndexedEvent(uint256 a, uint256 b, bool c);
    event IndexedEvent1(uint256 indexed a, uint256 b, bool c);
    event IndexedEvent2(uint256 indexed a, uint256 indexed b, bool c);
    event IndexedEvent3(uint256 indexed a, uint256 indexed b, bool indexed c);

    /**
     * Basic syntax
     * allowed elements inside assembly's block
     * syntactical elements can separated by whitespace, i.e. no terminating ; or newline required.
     */
    function allowedIdentifiers(uint256 _num) public pure {
        assembly {
            /**
             * Literals :
             *  Integer in decimal or hex less than 2^256 (32, 0x20)
             *  ASCII ("hello") and hex strings (hex"32") of size upto 32 bytes
             */

            // variable declarations (initialised with 0)
            let x  // these variables are stored in a new stack slot(stays until end of block or when being used for last time) and do not directly influence memory or storage
            // assignments
            x := 7

            // builtin functions calls
            let y := add(7, 43)
            mstore(0x40, 2)

            // block scoping
            // can access variable oustide from this scope
            // but variables declared or assigned in here can't be accessed outside this scope
            {
                let check := eq(50, y)
            }

            // if statements (Yul has no concept of bool type thus any value other than 0 is true )
            // following code represent assert in assembly
            let condition := eq(y, 50)
            if iszero(condition) {
                invalid()
            }

            //switch statements are used when multiple alternatives are needed as else / else if are invalid
            switch _num
            case 0 {
                // if n == 0
            }
            case 1 {
                // if n == 1
            }
            default {
                // if neither case is true
            }

            // for loops
            for {
                let i := 0
            } lt(i, 5) {
                i := add(i, 1)
            } {
                y := add(mul(i, 2), 3) // innermost operations are executed first as no order of precedence
            }

            // while loops (if in a for loop initialization and post-iteration parts are empty)
            let j := 5

            for {

            } lt(j, 5) {

            } {
                // while(i < 5)
                y := add(mul(j, 2), 3)
            }

            // function definitions
            function f(a, b) -> c {
                c := add(a, b)
            }
        }
    }

    /**
     * Yul has only 1 data type that of bytes32
     * thus compiler convert any other data type to bytes32 explicitally
     *
     * this function will return :
     * x = 176 (1200 % 256 as a result of overflow)
     * y = 1
     * z = false (as empty string)
     * s = bytes represntation of ASCII string
     * a = 20 bytes represntation of 1
     */
    function yulType()
        public
        pure
        returns (uint8 x, uint256 y, bool z, bytes32 s, address a)
    {
        assembly {
            x := 1200
            y := true
            z := ""
            s := "hello"
            a := 1
        }
    }

    function functionCalls() external pure {
        assembly {
            let z := 3
            // as it is not possible to access a Yul function or variable defined in a different inline assembly block
            // thus need to define the calling functions or variable within the same block
            function f(x, y) -> a, b {
                a := add(x, 3)
                // ERROR: b:= mul(a,z) as cannot access local variables defined outside of this function

                // just exits the current function while returning whatever values are currently assigned to the return variable(s).
                // unlike 'return' that quits the full execution context (internal message call) and not just the current yul function.
                leave
            }

            // if a built-in function returns a single value
            // built in function can be trasnslated into opcodes and is being read right ot left
            // e.g. PUSH1 3 PUSH1 0x80 MLOAD ADD PUSH1 0x80 MSTORE
            mstore(0x80, add(mload(0x80), 3))

            // if a user-defined function returns multiple values, they have to be assigned to local variables.
            // return values from functions, are expected on the stack from left to right,
            // i.e. y is on top of the stack and x is below it.
            let x, y := f(1, mload(0))
        }
    }

    function assemblyStorage(
        uint256 storageSlot
    ) external returns (uint256 x, uint256 varSlot, uint256 varVal) {
        assembly {
            x := sload(storageSlot) // reading a storage variable value stored at particular storage slot
            varSlot := _ran2.slot // returns a slot of a variable named 'rand'
            varVal := sload(varSlot)
            sstore(storageSlot, 1) // writing value to a storage slot
        }
    }

    function packedStorage()
        external
        pure
        returns (uint256 _slot, uint256 offset)
    {
        assembly {
            _slot := _ran2.slot // returns slot of variable 'ran2' in global storage
            offset := _ran2.offset //returns the starting bytes position of variable 'ran2' in it's slot
        }
    }

    // each arguments are padded to 32 bytes
    function abiEncoding()
        external
        pure
        returns (uint256 argsLength, bytes32 arg1, bytes32 arg2)
    {
        abi.encode(uint256(1), uint128(2));

        assembly {
            argsLength := mload(0x80) // returns 0x0000...000040 (the bytes length of the arguments: 64)
            arg1 := mload(0xa0) // returns 0x0000...000001 (32 bytes)
            arg2 := mload(0xc0) // returns 0x0000...000002 (padded to 32 bytes)
        }
    }

    // here no padding happens in the arguments
    function abiEncodePack()
        external
        pure
        returns (uint256 argsLength, bytes32 arg1, bytes16 arg2)
    {
        abi.encodePacked(uint256(1), uint128(2));

        assembly {
            argsLength := mload(0x80) // returns 0x0000...000040 (the bytes length of the arguments: 48 (32 + 16))
            arg1 := mload(0xa0) // returns 0x0000...000001 (32 bytes)
            arg2 := mload(0xc0) // returns 0x00...0002 (16 bytes)
        }
    }

    // if the return data size is bigger than expected, compiler will decode the first X bytes it expects
    // whereas returning size smaller than expected will result in failure to decode
    function yulReturn() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x80, 1)
            mstore(0xa0, 2)
            mstore(0xc0, 3)
            // return the data from slot 0xa0 and 0x40 represents byte size to returns
            return(0xa0, 0x40) // will return 2 & 3
            // return(0x80, 0x40) // will return 1 & 2
        }
    }

    function revertIt() external view {
        // equivalent to require(msg.sender != 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); of Solidity
        assembly {
            if iszero(
                sub(caller(), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
            ) {
                revert(0, 0) // similar to return but revert stop the execution of the function
            }
        }
    }

    function hashed() external pure returns (bytes32) {
        assembly {
            let freeMemPtr := mload(0x40)
            // store 1, 2, 3 in memory
            mstore(freeMemPtr, 1)
            mstore(add(freeMemPtr, 0x20), 2)
            mstore(add(freeMemPtr, 0x40), 3)

            // update free memory pointer
            mstore(0x40, add(freeMemPtr, 0x60)) // increase memory pointer by 3 slots (0x60)

            // keccak256(a,b) -> hash data stored at 'a' upto slot 'a+b'
            mstore(0x00, keccak256(freeMemPtr, 0x60)) // storting the hash data at its dedicated location in the memory(0x00 to 0x3f)
            return(0x00, 0x20)
        }
    }

    /**
     * t1 generally is event Signature while t2,t3... are indexed parameters
     * while in case of anonymous events no event signature is used and instead 4 indexed parameters can be used
     * log1(p, s, t1) - emits an event with one topic(indexed) t1 and bytes representation of un-indexed parameters of size s starting from memory slot p
     * similarly log2(p, s, t1, t2),log3(p, s, t1, t2, t3), log4(p, s, t1, t2, t3, t4)
     * log0(p, s) - for emitting anonymous events where only bytes representation of un-indexed parameters are passed
     */
    function emitEvents() external {
        assembly {
            // keccak256("IndexedEvent2(uint256,uint256,bool)")
            let
                eventSignature
            := 0x6c314e1fffffe49db80bbf8fba1926d211a91b20267702af8256a39edf31105b
            // store all non-indexed params starting from slot 0x80
            mstore(0x80, 1) // as bool so 1 for true , 0 for false

            // emit the event IndexedEvent2(45, 63, true)
            log3(0x80, 0x20, eventSignature, 45, 63)
        }
    }

    function externalStaticCall(
        address _contract
    ) external view returns (uint256 mulResult, bool noParamCalled) {
        assembly {
            let freeMemPtr := mload(0x40)
            // store the function selector of mul(uint256, uint256) in memory
            mstore(freeMemPtr, 0xc8a4ac9c)
            // store the first argument of calling function in the next memory slot
            mstore(add(freeMemPtr, 0x20), 5)
            // store the second argument
            mstore(add(freeMemPtr, 0x40), 10)
            // update the free memory pointer
            mstore(0x40, add(freeMemPtr, 0x60))
            // memory will look like:
            //  0x80: 00000000000000000000000000000000000000000000000000000000c8a4ac9c
            //  0xa0: 0000000000000000000000000000000000000000000000000000000000000005
            //  0xc0: 000000000000000000000000000000000000000000000000000000000000000a

            // staticcall : calling external contract function without any state modification
            // calling the function mul() with two parameters
            if iszero(
                staticcall(
                    gas(), // amount of gas to send
                    _contract, // call contract address
                    add(freeMemPtr, 28), // calldata starting pointer in the memory(usually starts from 4 bytes function selector)
                    0x44, // size of calldata to copy starting from the initial offset (0x04(func. selector) + 2 * 0x20(parameters slots))
                    0x00, // byte offset in the memory, where to store the return data , received from external call
                    0x20 // size of return data
                )
            ) {
                revert(0, 0)
            }

            mulResult := mload(0x00)

            freeMemPtr := mload(0x40)
            // store the function selector of noParam()
            mstore(freeMemPtr, 0xc2cfaca2)

            // calling the function mul() with two parameters
            noParamCalled := staticcall(
                gas(),
                _contract,
                add(freeMemPtr, 28),
                0x04, // only needs 4 byte function selector as no parameters
                0x00,
                0x00 // not copying the returned data
            )
        }
    }

    // calling an external contract where dynamic data types are passed along with handling dynamic sized return data
    function staticDynamicCall(
        address _contract
    ) external view returns (uint256[] memory) {
        assembly {
            let freeMemPtr := mload(0x40)
            mstore(freeMemPtr, 0x8c5f0b6d)
            // store the first argument (uint256) in slot 1
            mstore(add(freeMemPtr, 0x20), 3)
            // store pointer indicating start of array in calldata
            // Note : the location is based of the formulated calldata and not memory
            mstore(add(freeMemPtr, 0x40), 0x40)
            // store the array length
            mstore(add(freeMemPtr, 0x60), 3)
            // start storing the second argument(array elements) : [43,21,78]
            mstore(add(freeMemPtr, 0x80), 43)
            mstore(add(freeMemPtr, 0xa0), 21)
            mstore(add(freeMemPtr, 0xc0), 78)
            // update the free memory pointer
            mstore(0x40, add(freeMemPtr, 0xe0))
            // memory will look like:
            //  0x80: 000000000000000000000000000000000000000000000000000000008c5f0b6d
            // calldata begins here                                                     calldata offset
            //  0xa0: 0000000000000000000000000000000000000000000000000000000000000003      0x00
            //  0xc0: 0000000000000000000000000000000000000000000000000000000000000040      0x20
            //  0xe0: 0000000000000000000000000000000000000000000000000000000000000003      0x40
            // 0x100: 0000000000000000000000000000000000000000000000000000000000000043      0x60
            // 0x120: 0000000000000000000000000000000000000000000000000000000000000021      0x80
            // 0x140: 0000000000000000000000000000000000000000000000000000000000000078      0xa0

            if iszero(
                staticcall(
                    gas(),
                    _contract,
                    add(freeMemPtr, 28),
                    0xc4,
                    0x00,
                    0x00 // not storing the return data here as if the size is unclear
                )
            ) {
                revert(0, 0)
            }

            // when the return data size is unclear instead of manually defining inside call above we can
            // store return data like :

            // returndatacopy(t, f, s) copy s bytes from returndata at position f to mem at position t
            returndatacopy(mload(0x40), 0, returndatasize())

            // returndatasize : size of the last returndata
            // return the result from memory
            return(mload(0x40), returndatasize())
        }
    }

    function stateChangingCall(address _contract) external payable {
        assembly {
            let freeMemPtr := mload(0x40)
            // store the function selector of transferFunds(address)
            mstore(freeMemPtr, 0xe39ff19f)
            // store the first argument of calling function in the next memory slot, address in this case
            mstore(
                add(freeMemPtr, 0x20),
                0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
            )

            // call : calling external contract function with state modification and can also send ether along
            let success := call(
                gas(),
                _contract,
                callvalue(), // send ether along function call
                add(freeMemPtr, 28),
                0x24,
                0x00,
                0x00 // don't save as no return data
            )
            // transfering eth to an address via call
            // call(gas(), _receiverAddress, selfbalance(), 0, 0, 0, 0) selfbalance is equivalent to current contract balance
            if iszero(success) {
                revert(0, 0)
            }
        }
    }

    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            // calldatasize() size of call data in bytes
            // calldatacopy(t, f, s) copy s bytes from calldata at position f to mem at position t
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
