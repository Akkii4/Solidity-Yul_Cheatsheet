// SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.4.16 <0.9.0;

contract ExtContract {
    uint256 public transferVolume;

    //   "e39ff19f": "transferFunds(address)"
    function transferFunds(address _receiver) external payable {
        payable(_receiver).transfer(msg.value);
        transferVolume += msg.value;
    }

    //   "c8a4ac9c": "mul(uint256,uint256)"
    function mul(uint256 x, uint256 y) external pure returns (uint256) {
        return x * y;
    }

    //   "c2cfaca2": "noParam()"
    function noParam() external pure returns (bool) {
        return true;
    }

    //   "8c5f0b6d": "dynamicParam(uint256,uint256[])"
    function dynamicParam(
        uint256 _size,
        uint256[] memory _arr
    ) external pure returns (uint256[] memory _temp) {
        require(_arr.length == _size, "Array length mismatch");
        _temp = new uint[](_size);
        for (uint i; i < _arr.length; i++) {
            _temp[i] = 2 * _arr[i];
        }
    }
}
