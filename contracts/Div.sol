// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.4.16 <0.9.0;

string constant name = "Test_Div";

function divide2(uint256 x, uint256 y) pure returns (uint256) {
    return y / x;
}

contract Div {
    function divide(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a / b;
    }
}
