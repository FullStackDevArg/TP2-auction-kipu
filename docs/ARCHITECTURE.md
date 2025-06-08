# 📐 Arquitectura del Contrato de Subasta

## Estructura General

El contrato maneja una subasta pública con lógica de puja, reembolso de excedentes, comisión y extensiones de tiempo automáticas.

### Variables Clave

- `owner`: Creador de la subasta.
- `endTime`: Tiempo de finalización.
- `highestBid`, `highestBidder`: Seguimiento de la oferta líder.
- `commission`: Comisión fija del 2% aplicada a todas las transacciones.
- `deposited`: Mapeo de fondos depositados por cada usuario.
- `historicalBids`: Historial de todas las ofertas por usuario.

### Funciones Clave

- `ofertar()`: Permite hacer una oferta válida (mínimo 5% superior a la anterior), cobra comisión y extiende el tiempo si está dentro de los últimos 10 minutos.
- `finalizarSubasta()`: Devuelve fondos a todos excepto al ganador. Cobra comisión en los reembolsos.
- `reembolsarExceso()`: Permite retirar el exceso de ofertas previas (menos la última), con comisión.
- `verOfertas()`: Permite consultar el historial total de ofertas.
- `ganador()`: Devuelve el ganador solo si se finalizó la subasta.

### Seguridad

- Validaciones de tiempo con `require`.
- `finalized` para evitar doble ejecución.
- Prevención de reentradas usando lógica de efectos-interacciones.
- Uso de `transfer` para pagos.

### Eventos

- `NuevaOferta`: Emite cada vez que se hace una oferta válida.
- `SubastaFinalizada`: Emite al cerrar la subasta.
- `TiempoExtendido`: Indica cuando el tiempo fue extendido automáticamente.

