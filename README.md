# FairAid Project Contracts Repository

* This repository contains Solidity smart contracts for used in FairAid project.
* There are three files. FairAidDID.sol is the main smart contract implementation of DID functionality. The other two sol files contain IERC5192 and ERC5192 which are the Ethereum standard for Soulbound tokens. You need to have IERC5192.sol and ERC5192.sol files in order to compile the main FairAidDID.sol contract. 
* Artifacts are also included in this repository as a separate folder. You can use FairAidDID.json file for ABI reference. 
* You can access ABI (FairAidDID.json) by this IPFS link as well: https://gateway.pinata.cloud/ipfs/QmT7D23M1o1GDDgVjEgy4Ym1YuHePnwmN9t9552U8HD8MJ
* Here is an example of how you can create a FairAidDID contract instance in React using 'ethers' library:

```
const artifactUrl = "https://gateway.pinata.cloud/ipfs/QmT7D23M1o1GDDgVjEgy4Ym1YuHePnwmN9t9552U8HD8MJ";
const artifact = await fetch(artifactUrl).then(response => {
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
});
const { abi } = artifact;
const contract = new ethers.Contract(contractAddress, abi, signer);
```