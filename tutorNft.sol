pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TutorNFT is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    
    struct TutorProfile {
        string name;
        string subject;
        string bio;
        uint256 hourlyRate;
        uint256 totalSessions;
        uint256 rating;
        uint256 ratingCount;
        bool isActive;
        address tutorAddress;
    }
    
    struct Session {
        uint256 tutorTokenId;
        address student;
        uint256 duration;
        uint256 payment;
        uint256 timestamp;
        bool completed;
        uint8 rating;
    }
    
    mapping(uint256 => TutorProfile) public tutorProfiles;
    mapping(uint256 => Session[]) public tutorSessions;
    mapping(address => uint256[]) public tutorsByAddress;
    
    uint256[] public activeTutorIds;
    
    event TutorRegistered(uint256 indexed tokenId, address indexed tutor, string name, string subject);
    event SessionBooked(uint256 indexed tutorTokenId, address indexed student, uint256 duration, uint256 payment);
    event SessionCompleted(uint256 indexed tutorTokenId, address indexed student, uint8 rating);
    event TutorRated(uint256 indexed tutorTokenId, uint256 newRating, uint256 ratingCount);
    
    constructor() ERC721("TutorNFT", "TNFT") {}
    
    function registerTutor(
        string memory name,
        string memory subject,
        string memory bio,
        uint256 hourlyRate,
        string memory tokenURI
    ) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        
        tutorProfiles[tokenId] = TutorProfile({
            name: name,
            subject: subject,
            bio: bio,
            hourlyRate: hourlyRate,
            totalSessions: 0,
            rating: 0,
            ratingCount: 0,
            isActive: true,
            tutorAddress: msg.sender
        });
        
        tutorsByAddress[msg.sender].push(tokenId);
        activeTutorIds.push(tokenId);
        
        emit TutorRegistered(tokenId, msg.sender, name, subject);
        return tokenId;
    }
    
    function bookSession(uint256 tutorTokenId, uint256 duration) public payable nonReentrant {
        require(_exists(tutorTokenId), "Tutor does not exist");
        require(tutorProfiles[tutorTokenId].isActive, "Tutor is not active");
        
        uint256 requiredPayment = tutorProfiles[tutorTokenId].hourlyRate * duration / 3600;
        require(msg.value >= requiredPayment, "Insufficient payment");
        
        Session memory newSession = Session({
            tutorTokenId: tutorTokenId,
            student: msg.sender,
            duration: duration,
            payment: msg.value,
            timestamp: block.timestamp,
            completed: false,
            rating: 0
        });
        
        tutorSessions[tutorTokenId].push(newSession);
        
        emit SessionBooked(tutorTokenId, msg.sender, duration, msg.value);
    }
    
    function completeSession(uint256 tutorTokenId, uint256 sessionIndex, uint8 rating) public {
        require(sessionIndex < tutorSessions[tutorTokenId].length, "Invalid session index");
        Session storage session = tutorSessions[tutorTokenId][sessionIndex];
        require(session.student == msg.sender, "Not your session");
        require(!session.completed, "Session already completed");
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");
        
        session.completed = true;
        session.rating = rating;
        
        // Update tutor stats
        TutorProfile storage tutor = tutorProfiles[tutorTokenId];
        tutor.totalSessions++;
        tutor.rating = (tutor.rating * tutor.ratingCount + rating) / (tutor.ratingCount + 1);
        tutor.ratingCount++;
        
        // Transfer payment to tutor (minus platform fee)
        uint256 platformFee = session.payment * 5 / 100; // 5% platform fee
        uint256 tutorPayment = session.payment - platformFee;
        
        payable(tutor.tutorAddress).transfer(tutorPayment);
        
        emit SessionCompleted(tutorTokenId, msg.sender, rating);
        emit TutorRated(tutorTokenId, tutor.rating, tutor.ratingCount);
    }
    
    function updateTutorProfile(
        uint256 tokenId,
        string memory bio,
        uint256 hourlyRate,
        bool isActive
    ) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner of this tutor NFT");
        
        TutorProfile storage tutor = tutorProfiles[tokenId];
        tutor.bio = bio;
        tutor.hourlyRate = hourlyRate;
        tutor.isActive = isActive;
    }
    
    function getTutorProfile(uint256 tokenId) public view returns (TutorProfile memory) {
        require(_exists(tokenId), "Tutor does not exist");
        return tutorProfiles[tokenId];
    }
    
    function getTutorSessions(uint256 tokenId) public view returns (Session[] memory) {
        return tutorSessions[tokenId];
    }
    
    function getActiveTutors() public view returns (uint256[] memory) {
        uint256[] memory active = new uint256[](activeTutorIds.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < activeTutorIds.length; i++) {
            if (tutorProfiles[activeTutorIds[i]].isActive) {
                active[count] = activeTutorIds[i];
                count++;
            }
        }
        
        // Resize array to actual count
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = active[i];
        }
        
        return result;
    }
    
    function getTutorsByAddress(address tutorAddress) public view returns (uint256[] memory) {
        return tutorsByAddress[tutorAddress];
    }
    
    function withdrawPlatformFees() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    // Override required functions
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}