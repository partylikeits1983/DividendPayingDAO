#### Dividend Paying Governance Token

A smart contract that splits accrued fees in accordance with the % of the total supply the ERC-20 token holders own.

----
## Basic schema of what the smart contracts do.

<p align="center">
   <img src="/doc/schema1.jpg">
</p>

----

Smart Contract Functionality:

main writable functions:

- Transfer (transfer from user 1 to user 2)

- userRelease (release payment to user 2 minus fee)

- release (release dividend to token holder)

- createProposal (token holder with >= 10% of total supply can create proposal)

- vote (vote for fee proposal, quorum is 10% of total supply)

- contractDonation (if outside user wants to make donation to token holders) 

main readable functions:

- balanceOf (shows how many ERC20 tokens address has)

- voteEnd (shows unix time stamp when vote will end)

- getfee (shows current fee, cannot be higher than 10%)

- _totalUserReleased (shows how much Eth has been sent to users through smart contract)

- dividend (shows accrued fees in smart contract)




planned features:

- clean up DAOtoken.sol by using inheritance


