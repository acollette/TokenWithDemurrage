// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BrusselsCoin is ERC20, ERC20Burnable, Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 constant RAY = 10 ** 27;

    // Decrease factor per second.
    uint256 public decreaseFactor = RAY * 99999998 / 100000000;
    // Seconds after which the remaining balance will be 0.
    uint256 tau = 730 days;

    mapping(address => uint256) public lastActivity;

    event Minted(address indexed to, uint256 amount, string description);

    constructor(address[] memory admins) Ownable(msg.sender) ERC20("Brussels Coin", "BXL") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(MINTER_ROLE, admins[i]);
        }
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(
        address to,
        uint256 amount,
        string memory description
    ) public {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "Must have minter role to mint"
        );
        lastActivity[to] = block.timestamp;
        _mint(to, amount);
        emit Minted(to, amount, description);
    }

    function getDemurrage(address account) public view returns (uint256 demurrage) {
        uint256 accountBalance = balanceOf(account);
        demurrage = accountBalance - linearDecrease(accountBalance, block.timestamp - lastActivity[account]);
    }

    function tax(address account) external onlyOwner {
        uint256 demurrage = getDemurrage(account);
        _transfer(account, owner(), demurrage);
    }

    function balanceAfterDemurrage(address account) public view returns (uint256 balance) {
        uint256 accountBalance = balanceOf(account);
        balance = linearDecrease(accountBalance, block.timestamp - lastActivity[account]); 
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        address from = _msgSender();
        uint256 demurrage = getDemurrage(from);
        lastActivity[from] = block.timestamp;
        _transfer(from, owner(), demurrage);
        require(balanceOf(from) >= value, "Not enough balance, check for demurrage");
        _transfer(from, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        uint256 demurrage = getDemurrage(from);
        lastActivity[from] = block.timestamp;
        _transfer(from, owner(), demurrage);
        require(balanceOf(spender) >= value, "Not enough balance, check for demurrage");
        _transfer(from, to, value);
        return true;
    }

    function setDecreaseFactor(uint256 _decreaseFactor) external onlyOwner {
        decreaseFactor = _decreaseFactor; 
    }

    function setTau(uint256 tau_) external onlyOwner {
        require(tau_ >= 30 days);
        tau = tau_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      MATH
    //////////////////////////////////////////////////////////////////////////*/

    // Functions were ported from:
    // https://github.com/makerdao/dss/blob/master/src/abaci.sol

    /// @dev Returns the amount remaining after a demurrage.
    /// @param top The amount decaying.
    /// @param dur The seconds of decay.
    function linearDecrease(uint256 top, uint256 dur) public view returns (uint256) {
        if (dur >= tau) return 0;
        return rmul(top, mul(tau - dur, RAY) / tau);
    }

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

     function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / RAY;
    }
    
    function rpow(uint256 x, uint256 n, uint256 b) internal pure returns (uint256 z) {
        assembly {
            switch n case 0 { z := b }
            default {
                switch x case 0 { z := 0 }
                default {
                    switch mod(n, 2) case 0 { z := b } default { z := x }
                    let half := div(b, 2)  // for rounding.
                    for { n := div(n, 2) } n { n := div(n,2) } {
                        let xx := mul(x, x)
                        if shr(128, x) { revert(0,0) }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) { revert(0,0) }
                        x := div(xxRound, b)
                        if mod(n,2) {
                            let zx := mul(z, x)
                            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) { revert(0,0) }
                            z := div(zxRound, b)
                        }
                    }
                }
            }
        }
    }
}
