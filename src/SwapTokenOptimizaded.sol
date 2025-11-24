/ SPDX-License-Identifier: MIT 
pragma solidity 0.8.30;

import "./interfaces/IV2Router02.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {
    using SafeERC20 for IERC20;

    address public V2Router02;
    address public tesorery;
    uint256 public constant SURPLUS_SHARE_BPS = 5000; // 50% del excedente para el protocolo

    event SwapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 actualOut, uint256 userAmount, uint256 protocolProfit);

    constructor(address V2Router02_, address tesorery_){
        V2Router02 = V2Router02_;
        tesorery = tesorery_;
    }

    function swapTokensOptimizaded(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_) external {
        // 1. Transferir tokens del usuario al contrato
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);
        
        // 2. Aprobar al Router para que gaste nuestros tokens
        IERC20(path_[0]).approve(V2Router02, amountIn_);
        
        // 3. Ejecutar el Swap. Los tokens llegan a ESTE contrato (address(this))
        uint[] memory amountOuts = IV2Router02(V2Router02).swapExactTokensForTokens(
            amountIn_, 
            amountOutMin_, 
            path_, 
            address(this), 
            deadline_
        );
        
        
        // 4. Extraer la cantidad final recibida (el último número del array)
        uint256 actualOut = amountOuts[amountOuts.length - 1]; // <--- IMPORTANTE: Definir cuánto llegó realmente
        
        // 5. Extraer la dirección del token de salida (la última dirección del path)
        address tokenOut = path_[path_.length - 1]; // <--- IMPORTANTE: Definir cuál es el token de salida

        uint256 protocolProfit;
        uint256 userAmount;

        // 6. Lógica de reparto de excedentes
        if (actualOut > amountOutMin_) {
            // Hay excedente (Surplus)
            uint256 surplus = actualOut - amountOutMin_;
            
            protocolProfit = (surplus * SURPLUS_SHARE_BPS) / 10000;
            userAmount = actualOut - protocolProfit;

            // Transferir ganancia a la tesorería
            IERC20(tokenOut).safeTransfer(tesorery, protocolProfit);
            // Transferir el resto al usuario 
            IERC20(tokenOut).safeTransfer(msg.sender, userAmount);
        } else {
            // NO hay excedente (Solo se cumplió el mínimo o exacto)
            protocolProfit = 0;
            userAmount = actualOut;
            
            // Transferir todo al usuario
            IERC20(tokenOut).safeTransfer(msg.sender, actualOut);
        }
        
        emit SwapTokens(path_[0], tokenOut, amountIn_, actualOut, userAmount, protocolProfit);
    } 
}
