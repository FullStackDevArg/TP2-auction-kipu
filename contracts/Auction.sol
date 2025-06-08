// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Auction {
    // Dirección del dueño de la subasta (quien la crea)
    address public owner;

    // Tiempo en que termina la subasta (en timestamp)
    uint public endTime;

    // Precio base (mínimo) de la subasta
    uint public basePrice;

    // Estado: indica si la subasta fue finalizada
    bool public finalized;

    // Comisión del 2% aplicada a cada oferta
    uint public commission = 2;

    // Dirección del mejor postor (el que hizo la oferta más alta)
    address public highestBidder;

    // Monto actual más alto de la subasta
    uint public highestBid;

    // Estructura que representa una oferta (quién y cuánto)
    struct Bid {
        address bidder;
        uint amount;
    }

    // Lista de todas las ofertas realizadas
    Bid[] public bids;

    // Registra cuánto ha depositado cada dirección (usuario)
    mapping(address => uint) public deposited;

    // Historial completo de ofertas por usuario
    mapping(address => uint[]) public historicalBids;

    // Evento que se emite cada vez que hay una nueva oferta válida
    event NuevaOferta(address indexed bidder, uint amount);

    // Evento que se emite al finalizar la subasta
    event SubastaFinalizada(address ganador, uint monto);

    // Evento que se emite si se extiende el tiempo de la subasta
    event TiempoExtendido(uint nuevoFin);

    

    // Constructor: se ejecuta al crear la subasta
    // Establece al dueño, el tiempo de duración y el precio base
    constructor(uint _durationMinutes, uint _basePrice) {
        owner = msg.sender;
        endTime = block.timestamp + (_durationMinutes * 1 minutes);
        basePrice = _basePrice;
        highestBid = _basePrice;
    }

    // Modificador que permite ejecutar ciertas funciones solo mientras la subasta está activa
    modifier soloMientrasActiva() {
        require(block.timestamp < endTime, "La subasta ya finalizo");
        _;
    }

    // Modificador que permite ejecutar ciertas funciones solo al dueño de la subasta
    modifier soloOwner() {
        require(msg.sender == owner, "Solo el owner puede ejecutar esto");
        _;
    }

    // Función para hacer una oferta
    function ofertar() external payable soloMientrasActiva {
        // Se descuenta la comisión a la oferta
        uint ofertaNeta = msg.value * (100 - commission) / 100;

        // Se requiere que la nueva oferta supere al menos en un 5% la oferta más alta actual
        require(ofertaNeta >= highestBid * 105 / 100, "Oferta debe superar en 5% a la actual");

        // Si el usuario ya había ofertado antes, no se devuelve nada aún
        // Quedará acumulado y podrá solicitar su exceso luego
        if (deposited[msg.sender] > 0) {
            // No se devuelve nada automáticamente
        }

        // Se actualizan registros
        deposited[msg.sender] += ofertaNeta;
        historicalBids[msg.sender].push(ofertaNeta);

        // Se actualiza el mejor postor y el valor más alto
        highestBidder = msg.sender;
        highestBid = ofertaNeta;

        // Se guarda la oferta en la lista general
        bids.push(Bid(msg.sender, ofertaNeta));

        // Se emite evento informando nueva oferta
        emit NuevaOferta(msg.sender, ofertaNeta);

        // Si quedan menos de 10 minutos para el fin, se extiende el tiempo 10 minutos más
        if (endTime - block.timestamp < 10 minutes) {
            endTime += 10 minutes;
            emit TiempoExtendido(endTime); // Se notifica que se extendió el tiempo
        }
    }

    // Devuelve todas las ofertas realizadas hasta el momento
    function verOfertas() public view returns (Bid[] memory) {
        return bids;
    }

    // Devuelve al ganador y la oferta más alta, solo si ya fue finalizada
    function ganador() public view returns (address, uint) {
        require(finalized, "La subasta no ha finalizado aun");
        return (highestBidder, highestBid);
    }

    // Función que finaliza la subasta (solo el dueño puede llamarla)
    function finalizarSubasta() public soloOwner {
        // Solo puede finalizarse si ya pasó el tiempo y no fue finalizada antes
        require(block.timestamp >= endTime, "La subasta aun esta activa");
        require(!finalized, "Ya fue finalizada");

        finalized = true;

        // Reembolsar a todos los que no ganaron
        for (uint i = 0; i < bids.length; i++) {
            address bidder = bids[i].bidder;
            uint amount = bids[i].amount;

            // Si no es el ganador y tiene fondos, se le devuelve su oferta neta
            if (bidder != highestBidder && deposited[bidder] > 0) {
                uint refund = amount * (100 - commission) / 100;
                deposited[bidder] = 0; // Se evita doble devolución
                payable(bidder).transfer(refund);
            }
        }

        // Se emite evento indicando el ganador y su monto
        emit SubastaFinalizada(highestBidder, highestBid);
    }

    // Función que permite a los usuarios retirar el exceso de ofertas anteriores
    function reembolsarExceso() public {
        uint[] storage ofertas = historicalBids[msg.sender];

        // Solo si hay más de una oferta (hay exceso acumulado)
        require(ofertas.length > 1, "No hay exceso para reembolsar");

        uint totalExceso = 0;

        // Se suman todas menos la última (la válida actualmente)
        for (uint i = 0; i < ofertas.length - 1; i++) {
            totalExceso += ofertas[i];
        }

        require(totalExceso > 0, "Nada para reembolsar");

        // Solo se conserva la última oferta en el historial
        historicalBids[msg.sender] = [ofertas[ofertas.length - 1]];

        // Se aplica comisión también al reembolso del exceso
        uint neto = totalExceso * (100 - commission) / 100;

        // Se descuenta el total reembolsado del depósito acumulado
        deposited[msg.sender] -= totalExceso;

        // Se transfiere el reembolso neto al usuario
        payable(msg.sender).transfer(neto);
    }
}
