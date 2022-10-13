// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.4.16 <0.9.0;

contract Mul {
    function multiply(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a * b;
    }
}
