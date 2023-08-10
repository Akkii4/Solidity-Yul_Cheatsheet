// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * Yul is a low-level language that can be compiled to bytecode
 *  and can be used stand-alone(use --strict-assembly) or as inline assembly inside Solidity.
 * Used for granular optimisation.
 */

contract InlineYul {
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
            // as it is not possible to access a Yul function or variable defined in a different inline assembly block
            // thus need to define the calling functions or variable within the same block
            function f(x, y) -> a, b {
                /* ... */
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
}
