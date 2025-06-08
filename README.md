# 🛒 Subasta Inteligente en Solidity

Este repositorio contiene un contrato inteligente de subasta escrito en Solidity. El contrato permite realizar subastas con las siguientes características:
- Tiempo de duracion en minutos (2880 minutos desde su publicacion).
- Oferta mínima inicial (precio base).
- Múltiples ofertas por usuario.
- Reembolsos parciales del exceso de ofertas anteriores.
- Comisión del 2% aplicada a cada transacción.
- Extensión automática de tiempo si se ofertan los últimos 10 minutos.
- Eventos para seguimiento del estado de la subasta.

## 📁 Estructura del proyecto

- `contracts/Auction.sol`: Contrato principal de subasta.
- `docs/ARCHITECTURE.md`: Documentación técnica detallada del contrato.

## 🚀 Despliegue

El contrato está desplegado en la dirección:

**[0x8c27e3bbcd2d1d63103086ae7b9875dec6390fbf](https://etherscan.io/address/0x8c27e3bbcd2d1d63103086ae7b9875dec6390fbf)**

## 🔐 Licencia

Este proyecto está licenciado bajo MIT.
