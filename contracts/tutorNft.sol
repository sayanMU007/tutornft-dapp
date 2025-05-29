// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TutorNFT is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    Counters.Counter private _tutorIds;
    
    // Platform fee (2.5%)
    uint256 public platformFeePercent = 250; // 250 = 2.5%
    uint256 public constant PERCENT_DIVISOR = 10000;
    
    // Structs
    struct Tutor {
        uint256 tutorId;
        address tutorAddress;
        string name;
        string expertise;
        string description;
        uint256 hourlyRate; // in wei
        uint256 totalEarnings;
        uint256 totalSessions;
        uint256 rating; // Out of 5000 (5000 = 5.0 stars)
        uint256 ratingCount;
        bool isActive;
        uint256 createdAt;
    }
    
    struct Session {
        uint256 sessionId;
        uint256 tutorId;
        address student;
        uint256 duration; // in hours
        uint256 totalCost;
        string subject;
        string meetingLink;
        uint256 scheduledTime;
        SessionStatus status;
        uint256 createdAt;
    }
    
    struct SessionNFT {
        uint256 tokenId;
        uint256 sessionId;
        string certificateURI;
        uint256 completedAt;
    }
    
    enum SessionStatus {
        Scheduled,
        InProgress,
        Completed,
        Cancelled,
        Disputed
    }
    
    // Mappings
    mapping(uint256 => Tutor) public tutors;
    mapping(address => uint256) public tutorAddressToId;
    mapping(uint256 => Session) public sessions;
    mapping(uint256 => SessionNFT) public sessionNFTs;
    mapping(address => uint256[]) public studentSessions;
    mapping(uint256 => uint256[]) public tutorSessions;
    mapping(bytes32 => bool) public completedChallenges;
    
    // Events
    event TutorRegistered(uint256 indexed tutorId, address indexed tutorAddress, string name);
    event SessionBooked(uint256 indexed sessionId, uint256 indexed tutorId, address indexed student, uint256 cost);
    event SessionCompleted(uint256 indexed sessionId, uint256 indexed tokenId);
    event SessionCancelled(uint256 indexed sessionId, string reason);
    event TutorRated(uint256 indexed tutorId, uint256 rating, address indexed student);
    event EarningsWithdrawn(uint256 indexed tutorId, uint256 amount);
    
    constructor() ERC721("TutorNFT", "TNFT") {}
    
    // Tutor Management
    function registerTutor(
        string memory _name,
        string memory _expertise,
        string memory _description,
        uint256 _hourlyRate
    ) external {
        require(bytes(_name).length > 0, "Name required");
        require(_hourlyRate > 0, "Rate must be positive");
        require(tutorAddressToId[msg.sender] == 0, "Already registered");
        
        _tutorIds.increment();
        uint256 newTutorId = _tutorIds.current();
        
        tutors[newTutorId] = Tutor({
            tutorId: newTutorId,
            tutorAddress: msg.sender,
            name: _name,
            expertise: _expertise,
            description: _description,
            hourlyRate: _hourlyRate,
            totalEarnings: 0,
            totalSessions: 0,
            rating: 0,
            ratingCount: 0,
            isActive: true,
            createdAt: block.timestamp
        });
        
        tutorAddressToId[msg.sender] = newTutorId;
        
        emit TutorRegistered(newTutorId, msg.sender, _name);
    }
    
    function updateTutorProfile(
        string memory _name,
        string memory _expertise,
        string memory _description,
        uint256 _hourlyRate
    ) external {
        uint256 tutorId = tutorAddressToId[msg.sender];
        require(tutorId > 0, "Not registered");
        
        Tutor storage tutor = tutors[tutorId];
        tutor.name = _name;
        tutor.expertise = _expertise;
        tutor.description = _description;
        tutor.hourlyRate = _hourlyRate;
    }
    
    function toggleTutorStatus() external {
        uint256 tutorId = tutorAddressToId[msg.sender];
        require(tutorId > 0, "Not registered");
        
        tutors[tutorId].isActive = !tutors[tutorId].isActive;
    }
    
    // Session Management
    function bookSession(
        uint256 _tutorId,
        uint256 _duration,
        string memory _subject,
        uint256 _scheduledTime
    ) external payable nonReentrant {
        require(_tutorId > 0 && _tutorId <= _tutorIds.current(), "Invalid tutor");
        require(_duration > 0, "Duration required");
        require(_scheduledTime > block.timestamp, "Invalid time");
        
        Tutor storage tutor = tutors[_tutorId];
        require(tutor.isActive, "Tutor inactive");
        
        uint256 totalCost = tutor.hourlyRate * _duration;
        require(msg.value >= totalCost, "Insufficient payment");
        
        // Refund excess payment
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
        
        _tokenIds.increment();
        uint256 newSessionId = _tokenIds.current();
        
        sessions[newSessionId] = Session({
            sessionId: newSessionId,
            tutorId: _tutorId,
            student: msg.sender,
            duration: _duration,
            totalCost: totalCost,
            subject: _subject,
            meetingLink: "",
            scheduledTime: _scheduledTime,
            status: SessionStatus.Scheduled,
            createdAt: block.timestamp
        });
        
        studentSessions[msg.sender].push(newSessionId);
        tutorSessions[_tutorId].push(newSessionId);
        
        emit SessionBooked(newSessionId, _tutorId, msg.sender, totalCost);
    }
    
    function startSession(uint256 _sessionId, string memory _meetingLink) external {
        Session storage session = sessions[_sessionId];
        require(session.sessionId > 0, "Session not found");
        
        uint256 tutorId = tutorAddressToId[msg.sender];
        require(session.tutorId == tutorId, "Not your session");
        require(session.status == SessionStatus.Scheduled, "Invalid status");
        
        session.status = SessionStatus.InProgress;
        session.meetingLink = _meetingLink;
    }
    
    function completeSession(
        uint256 _sessionId,
        string memory _certificateURI
    ) external {
        Session storage session = sessions[_sessionId];
        require(session.sessionId > 0, "Session not found");
        
        uint256 tutorId = tutorAddressToId[msg.sender];
        require(session.tutorId == tutorId, "Not your session");
        require(session.status == SessionStatus.InProgress, "Invalid status");
        
        // Update session status
        session.status = SessionStatus.Completed;
        
        // Mint NFT certificate to student
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(session.student, newTokenId);
        _setTokenURI(newTokenId, _certificateURI);
        
        sessionNFTs[newTokenId] = SessionNFT({
            tokenId: newTokenId,
            sessionId: _sessionId,
            certificateURI: _certificateURI,
            completedAt: block.timestamp
        });
        
        // Update tutor stats
        Tutor storage tutor = tutors[session.tutorId];
        tutor.totalSessions++;
        
        // Calculate and transfer earnings
        uint256 platformFee = (session.totalCost * platformFeePercent) / PERCENT_DIVISOR;
        uint256 tutorEarnings = session.totalCost - platformFee;
        
        tutor.totalEarnings += tutorEarnings;
        payable(tutor.tutorAddress).transfer(tutorEarnings);
        
        emit SessionCompleted(_sessionId, newTokenId);
    }
    
    function cancelSession(uint256 _sessionId, string memory _reason) external {
        Session storage session = sessions[_sessionId];
        require(session.sessionId > 0, "Session not found");
        require(
            msg.sender == session.student || 
            tutorAddressToId[msg.sender] == session.tutorId || 
            msg.sender == owner(),
            "Not authorized"
        );
        require(session.status == SessionStatus.Scheduled, "Cannot cancel");
        
        session.status = SessionStatus.Cancelled;
        
        // Refund student
        payable(session.student).transfer(session.totalCost);
        
        emit SessionCancelled(_sessionId, _reason);
    }
    
    // Rating System
    function rateTutor(uint256 _sessionId, uint256 _rating) external {
        require(_rating >= 1000 && _rating <= 5000, "Rating 1-5 stars");
        
        Session storage session = sessions[_sessionId];
        require(session.student == msg.sender, "Not your session");
        require(session.status == SessionStatus.Completed, "Session not completed");
        
        Tutor storage tutor = tutors[session.tutorId];
        
        // Update rating
        uint256 totalRating = (tutor.rating * tutor.ratingCount) + _rating;
        tutor.ratingCount++;
        tutor.rating = totalRating / tutor.ratingCount;
        
        emit TutorRated(session.tutorId, _rating, msg.sender);
    }
    
    // View Functions
    function getTutor(uint256 _tutorId) external view returns (Tutor memory) {
        return tutors[_tutorId];
    }
    
    function getSession(uint256 _sessionId) external view returns (Session memory) {
        return sessions[_sessionId];
    }
    
    function getStudentSessions(address _student) external view returns (uint256[] memory) {
        return studentSessions[_student];
    }
    
    function getTutorSessions(uint256 _tutorId) external view returns (uint256[] memory) {
        return tutorSessions[_tutorId];
    }
    
    function getTotalTutors() external view returns (uint256) {
        return _tutorIds.current();
    }
    
    function getTotalSessions() external view returns (uint256) {
        return _tokenIds.current();
    }
    
    // Admin Functions
    function setPlatformFee(uint256 _feePercent) external onlyOwner {
        require(_feePercent <= 1000, "Max 10% fee"); // Max 10%
        platformFeePercent = _feePercent;
    }
    
    function withdrawPlatformFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        payable(owner()).transfer(balance);
    }
    
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    // Override functions
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