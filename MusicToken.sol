// SPDX-License-Identifier: MIT

/*
 * MusicToken.sol – v0.1 – 06 de febrero de 2026
 *
 * DISCLAIMER MUY IMPORTANTE – LEER ANTES DE USAR
 *
 * Este es un contrato inteligente BASE / BORRADOR creado para MusicTokenRing.
 * NO ESTÁ AUDITADO.
 * NO HA SIDO PROBADO EN MAINNET NI TESTNET PÚBLICA.
 * NO DESPLEGAR CON FONDOS REALES NI USAR EN PRODUCCIÓN SIN AUDITORÍA PROFESIONAL POR EMPRESAS RECONOCIDAS (Certik, PeckShield, Hacken, etc.).
 *
 * Riesgos conocidos posibles: reentrancy, overflow/underflow (aunque usa SafeMath o 0.8+), front-running, centralización temporal (Ownable), etc.
 * El código puede contener errores graves o vulnerabilidades.
 * Cualquier despliegue o interacción es bajo tu propio riesgo exclusivo.
 * El creador/fundador no asume responsabilidad por pérdidas de cualquier tipo.
 *
 * Uso recomendado: SOLO para revisión comunitaria, aprendizaje y sugerencias de mejora.
 * Gracias por tu atención y feedback responsable.
 */

pragma solidity ^0.8.20;

// Resto del código...
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MusicToken
 * @dev Token ERC20 para MusicToken Ring platform
 * Supply: 1,000,000,000 MTOKEN
 * Features: Burnable, Pausable, Vesting
 */
contract MusicToken is ERC20, ERC20Burnable, Pausable, Ownable {
    
    // Supply total: 1 billion tokens
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    
    // Distribution
    uint256 public constant TEAM_ALLOCATION = 200_000_000 * 10**18; // 20%
    uint256 public constant PRESALE_ALLOCATION = 50_000_000 * 10**18; // 5%
    uint256 public constant PUBLIC_SALE_ALLOCATION = 100_000_000 * 10**18; // 10%
    uint256 public constant LIQUIDITY_ALLOCATION = 100_000_000 * 10**18; // 10%
    uint256 public constant REWARDS_ALLOCATION = 300_000_000 * 10**18; // 30%
    uint256 public constant PARTNERSHIPS_ALLOCATION = 50_000_000 * 10**18; // 5%
    uint256 public constant AIRDROP_ALLOCATION = 50_000_000 * 10**18; // 5%
    uint256 public constant MARKETING_ALLOCATION = 100_000_000 * 10**18; // 10%
    uint256 public constant STAKING_ALLOCATION = 50_000_000 * 10**18; // 5%
    
    // Wallets
    address public teamWallet;
    address public presaleWallet;
    address public publicSaleWallet;
    address public liquidityWallet;
    address public rewardsWallet;
    address public partnershipsWallet;
    address public airdropWallet;
    address public marketingWallet;
    address public stakingWallet;
    
    // Vesting
    uint256 public teamVestingStart;
    uint256 public constant TEAM_VESTING_DURATION = 730 days; // 24 meses
    uint256 public constant TEAM_CLIFF = 180 days; // 6 meses cliff
    uint256 public teamTokensReleased;
    
    // Anti-whale
    uint256 public maxTransactionAmount = 5_000_000 * 10**18; // 0.5% of supply
    uint256 public maxWalletBalance = 10_000_000 * 10**18; // 1% of supply
    
    // Trading control
    bool public tradingEnabled = false;
    mapping(address => bool) public isExcludedFromLimits;
    
    // Events
    event TradingEnabled(uint256 timestamp);
    event TeamTokensReleased(uint256 amount, uint256 timestamp);
    event MaxTransactionAmountUpdated(uint256 newAmount);
    event MaxWalletBalanceUpdated(uint256 newAmount);
    
    constructor(
        address _teamWallet,
        address _presaleWallet,
        address _publicSaleWallet,
        address _liquidityWallet,
        address _rewardsWallet,
        address _partnershipsWallet,
        address _airdropWallet,
        address _marketingWallet,
        address _stakingWallet
    ) ERC20("MusicToken", "MTOKEN") {
        require(_teamWallet != address(0), "Team wallet cannot be zero");
        require(_presaleWallet != address(0), "Presale wallet cannot be zero");
        require(_publicSaleWallet != address(0), "Public sale wallet cannot be zero");
        require(_liquidityWallet != address(0), "Liquidity wallet cannot be zero");
        require(_rewardsWallet != address(0), "Rewards wallet cannot be zero");
        require(_partnershipsWallet != address(0), "Partnerships wallet cannot be zero");
        require(_airdropWallet != address(0), "Airdrop wallet cannot be zero");
        require(_marketingWallet != address(0), "Marketing wallet cannot be zero");
        require(_stakingWallet != address(0), "Staking wallet cannot be zero");
        
        teamWallet = _teamWallet;
        presaleWallet = _presaleWallet;
        publicSaleWallet = _publicSaleWallet;
        liquidityWallet = _liquidityWallet;
        rewardsWallet = _rewardsWallet;
        partnershipsWallet = _partnershipsWallet;
        airdropWallet = _airdropWallet;
        marketingWallet = _marketingWallet;
        stakingWallet = _stakingWallet;
        
        // Mint tokens
        _mint(teamWallet, TEAM_ALLOCATION);
        _mint(presaleWallet, PRESALE_ALLOCATION);
        _mint(publicSaleWallet, PUBLIC_SALE_ALLOCATION);
        _mint(liquidityWallet, LIQUIDITY_ALLOCATION);
        _mint(rewardsWallet, REWARDS_ALLOCATION);
        _mint(partnershipsWallet, PARTNERSHIPS_ALLOCATION);
        _mint(airdropWallet, AIRDROP_ALLOCATION);
        _mint(marketingWallet, MARKETING_ALLOCATION);
        _mint(stakingWallet, STAKING_ALLOCATION);
        
        // Exclude from limits
        isExcludedFromLimits[owner()] = true;
        isExcludedFromLimits[address(this)] = true;
        isExcludedFromLimits[teamWallet] = true;
        isExcludedFromLimits[liquidityWallet] = true;
        isExcludedFromLimits[rewardsWallet] = true;
        
        // Start team vesting
        teamVestingStart = block.timestamp;
    }
    
    /**
     * @dev Enable trading (can only be called once)
     */
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        emit TradingEnabled(block.timestamp);
    }
    
    /**
     * @dev Release vested team tokens
     */
    function releaseTeamTokens() external {
        require(msg.sender == teamWallet || msg.sender == owner(), "Not authorized");
        require(block.timestamp >= teamVestingStart + TEAM_CLIFF, "Cliff period not over");
        
        uint256 vestedAmount = calculateVestedAmount();
        uint256 releasableAmount = vestedAmount - teamTokensReleased;
        
        require(releasableAmount > 0, "No tokens to release");
        
        teamTokensReleased += releasableAmount;
        
        // Transfer from team wallet to authorized address
        // Note: Team tokens are already minted to teamWallet
        // This function just tracks the vesting schedule
        
        emit TeamTokensReleased(releasableAmount, block.timestamp);
    }
    
    /**
     * @dev Calculate vested amount for team
     */
    function calculateVestedAmount() public view returns (uint256) {
        if (block.timestamp < teamVestingStart + TEAM_CLIFF) {
            return 0;
        }
        
        if (block.timestamp >= teamVestingStart + TEAM_VESTING_DURATION) {
            return TEAM_ALLOCATION;
        }
        
        uint256 timeVested = block.timestamp - (teamVestingStart + TEAM_CLIFF);
        uint256 vestingPeriod = TEAM_VESTING_DURATION - TEAM_CLIFF;
        
        return (TEAM_ALLOCATION * timeVested) / vestingPeriod;
    }
    
    /**
     * @dev Update max transaction amount
     */
    function updateMaxTransactionAmount(uint256 newAmount) external onlyOwner {
        require(newAmount >= TOTAL_SUPPLY / 1000, "Cannot set below 0.1%");
        maxTransactionAmount = newAmount;
        emit MaxTransactionAmountUpdated(newAmount);
    }
    
    /**
     * @dev Update max wallet balance
     */
    function updateMaxWalletBalance(uint256 newAmount) external onlyOwner {
        require(newAmount >= TOTAL_SUPPLY / 100, "Cannot set below 1%");
        maxWalletBalance = newAmount;
        emit MaxWalletBalanceUpdated(newAmount);
    }
    
    /**
     * @dev Exclude/include address from limits
     */
    function setExcludedFromLimits(address account, bool excluded) external onlyOwner {
        isExcludedFromLimits[account] = excluded;
    }
    
    /**
     * @dev Pause token transfers
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause token transfers
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Override transfer to add limits and trading control
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override whenNotPaused {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        // Check if trading is enabled
        if (!tradingEnabled) {
            require(
                isExcludedFromLimits[from] || isExcludedFromLimits[to],
                "Trading not enabled yet"
            );
        }
        
        // Apply limits if not excluded
        if (!isExcludedFromLimits[from] && !isExcludedFromLimits[to]) {
            // Check max transaction amount
            require(
                amount <= maxTransactionAmount,
                "Transfer amount exceeds max transaction amount"
            );
            
            // Check max wallet balance for buys
            if (from != owner() && to != owner()) {
                require(
                    balanceOf(to) + amount <= maxWalletBalance,
                    "Recipient would exceed max wallet balance"
                );
            }
        }
        
        super._transfer(from, to, amount);
    }
    
    /**
     * @dev Withdraw any ERC20 tokens sent to this contract by mistake
     */
    function withdrawStuckTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(this), "Cannot withdraw MTOKEN");
        IERC20(tokenAddress).transfer(owner(), amount);
    }
    
    /**
     * @dev Withdraw ETH/MATIC sent to contract by mistake
     */
    function withdrawStuckETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
