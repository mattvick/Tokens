/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/

import "./HumanStandardToken.sol";
import "./MultiSigWallet.sol";

pragma solidity ^0.4.8;

contract LawEnforceableHumanStandardToken is HumanStandardToken {


    /* Public variables of the token */

    bool public isFrozen;
    mapping (address => bool) public frozenHolders;

    /**
     * Constructor function
     *
     * Initializes contract with specified name.
     */
    function LawEnforceableHumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        super.HumanStandardToken(_initialAmount, _tokenName, _decimalUnits, _tokenSymbol);
        isFrozen = false;
    }

    modifier onlyLawEnforcement() {
        if (msg.sender != CompanyMultiSigWallet(owner).lawEnforcementWallet())
            revert();
        _;
    }

    modifier notFrozenContract() {
        require(!isFrozen);
        _;
    }

    modifier notFrozenHolder(address _address) {
        require(!frozenHolders[_address]);
        _;
    }

    function transfer(address _to, uint256 _value) returns (bool success) notFrozenContract notFrozenHolder(msg.sender) notFrozenHolder(_to) {
        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) notFrozenContract notFrozenHolder(_from) notFrozenHolder(_to) {
        super.transferFrom(_from, _to, _value)
    }

    function changeContractFrozenStatus(bool _value) public onlyLawEnforcement {
        isFrozen = _value;
    }

    function changeHolderFrozenStatus(address _holder, bool _value) public onlyLawEnforcement {
        frozenHolders[_holder] = _value;
    }
}
