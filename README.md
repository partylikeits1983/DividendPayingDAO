## Dividend Paying Governance Token

A smart contract that splits accrued fees in accordance with the % of the total supply the ERC-20 token holders own.


#### Basic schema of the smart contract.

<p align="center">
   <img src="/doc/schema1.jpg">
</p>

----

## Rinkeby address

You can interact with the contract on the Rinkeby testnet. Text me on telegram (contact info in bio) and I will send you some ERC20 tokens from this smart contract on Rinkeby. 


https://rinkeby.etherscan.io/address/0x562A3e51F33348fa619D0f7EA815958Cd0563b6F#readContract


## Smart Contract Functionality:


This smart contract functions as a payment backend for a decentralized taxi service. 
Yandex Taxi and Uber both charge obscene fees (25% not including taxes) to drivers. 

This smart contract decentralizes the payment backend for a Taxi app, while still being able to generate revenue in order to support the development of the project. 

Individuals are incentivized to hold the ERC20 tokens of this smart contract as these tokens generate dividends in ETH and function as governance tokens. 



#### Main writable functions:

- Transfer (transfer from user 1 to user 2)

- userRelease (release payment to user 2 minus fee)

- release (release dividend to token holder)

- createProposal (token holder with >= 10% of total supply can create proposal)

- vote (vote for fee proposal, quorum is 10% of total supply)

- contractDonation (if outside user wants to make donation to token holders)


#### main readable functions:

- balanceOf (shows how many ERC20 tokens address has)

- voteEnd (shows unix time stamp when vote will end)

- getfee (shows current fee, cannot be higher than 10%)

- _totalUserReleased (shows how much Eth has been sent to users through smart contract)

- dividend (shows accrued fees in smart contract)





#### planned features:

- clean up DAOtoken.sol by using inheritance (completed)


