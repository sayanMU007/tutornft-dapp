# 🎓 TutorNFT - Decentralized Tutoring Platform

<div align="center">

![TutorNFT Logo](https://img.shields.io/badge/TutorNFT-Decentralized%20Education-blue?style=for-the-badge&logo=ethereum)

**Revolutionizing Online Education with Blockchain Technology**

[![Built with React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Solidity](https://img.shields.io/badge/Solidity-363636?style=for-the-badge&logo=solidity&logoColor=white)](https://soliditylang.org/)
[![Core DAO](https://img.shields.io/badge/Core%20DAO-FF6B35?style=for-the-badge&logo=blockchain&logoColor=white)](https://coredao.org/)
[![MetaMask](https://img.shields.io/badge/MetaMask-F6851B?style=for-the-badge&logo=metamask&logoColor=white)](https://metamask.io/)

</div>

---

## 🌟 Overview

TutorNFT is a groundbreaking blockchain-powered online tutoring platform built on Core DAO where tutors mint NFTs representing their profiles and students can book and pay for tutoring sessions using cryptocurrency. Experience the future of decentralized education!

## ✨ Key Features

🎯 **NFT-Based Tutor Profiles** - Tutors create unique NFT profiles with their expertise and rates  
💰 **Decentralized Payments** - Secure cryptocurrency payments through smart contracts  
⭐ **On-Chain Rating System** - Students can rate tutors, building reputation on blockchain  
📅 **Session Management** - Complete booking and completion workflow  
🔗 **Core DAO Integration** - Built specifically for the Core blockchain ecosystem  
🛡️ **Security First** - ReentrancyGuard protection and ownership controls  

## 📸 Screenshots

### 🏠 Homepage - Browse Available Tutors
![Screenshot (48)](https://github.com/user-attachments/assets/69d10a4c-a3ab-4f7b-9802-14cf52694700)

*Clean, modern interface showing available tutors and navigation*

### 📝 Tutor Registration Form
![Screenshot (49)](https://github.com/user-attachments/assets/e9efbebb-8d37-4e8d-8e83-a8b3216fe9da)

*Simple form for tutors to register their profiles and set hourly rates*

### 🔗 Wallet Connection
![Screenshot (50)](https://github.com/user-attachments/assets/d6852b96-5b27-4ea1-a98f-5ac34617daf0)

*Seamless MetaMask wallet integration for secure transactions*

### 🦊 MetaMask Integration
![Screenshot (53)](https://github.com/user-attachments/assets/3c87e88c-a1b7-4eae-9177-6d0d5a817463)

*Connect your wallet to access all platform features*

## 🏗️ Architecture

### 📋 Smart Contract (Solidity)
- **`TutorNFT.sol`** - Main contract handling tutor registration, session booking, and payments
- **ERC-721 Compliant** - Standard NFT implementation for tutor profiles
- **Built-in Rating System** - On-chain reputation management
- **Platform Fee Mechanism** - 5% platform fee, 95% goes to tutors

### 🎨 Frontend (React)
- **Modern React Application** with Web3 integration
- **MetaMask Wallet Connection** for seamless transactions
- **Responsive Design** with glassmorphism UI effects
- **Real-time Contract Interaction** for instant updates

## 🚀 Getting Started

### 📋 Prerequisites

Before you begin, ensure you have:

- 📦 **Node.js** (v16 or later)
- 📥 **npm or yarn** package manager
- 🦊 **MetaMask browser extension**
- 💎 **Core DAO testnet/mainnet tokens**

### ⚡ Quick Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tutornft-dapp
   ```

2. **Install all dependencies**
   ```bash
   npm run install:all
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   ```
   
   Configure your `.env` file:
   ```env
   PRIVATE_KEY=your_wallet_private_key_without_0x
   CORE_SCAN_API_KEY=your_corescan_api_key
   REACT_APP_CONTRACT_ADDRESS=deployed_contract_address
   ```

### 🔧 Smart Contract Deployment

1. **Compile contracts**
   ```bash
   npm run compile
   ```

2. **Run comprehensive tests**
   ```bash
   npm test
   ```

3. **Deploy to Core Testnet**
   ```bash
   npm run deploy:testnet
   ```

4. **Deploy to Core Mainnet**
   ```bash
   npm run deploy:mainnet
   ```

5. **Verify on CoreScan**
   ```bash
   CONTRACT_ADDRESS=<deployed_address> npm run verify
   ```

### 🎯 Frontend Development

1. **Update contract configuration**
   - Copy the deployed contract address
   - Update `REACT_APP_CONTRACT_ADDRESS` in frontend `.env`

2. **Start development server**
   ```bash
   npm run dev
   ```

3. **Build for production**
   ```bash
   npm run build
   ```

## 👥 How to Use

### 🎓 For Tutors

1. **Connect Wallet** - Click "Connect Wallet" and connect your MetaMask
2. **Become a Tutor** - Click "Become a Tutor" button
3. **Fill Profile** - Add your name, expertise, bio, and hourly rate
4. **Set Rate** - Define your hourly rate in CORE tokens
5. **Register** - Submit registration to mint your tutor NFT

### 📚 For Students

1. **Connect Wallet** - Ensure your MetaMask is connected
2. **Browse Tutors** - Explore available tutors and their profiles
3. **Select & Book** - Choose a tutor and session duration
4. **Pay Securely** - Pay for the session using CORE tokens
5. **Rate Experience** - After the session, rate your tutor

## 🌐 Network Information

### 🧪 Core Testnet
- **Network:** Core Testnet
- **Chain ID:** 1115
- **RPC:** `https://rpc.test.btcs.network`
- **Explorer:** https://scan.test.btcs.network

### 🚀 Core Mainnet
- **Network:** Core Mainnet  
- **Chain ID:** 1116
- **RPC:** `https://rpc.coredao.org`
- **Explorer:** https://scan.coredao.org

## 📚 Smart Contract API

### 👨‍🏫 Tutor Registration
```solidity
function registerTutor(
    string memory name,
    string memory subject,
    string memory bio,
    uint256 hourlyRate,
    string memory tokenURI
) public returns (uint256)
```

### 📅 Session Booking
```solidity
function bookSession(uint256 tutorTokenId, uint256 duration) public payable
```

### ✅ Session Completion
```solidity
function completeSession(uint256 tutorTokenId, uint256 sessionIndex, uint8 rating) public
```

### ⚙️ Profile Management
```solidity
function updateTutorProfile(
    uint256 tokenId,
    string memory bio,
    uint256 hourlyRate,
    bool isActive
) public
```

### 👀 View Functions
- `getTutorProfile(uint256 tokenId)` - Get detailed tutor profile
- `getActiveTutors()` - List all active tutor IDs
- `getTutorsByAddress(address tutorAddress)` - Get tutors by wallet address
- `getTutorSessions(uint256 tokenId)` - View session history

## 🔒 Security Features

- 🛡️ **ReentrancyGuard** - Prevents reentrancy attacks on payments
- 👑 **Ownership Controls** - Only NFT owners can modify profiles
- 💰 **Payment Validation** - Ensures sufficient payment before booking
- ⭐ **Rating Limits** - Restricts ratings to 1-5 scale
- ✅ **Session Verification** - Only participants can complete sessions

## 💰 Economics & Tokenomics

- 💸 **Platform Fee:** 5% of each session payment
- 👨‍🏫 **Tutor Earnings:** 95% of session payment goes directly to tutor
- ⛽ **Gas Optimized:** Smart contracts optimized for lower transaction costs
- 🎯 **Flexible Pricing:** Tutors set their own competitive hourly rates

## 🗺️ Development Roadmap

- [ ] 🔍 Advanced search and filtering system
- [ ] 🌍 Multi-language support
- [ ] 📹 Integrated video call functionality
- [ ] ⚖️ Dispute resolution system
- [ ] 📦 Bulk session booking feature
- [ ] 📅 Tutor availability scheduling
- [ ] 📱 Native mobile app development
- [ ] 🤖 AI-powered tutor matching

## 🧪 Testing

Run our comprehensive test suite:

```bash
npm test
```

**Test Coverage Includes:**
- ✅ Contract deployment and initialization
- ✅ Tutor registration and profile management
- ✅ Session booking and completion flows
- ✅ Rating system functionality
- ✅ Payment processing and distribution
- ✅ Access control and security measures
- ✅ Edge cases and error handling

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Community

Need help? We're here for you!

- 🐛 **Issues:** [Create an issue on GitHub](https://github.com/your-repo/issues)
- 💬 **Discord:** Join our community Discord server
- 📧 **Email:** support@tutornft.com
- 📚 **Documentation:** Comprehensive docs available

## 🙏 Acknowledgments

- 🏗️ **Core DAO** - For providing robust blockchain infrastructure
- 🛡️ **OpenZeppelin** - For secure smart contract libraries
- ⚛️ **React Community** - For amazing frontend development tools
- 🦊 **MetaMask** - For seamless Web3 wallet integration

---

<div align="center">

**Built with ❤️ for the decentralized education future**

[⭐ Star this repo](https://github.com/your-repo) • [🐛 Report Bug](https://github.com/your-repo/issues) • [💡 Request Feature](https://github.com/your-repo/issues)

</div>
