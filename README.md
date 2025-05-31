# TutorNFT - Decentralized Tutoring Platform

TutorNFT is a blockchain-powered online tutoring platform built on Core DAO where tutors mint NFTs representing their profiles and students can book and pay for tutoring sessions using cryptocurrency.

## Features

- **NFT-Based Tutor Profiles**: Tutors create unique NFT profiles with their expertise and rates
- **Decentralized Payments**: Secure cryptocurrency payments through smart contracts
- **Rating System**: Students can rate tutors, building reputation on-chain
- **Session Management**: Complete booking and completion workflow
- **Core DAO Integration**: Built specifically for the Core blockchain ecosystem

## Architecture

### Smart Contract (Solidity)
- `TutorNFT.sol`: Main contract handling tutor registration, session booking, and payments
- ERC-721 compliant NFT implementation
- Built-in rating and reputation system
- Platform fee mechanism (5% of session payments)

### Frontend (React)
- Modern React application with Web3 integration
- MetaMask wallet connection
- Responsive design with glassmorphism UI
- Real-time contract interaction

## Getting Started

### Prerequisites
- Node.js (v16 or later)
- npm or yarn
- MetaMask browser extension
- Core DAO testnet/mainnet tokens

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tutornft-dapp
   ```

2. **Install dependencies**
   ```bash
   npm run install:all
   ```

3. **Environment Setup**
   ```bash
   cp .env.example .env
   ```
   
   Fill in your `.env` file with:
   - `PRIVATE_KEY`: Your wallet private key (without 0x prefix)
   - `CORE_SCAN_API_KEY`: CoreScan API key for contract verification

### Smart Contract Deployment

1. **Compile contracts**
   ```bash
   npm run compile
   ```

2. **Run tests**
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

5. **Verify contract**
   ```bash
   CONTRACT_ADDRESS=<deployed_address> npm run verify
   ```

### Frontend Development

1. **Update contract address**
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

## Usage

### For Tutors
1. Connect your MetaMask wallet
2. Click "Become a Tutor"
3. Fill in your profile information
4. Set your hourly rate in CORE tokens
5. Submit registration (mints your tutor NFT)

### For Students
1. Connect your MetaMask wallet
2. Browse available tutors
3. Select a tutor and session duration
4. Pay for the session using CORE tokens
5. After the session, rate your experience

## Contract Addresses

### Core Testnet
- Network: Core Testnet
- Chain ID: 1115
- RPC: https://rpc.test.btcs.network
- Explorer: https://scan.test.btcs.network

### Core Mainnet
- Network: Core Mainnet  
- Chain ID: 1116
- RPC: https://rpc.coredao.org
- Explorer: https://scan.coredao.org

## API Reference

### Smart Contract Methods

#### Tutor Registration
```solidity
function registerTutor(
    string memory name,
    string memory subject,
    string memory bio,
    uint256 hourlyRate,
    string memory tokenURI
) public returns (uint256)
```

#### Session Booking
```solidity
function bookSession(uint256 tutorTokenId, uint256 duration) public payable
```

#### Session Completion
```solidity
function completeSession(uint256 tutorTokenId, uint256 sessionIndex, uint8 rating) public
```

#### Profile Management
```solidity
function updateTutorProfile(
    uint256 tokenId,
    string memory bio,
    uint256 hourlyRate,
    bool isActive
) public
```

### View Functions
- `getTutorProfile(uint256 tokenId)`: Get tutor profile details
- `getActiveTutors()`: Get list of active tutor IDs
- `getTutorsByAddress(address tutorAddress)`: Get tutor IDs for an address
- `getTutorSessions(uint256 tokenId)`: Get session history for a tutor

## Security Features

- **ReentrancyGuard**: Prevents reentrancy attacks on payment functions
- **Ownership Controls**: Only NFT owners can modify their profiles
- **Payment Validation**: Ensures sufficient payment before booking
- **Rating Limits**: Restricts ratings to 1-5 scale
- **Session Verification**: Only session participants can complete sessions

## Economics

- **Platform Fee**: 5% of each session payment goes to platform
- **Tutor Payment**: 95% of session payment goes directly to tutor
- **Gas Optimization**: Optimized contract for lower transaction costs
- **Flexible Pricing**: Tutors set their own hourly rates

## Development Roadmap

- [ ] Advanced search and filtering
- [ ] Multi-language support
- [ ] Video call integration
- [ ] Dispute resolution system
- [ ] Bulk session booking
- [ ] Tutor availability scheduling
- [ ] Mobile app development

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Testing

Run the comprehensive test suite:

```bash
npm test
```

Test coverage includes:
- Contract deployment
- Tutor registration
- Session booking and completion
- Rating system
- Payment flows
- Access controls
- Edge cases

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Join our community Discord
- Email: support@tutornft.com

## Acknowledgments

- Core DAO for the blockchain infrastructure
- OpenZeppelin for secure smart contract libraries
- React and Web3 communities for frontend tools

---

**Built with ❤️ for the decentralized education future**

// .gitignore
# Dependencies
node_modules/
frontend/node_modules/

# Production builds
/build
frontend/build/
frontend/dist/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Hardhat
cache/
artifacts/
typechain/
typechain-types/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Coverage
coverage/
*.lcov

# Temporary
*.tmp
*.temp

# Lock files (keep one)
package-lock.json
yarn.lock

# Deployment artifacts
deployments/
.openzeppelin/

# IPFS
.ipfs/
