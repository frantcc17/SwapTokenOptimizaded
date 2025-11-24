# SwapTokenOptimizaded
Este contrato es un intermediario de ejecución (Proxy) para intercambios descentralizados (basado en Uniswap V2). Su función principal no es solo intercambiar tokens, sino actuar como un mecanismo de arbitraje interno sobre el "Slippage" (deslizamiento) del usuario.

A diferencia de una interfaz normal donde si el usuario recibe un mejor precio del esperado se queda con todo el beneficio, este contrato detecta si hubo una ejecución favorable (Positive Slippage) y captura el 50% de ese excedente para la tesorería del protocolo, devolviendo el resto al usuario. Convierte la ineficiencia o precaución del usuario al configurar su amountOutMin en una fuente de ingresos para el protocolo.
