// needs Yul compiler to run

// contract are object in Yul, while the code is actual source code logic inside it 
// Pure yul cannot be verified on Etherscan
object "Simple"{

    // basic construcutor
    code {
        //... any logic to put into constructor

        // Deploy the contract and save the runtime bytecode in memory and return it

        // datacopy is similar to copdecopy in evm
        // copies size of runtime code from code position of "any_randomName" to mem at position 0
        datacopy(0, dataoffset("any_randomName"), datasize("any_randomName")) 
        return(0, datasize("any_randomName"))
    }

    object "any_randomName" {
        code {
            switch extractFuncSelector()

            case 0xe1cb0e52 /* getVal() */{
                mstore(0x00, 2) // store val 2 at slot 0
                return (0x00, 0x20) // return 32 bytes from slot 0
            }

            default { revert(0,0)}
            
            function extractFuncSelector() -> s{
                // shift right calldata by 224(28 bytes) to fetch first 4 bytes as function selector
                // similar to  s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
                s := shr(224, calldataload(0))
            }
            // verbatim allows to create bytecode for opcodes, also bypassing the optimiszer
            // verbatim_<n>i_<m>o("<data>", ...)
            // n & m (0-99) specifies the number of input and output stack respectively
            // data represents series of opcodes
            let x := calldataload(0)
            // here 1i means 1 byte is taken from the stack and 1o means 1 byte pushed onto stack as output
            let double := verbatim_1i_1o(hex"600202", x)
        }
    }
}