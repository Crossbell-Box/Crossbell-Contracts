# How to contribute
Glad to see you are interested to make contributions. To make your work more efficient and our community more healthy, please always start with an PR or issue to clearly describe what you want to make changes first.

## Testing
We use foundry test framework, with hardhat as a supplement. Be sure to write unit tests for new code you created. 

## Submit Changes

Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

```
$ git commit -m "feat: A brief summary of the commit
> 
> A paragraph describing what changed and its impact."
```

## Coding conventions

Start reading our code and you'll get the hang of it. We optimize for readability:

+ We indent using four spaces
+ Use ``filename: a sentence to describe the reason (without capitalization, without a period at the end)`` format in the error message for ``require`` in upgradable contracts
+ Comment style
  - It is recommended that Solidity contracts are fully annotated using NatSpec for all public interfaces (everything in the ABI).
  - It is recommended all the condition check logic are described in ``Requirements``
  - It is recommended to describe the Event emitted in a function.

Thanks.