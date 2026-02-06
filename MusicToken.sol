// SPDX-License-Identifier: MIT

/*
 * MusicToken.sol – v0.1 – 06 de febrero de 2026
 *
 * ADVERTENCIA MUY IMPORTANTE – LEER OBLIGATORIAMENTE
 *
 * Este archivo contiene un contrato inteligente BASE / BORRADOR para MusicTokenRing.
 * NO HA SIDO AUDITADO NI PROBADO EN ENTORNO REAL.
 * NO DESPLEGAR EN MAINNET NI USAR CON FONDOS REALES SIN AUDITORÍA PROFESIONAL (Certik, PeckShield, Hacken u otra firma reconocida).
 *
 * Posibles riesgos: vulnerabilidades de seguridad (reentrancy, overflow, front-running, centralización temporal, etc.).
 * El código puede contener errores graves o ser insuficiente para producción.
 * Cualquier despliegue, interacción o uso es bajo tu responsabilidad exclusiva.
 * El creador/fundador declina toda responsabilidad por pérdidas, daños o consecuencias derivadas.
 *
 * Uso recomendado: SOLO revisión comunitaria, aprendizaje y sugerencias de mejora.
 * Gracias por tu atención y feedback responsable.
 */

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MusicToken is ERC20, Ownable {
    // Constructor: Inicializa el token con nombre "MusicTokenRing" y símbolo "MTR"
    // Todo el supply inicial (1,000,000,000) se mintea al owner (founder)
    // Esto es centralizado temporalmente hasta que se migre a gobernanza comunitaria o multisig
    constructor() ERC20("MusicTokenRing", "MTR") Ownable(msg.sender) {
        _mint(msg.sender, 1000000000 * 10 ** decimals()); // Supply total 1B
    }

    // Función burn: Permite a cualquier holder quemar sus propios tokens
    // Útil para mecanismos deflacionarios o recompensas futuras
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Función transfer override: Aquí se puede implementar la lógica de tax (fees) en el futuro
    // Actualmente realiza transfer normal de ERC20 (sin tax activa)
    // Pendiente: agregar tax para marketing/liquidity/burn según tokenomics
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Aquí iría lógica de tax si se implementa
        return super.transfer(recipient, amount);
    }
}
