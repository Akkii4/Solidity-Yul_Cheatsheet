// needs Yul compiler to run

// contract are object in Yul, while the code is actual source code logic inside it 
// Pure yul cannot be verified on Etherscan
object "Simple"{

    // basic construcutor
    code {
        // Deploy the contract and save the runtime bytecode in memory and return it
        // datacopy 
        datacopy(0, dataoffset("any_randomName"), datasize("any_randomName")) 
        return(0, datasize("any_randomName"))
    }

    object "any_randomName" {
        code {
            mstore(0x00, 2)
            return (0x00, 0x20)
        }
    }
}