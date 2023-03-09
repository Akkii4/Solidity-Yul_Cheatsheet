# Solidity CHEATSHEET

```
A complete reference guide to Solidity Programming.
```

## Check it Out

Install dependencies

```
npm i
```

Compile

```
npm run compile && npm run lint
```

## Criticism Welcome

But only +ve ;-) , you are open to contribute via creating PR or point out any issues.

# FAQ

## Blockchain Basics

### 1. Blockchain in one sentence ?

```
A blockchain is a globally shared, transactional database.
```

### 2. What is Transaction in Blockchain ?

> A message that is sent from one account to another account

```
To change something in the blockchain, a transaction needs to created which is always cryptographically signed
by the sender (creator) and has to be accepted by all others.
```

### 3. What does Block means in Blockchain ?

```
Blocks are included to solve Blockchain's Double Spend Problem , thus the transactions are bundled into a “block”
and then they will be executed and distributed among all participating nodes. If two transactions contradict each other,
the one that ends up being second will be rejected and not become part of the block.
```

## EVM : The Ethereum Virtual Machine

> It is an isolated runtime environment for smart contracts in Ethereum which means that code running inside the EVM
> has no access to network, filesystem or other processes, even Smart contracts have limited access to other smart contracts.

### 1. Accounts in Ethereum ?

```
1. External accounts : controlled by public-private key pairs (i.e. humans)
   - determined from the public key
2. Contract accounts : controlled by the code stored together with the account.
   - derived from the creator address and the number of transactions sent from that address, the so-called “nonce”
```

### 2. What is a Smart contract ?

```
Is the sense of Solidity is a collection of code (its functions) and data (its state)
that resides at a specific address on the Ethereum blockchain.
```

### 3. Gas in Ethereum ?

```
Upon creation, each transaction is charged with a certain amount of gas for using computation of EVM and
also incitivize EVM executors(stakers/miners) thus has to be paid for by the originator of the transaction.
```
