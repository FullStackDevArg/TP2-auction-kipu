# 🛒 Smart Auction in Solidity

This repository contains a smart auction contract written in Solidity. The contract allows auctions with the following characteristics:
- Duration in minutes (2880 minutes from publication).
- Minimum initial bid (base price).
- Multiple bids per user.
- Partial refunds for excess bids from previous bids.
- 2% commission applied to each transaction.
- Automatic time extension if bids are placed in the last 10 minutes.
- Events to track the auction status.

## 📁 Project Structure

- `contracts/Auction.sol`: Main auction contract.
- `docs/ARCHITECTURE.md`: Detailed technical documentation for the contract.

## 🚀 Deployment

The contract is deployed to the address:

**[0x8c27e3bbcd2d1d63103086ae7b9875dec6390fbf](https://etherscan.io/address/0x8c27e3bbcd2d1d63103086ae7b9875dec6390fbf)**

## 🔐 License

This project is licensed under the MIT License.
