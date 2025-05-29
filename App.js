import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { User, BookOpen, Star, Clock, DollarSign } from 'lucide-react';
import './App.css';

const CONTRACT_ADDRESS = process.env.REACT_APP_CONTRACT_ADDRESS || '';
const NETWORK_ID = process.env.REACT_APP_NETWORK_ID || '1116';

// ABI excerpt - you would include the full ABI here
const CONTRACT_ABI = [
  "function registerTutor(string memory name, string memory subject, string memory bio, uint256 hourlyRate, string memory tokenURI) public returns (uint256)",
  "function bookSession(uint256 tutorTokenId, uint256 duration) public payable",
  "function completeSession(uint256 tutorTokenId, uint256 sessionIndex, uint8 rating) public",
  "function getTutorProfile(uint256 tokenId) public view returns (tuple(string name, string subject, string bio, uint256 hourlyRate, uint256 totalSessions, uint256 rating, uint256 ratingCount, bool isActive, address tutorAddress))",
  "function getActiveTutors() public view returns (uint256[])",
  "function getTutorsByAddress(address tutorAddress) public view returns (uint256[])",
  "event TutorRegistered(uint256 indexed tokenId, address indexed tutor, string name, string subject)",
  "event SessionBooked(uint256 indexed tutorTokenId, address indexed student, uint256 duration, uint256 payment)"
];

function App() {
  const [account, setAccount] = useState('');
  const [contract, setContract] = useState(null);
  const [tutors, setTutors] = useState([]);
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('browse');

  useEffect(() => {
    checkWalletConnection();
  }, []);

  const checkWalletConnection = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
          setAccount(accounts[0]);
          initializeContract();
        }
      } catch (error) {
        console.error('Error checking wallet connection:', error);
      }
    }
  };

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
        initializeContract();
      } catch (error) {
        console.error('Error connecting wallet:', error);
      }
    } else {
      alert('Please install MetaMask to use this DApp');
    }
  };

  const initializeContract = async () => {
    if (window.ethereum && CONTRACT_ADDRESS) {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const contractInstance = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
        setContract(contractInstance);
        loadTutors(contractInstance);
      } catch (error) {
        console.error('Error initializing contract:', error);
      }
    }
  };

  const loadTutors = async (contractInstance) => {
    try {
      setLoading(true);
      const tutorIds = await contractInstance.getActiveTutors();
      const tutorProfiles = [];

      for (const id of tutorIds) {
        try {
          const profile = await contractInstance.getTutorProfile(id);
          tutorProfiles.push({
            id: id.toString(),
            ...profile
          });
        } catch (error) {
          console.error(`Error loading tutor ${id}:`, error);
        }
      }

      setTutors(tutorProfiles);
    } catch (error) {
      console.error('Error loading tutors:', error);
    } finally {
      setLoading(false);
    }
  };

  const registerTutor = async (formData) => {
    if (!contract) return;

    try {
      setLoading(true);
      const tx = await contract.registerTutor(
        formData.name,
        formData.subject,
        formData.bio,
        ethers.parseEther(formData.hourlyRate),
        formData.tokenURI || ''
      );
      await tx.wait();
      alert('Tutor registered successfully!');
      loadTutors(contract);
    } catch (error) {
      console.error('Error registering tutor:', error);
      alert('Error registering tutor: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const bookSession = async (tutorId, duration, payment) => {
    if (!contract) return;

    try {
      setLoading(true);
      const tx = await contract.bookSession(tutorId, duration, {
        value: ethers.parseEther(payment)
      });
      await tx.wait();
      alert('Session booked successfully!');
    } catch (error) {
      console.error('Error booking session:', error);
      alert('Error booking session: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="app-header">
        <h1><BookOpen /> TutorNFT</h1>
        <div className="header-actions">
          {account ? (
            <div className="wallet-info">
              <User size={16} />
              <span>{account.slice(0, 6)}...{account.slice(-4)}</span>
            </div>
          ) : (
            <button onClick={connectWallet} className="connect-btn">
              Connect Wallet
            </button>
          )}
        </div>
      </header>

      <nav className="tab-nav">
        <button 
          className={activeTab === 'browse' ? 'active' : ''}
          onClick={() => setActiveTab('browse')}
        >
          Browse Tutors
        </button>
        <button 
          className={activeTab === 'register' ? 'active' : ''}
          onClick={() => setActiveTab('register')}
        >
          Become a Tutor
        </button>
      </nav>

      <main className="main-content">
        {activeTab === 'browse' && (
          <TutorBrowser 
            tutors={tutors} 
            loading={loading} 
            onBookSession={bookSession}
          />
        )}
        {activeTab === 'register' && (
          <TutorRegistration 
            onRegister={registerTutor}
            loading={loading}
          />
        )}
      </main>
    </div>
  );
}

function TutorBrowser({ tutors, loading, onBookSession }) {
  if (loading) {
    return <div className="loading">Loading tutors...</div>;
  }

  return (
    <div className="tutor-grid">
      {tutors.map(tutor => (
        <TutorCard 
          key={tutor.id}
          tutor={tutor}
          onBookSession={onBookSession}
        />
      ))}
      {tutors.length === 0 && (
        <div className="no-tutors">No tutors available yet.</div>
      )}
    </div>
  );
}

function TutorCard({ tutor, onBookSession }) {
  const [showBooking, setShowBooking] = useState(false);
  const [duration, setDuration] = useState('3600'); // 1 hour in seconds

  const handleBook = () => {
    const payment = (parseFloat(ethers.formatEther(tutor.hourlyRate)) * parseInt(duration) / 3600).toString();
    onBookSession(tutor.id, duration, payment);
    setShowBooking(false);
  };

  return (
    <div className="tutor-card">
      <div className="tutor-header">
        <h3>{tutor.name}</h3>
        <div className="rating">
          <Star size={16} />
          <span>{tutor.ratingCount > 0 ? (tutor.rating / 100).toFixed(1) : 'New'}</span>
        </div>
      </div>
      
      <div className="tutor-info">
        <p className="subject">{tutor.subject}</p>
        <p className="bio">{tutor.bio}</p>
        
        <div className="tutor-stats">
          <div className="stat">
            <Clock size={14} />
            <span>{tutor.totalSessions.toString()} sessions</span>
          </div>
          <div className="stat">
            <DollarSign size={14} />
            <span>{ethers.formatEther(tutor.hourlyRate)} CORE/hour</span>
          </div>
        </div>
      </div>

      {!showBooking ? (
        <button onClick={() => setShowBooking(true)} className="book-btn">
          Book Session
        </button>
      ) : (
        <div className="booking-form">
          <select 
            value={duration} 
            onChange={(e) => setDuration(e.target.value)}
            className="duration-select"
          >
            <option value="1800">30 minutes</option>
            <option value="3600">1 hour</option>
            <option value="7200">2 hours</option>
          </select>
          <div className="booking-actions">
            <button onClick={handleBook} className="confirm-btn">Confirm</button>
            <button onClick={() => setShowBooking(false)} className="cancel-btn">Cancel</button>
          </div>
        </div>
      )}
    </div>
  );
}

function TutorRegistration({ onRegister, loading }) {
  const [formData, setFormData] = useState({
    name: '',
    subject: '',
    bio: '',
    hourlyRate: '',
    tokenURI: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    if (formData.name && formData.subject && formData.bio && formData.hourlyRate) {
      onRegister(formData);
    } else {
      alert('Please fill in all required fields');
    }
  };

  return (
    <div className="registration-form">
      <h2>Become a Tutor</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Your Name *"
          value={formData.name}
          onChange={(e) => setFormData({...formData, name: e.target.value})}
          required
        />
        
        <input
          type="text"
          placeholder="Subject/Expertise *"
          value={formData.subject}
          onChange={(e) => setFormData({...formData, subject: e.target.value})}
          required
        />
        
        <textarea
          placeholder="Tell students about yourself *"
          value={formData.bio}
          onChange={(e) => setFormData({...formData, bio: e.target.value})}
          required
        />
        
        <input
          type="number"
          step="0.01"
          placeholder="Hourly Rate (CORE) *"
          value={formData.hourlyRate}
          onChange={(e) => setFormData({...formData, hourlyRate: e.target.value})}
          required
        />
        
        <input
          type="url"
          placeholder="Profile Image URL (optional)"
          value={formData.tokenURI}
          onChange={(e) => setFormData({...formData, tokenURI: e.target.value})}
        />
        
        <button type="submit" disabled={loading} className="register-btn">
          {loading ? 'Registering...' : 'Register as Tutor'}
        </button>
      </form>
    </div>
  );
}

export default App;
