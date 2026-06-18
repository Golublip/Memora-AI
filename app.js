// Memora AI - State Engine & UI Simulation

// Mock Database of Memories
let memories = [
  {
    id: 'node-1',
    title: 'Basic_Life_Support_Cert.pdf',
    category: 'Education',
    priority: 95,
    size: '1.2 MB',
    hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    desc: 'OCR Text: American Heart Association Basic Life Support (BLS) Provider Course completed. Expiration date: July 3, 2026.',
    tags: ['AHA', 'BLS', 'Certificate', 'Medical'],
    x: -80, y: -60, z: 20
  },
  {
    id: 'node-2',
    title: 'Cardiac_Perfusion_Trainee.pdf',
    category: 'Career',
    priority: 92,
    size: '2.4 MB',
    hash: '5d41402abc4b2a76b9719d911017c5921827471284bb41e46820c8991b852a32',
    desc: 'OCR Text: Cardiac Perfusion Clinical Internship completion record, Department of Cardiothoracic Surgery.',
    tags: ['Perfusion', 'Internship', 'Resume', 'Clinical'],
    x: 80, y: 70, z: -30
  },
  {
    id: 'node-3',
    title: 'Aadhaar_Card_Secure.png',
    category: 'Important Documents',
    priority: 98,
    size: '450 KB',
    hash: '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
    desc: 'OCR Text: Unique Identification Authority of India (UIDAI). Government Identification Aadhaar card.',
    tags: ['Aadhaar', 'ID', 'Government', 'Identity'],
    x: -30, y: 80, z: 10
  },
  {
    id: 'node-4',
    title: 'Medical_Prescription_June.jpg',
    category: 'Health',
    priority: 75,
    size: '620 KB',
    hash: 'f3a4b6c8d0e2f4a6b8c0d2e4f6a8b0c2d4e6f8a0b2c4d6e8f0a2b4c6d8e0f2a4',
    desc: 'OCR Text: Pharmacy Prescription. Ibuprofen, Amoxicillin, daily dosage instructions.',
    tags: ['Health', 'Prescription', 'Medical', 'Pharmacy'],
    x: -70, y: 50, z: -10
  },
  {
    id: 'node-5',
    title: 'RentReceipt_June.pdf',
    category: 'Finance',
    priority: 60,
    size: '310 KB',
    hash: 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2',
    desc: 'OCR Text: Monthly Rental Receipt. Paid amount: $1200. Account statement settled.',
    tags: ['Rent', 'Receipt', 'Finance', 'Housing'],
    x: 40, y: -90, z: -15
  }
];

// Reminders Array
let reminders = [
  {
    id: 'rem-1',
    title: 'BLS Certificate Expiry',
    desc: 'Expires in 15 days. Recertification required.',
    due: 'July 3'
  }
];

// App Configurations
let isDyslexicMode = false;
let galaxyZoom = 1.0;
let panX = 0;
let panY = 0;
let isDragging = false;
let startDragX = 0;
let startDragY = 0;

// Initialize Background Neural Network
const neuralCanvas = document.getElementById('neural-bg');
const nCtx = neuralCanvas.getContext('2d');
let particles = [];

function resizeNeuralCanvas() {
  neuralCanvas.width = window.innerWidth;
  neuralCanvas.height = window.innerHeight;
}
window.addEventListener('resize', resizeNeuralCanvas);
resizeNeuralCanvas();

// Particle Class for Neural BG
class NeuralNode {
  constructor() {
    this.x = Math.random() * neuralCanvas.width;
    this.y = Math.random() * neuralCanvas.height;
    this.vx = (Math.random() - 0.5) * 0.4;
    this.vy = (Math.random() - 0.5) * 0.4;
    this.radius = 1.5;
  }

  update() {
    this.x += this.vx;
    this.y += this.vy;
    
    if (this.x < 0 || this.x > neuralCanvas.width) this.vx = -this.vx;
    if (this.y < 0 || this.y > neuralCanvas.height) this.vy = -this.vy;
  }

  draw() {
    nCtx.beginPath();
    nCtx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
    nCtx.fillStyle = 'rgba(0, 242, 254, 0.2)';
    nCtx.fill();
  }
}

// Populate neural nodes
for (let i = 0; i < 40; i++) {
  particles.push(new NeuralNode());
}

function animateNeuralBg() {
  nCtx.clearRect(0, 0, neuralCanvas.width, neuralCanvas.height);
  
  // Connect filaments
  nCtx.strokeStyle = 'rgba(0, 242, 254, 0.05)';
  nCtx.lineWidth = 1;
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      let dx = particles[i].x - particles[j].x;
      let dy = particles[i].y - particles[j].y;
      let dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < 120) {
        nCtx.beginPath();
        nCtx.moveTo(particles[i].x, particles[i].y);
        nCtx.lineTo(particles[j].x, particles[j].y);
        nCtx.stroke();
      }
    }
  }

  // Draw and update
  particles.forEach(p => {
    p.update();
    p.draw();
  });

  requestAnimationFrame(animateNeuralBg);
}
animateNeuralBg();

// Initialize 3D Galaxy Canvas
const galaxyCanvas = document.getElementById('galaxy-canvas');
const gCtx = galaxyCanvas.getContext('2d');
let angleRotation = 0;

function resizeGalaxyCanvas() {
  const rect = galaxyCanvas.parentElement.getBoundingClientRect();
  galaxyCanvas.width = rect.width;
  galaxyCanvas.height = rect.height;
}
window.addEventListener('resize', resizeGalaxyCanvas);
resizeGalaxyCanvas();

// Color definitions for galaxy nodes
const categoryColors = {
  'Education': '#3b82f6',
  'Career': '#10b981',
  'Health': '#ef4444',
  'Finance': '#f59e0b',
  'Personal': '#ec4899',
  'Important Documents': '#8b5cf6',
  'Saved Links': '#06b6d4',
  'AI Generated': '#d946ef'
};

function drawGalaxy() {
  gCtx.clearRect(0, 0, galaxyCanvas.width, galaxyCanvas.height);
  const cx = galaxyCanvas.width / 2 + panX;
  const cy = galaxyCanvas.height / 2 + panY;

  // 1. Draw core nebula
  let coreGlow = gCtx.createRadialGradient(cx, cy, 0, cx, cy, 120 * galaxyZoom);
  coreGlow.addColorStop(0, 'rgba(157, 78, 221, 0.35)');
  coreGlow.addColorStop(0.5, 'rgba(0, 242, 254, 0.08)');
  coreGlow.addColorStop(1, 'rgba(0,0,0,0)');
  gCtx.fillStyle = coreGlow;
  gCtx.beginPath();
  gCtx.arc(cx, cy, 120 * galaxyZoom, 0, Math.PI * 2);
  gCtx.fill();

  // Rotate galaxy context slightly for cosmic rotation
  angleRotation += 0.001;

  // 2. Draw category dust arm clusters
  const categories = Object.keys(categoryColors);
  categories.forEach((cat, index) => {
    let angle = (index * (Math.PI * 2) / categories.length) + angleRotation;
    let radius = 100 * galaxyZoom;
    let ccx = cx + radius * Math.cos(angle);
    let ccy = cy + radius * Math.sin(angle);

    // Nebula dust background
    let dustGlow = gCtx.createRadialGradient(ccx, ccy, 0, ccx, ccy, 45 * galaxyZoom);
    dustGlow.addColorStop(0, categoryColors[cat] + '22');
    dustGlow.addColorStop(1, 'rgba(0,0,0,0)');
    gCtx.fillStyle = dustGlow;
    gCtx.beginPath();
    gCtx.arc(ccx, ccy, 45 * galaxyZoom, 0, Math.PI * 2);
    gCtx.fill();
    
    // Category Label
    gCtx.fillStyle = 'rgba(255,255,255,0.4)';
    gCtx.font = `${Math.max(9, 10 * galaxyZoom)}px Inter`;
    gCtx.textAlign = 'center';
    gCtx.fillText(cat.toUpperCase(), ccx, ccy - 20 * galaxyZoom);
  });

  // 3. Draw star nodes (memories)
  memories.forEach(node => {
    // Project 3D positions with cosmic rotation
    let cosR = Math.cos(angleRotation * 0.5);
    let sinR = Math.sin(angleRotation * 0.5);
    let rx = node.x * cosR - node.y * sinR;
    let ry = node.x * sinR + node.y * cosR;

    let sx = cx + rx * galaxyZoom;
    let sy = cy + ry * galaxyZoom;

    // Node star glow
    gCtx.shadowColor = categoryColors[node.category] || '#fff';
    gCtx.shadowBlur = 10 * galaxyZoom;
    
    gCtx.fillStyle = '#ffffff';
    gCtx.beginPath();
    gCtx.arc(sx, sy, 3.5 * galaxyZoom, 0, Math.PI * 2);
    gCtx.fill();
    
    // Reset shadow
    gCtx.shadowBlur = 0;

    // Label on hover/zoom
    if (galaxyZoom > 0.8) {
      gCtx.fillStyle = 'rgba(243, 244, 246, 0.7)';
      gCtx.font = '9px Inter';
      gCtx.textAlign = 'center';
      gCtx.fillText(node.title.substring(0, 16), sx, sy + 12);
    }
  });

  requestAnimationFrame(drawGalaxy);
}
setTimeout(() => {
  resizeGalaxyCanvas();
  drawGalaxy();
}, 200);

// Drag & Pan controls for Galaxy
galaxyCanvas.addEventListener('mousedown', (e) => {
  isDragging = true;
  startDragX = e.clientX - panX;
  startDragY = e.clientY - panY;
});

window.addEventListener('mousemove', (e) => {
  if (isDragging) {
    panX = e.clientX - startDragX;
    panY = e.clientY - startDragY;
  }
});

window.addEventListener('mouseup', () => {
  isDragging = false;
});

// Zoom controls
galaxyCanvas.addEventListener('wheel', (e) => {
  e.preventDefault();
  if (e.deltaY < 0) {
    galaxyZoom = Math.min(2.5, galaxyZoom + 0.1);
  } else {
    galaxyZoom = Math.max(0.4, galaxyZoom - 0.1);
  }
});

// Click detection on individual star nodes
galaxyCanvas.addEventListener('click', (e) => {
  const rect = galaxyCanvas.getBoundingClientRect();
  const clickX = e.clientX - rect.left;
  const clickY = e.clientY - rect.top;

  const cx = galaxyCanvas.width / 2 + panX;
  const cy = galaxyCanvas.height / 2 + panY;

  let clickedNode = null;

  for (let node of memories) {
    let cosR = Math.cos(angleRotation * 0.5);
    let sinR = Math.sin(angleRotation * 0.5);
    let rx = node.x * cosR - node.y * sinR;
    let ry = node.x * sinR + node.y * cosR;

    let sx = cx + rx * galaxyZoom;
    let sy = cy + ry * galaxyZoom;

    let dx = clickX - sx;
    let dy = clickY - sy;
    let dist = Math.sqrt(dx * dx + dy * dy);

    if (dist < 10 * galaxyZoom) {
      clickedNode = node;
      break;
    }
  }

  if (clickedNode) {
    showNodeDetails(clickedNode);
  }
});

// Display detailed metadata in Inspector Panel
const nodeInspector = document.getElementById('node-inspector');
function showNodeDetails(node) {
  document.getElementById('inspect-title').innerText = node.title;
  const catBadge = document.getElementById('inspect-category');
  catBadge.innerText = node.category;
  catBadge.className = `category-badge ${node.category.toLowerCase().replace(' ', '-')}`;
  
  // Set badge specific style color directly if needed
  catBadge.style.borderColor = categoryColors[node.category];
  catBadge.style.color = categoryColors[node.category];
  catBadge.style.background = categoryColors[node.category] + '22';

  document.getElementById('inspect-priority').innerText = `${node.priority}/100`;
  document.getElementById('inspect-size').innerText = node.size;
  document.getElementById('inspect-desc').innerText = node.desc;
  document.getElementById('inspect-hash').innerText = node.hash.substring(0, 16) + '...';
  
  // Tags
  const tagsContainer = document.getElementById('inspect-tags');
  tagsContainer.innerHTML = '';
  node.tags.forEach(t => {
    const span = document.createElement('span');
    span.className = 'tag';
    span.innerText = t;
    tagsContainer.appendChild(span);
  });

  nodeInspector.classList.remove('hidden');
}

document.getElementById('inspect-close').addEventListener('click', () => {
  nodeInspector.classList.add('hidden');
});

// Dynamic Dyslexia Mode Toggle
const btnDyslexic = document.getElementById('btn-dyslexic');
btnDyslexic.addEventListener('click', () => {
  isDyslexicMode = !isDyslexicMode;
  if (isDyslexicMode) {
    document.body.classList.add('dyslexic-mode');
    btnDyslexic.classList.add('btn-cyan');
    btnDyslexic.classList.remove('btn-glass');
  } else {
    document.body.classList.remove('dyslexic-mode');
    btnDyslexic.classList.remove('btn-cyan');
    btnDyslexic.classList.add('btn-glass');
  }
});

// AI ORB Assistant state logic
const aiOrb = document.getElementById('ai-orb');
const orbStatus = document.getElementById('orb-status');

function setOrbState(state) {
  aiOrb.className = `ai-orb ${state}`;
  switch(state) {
    case 'idle':
      orbStatus.innerText = 'ORB STANDBY';
      orbStatus.style.color = '#00f2fe';
      break;
    case 'listening':
      orbStatus.innerText = 'LISTENING...';
      orbStatus.style.color = '#9d4edd';
      break;
    case 'processing':
      orbStatus.innerText = 'AI PROCESSOR ACTIVE';
      orbStatus.style.color = '#f59e0b';
      break;
    case 'speaking':
      orbStatus.innerText = 'MEMORA SYNTHESIS';
      orbStatus.style.color = '#10b981';
      break;
  }
}

// Simulation Queue Ingestion Pipeline
const queueList = document.getElementById('queue-list');

function enqueueFile(fileName, sizeText, mimeType, ocrTextOverride = null) {
  // Clear empty state
  const empty = queueList.querySelector('.queue-empty');
  if (empty) empty.remove();

  const id = 'queue-' + Date.now();
  const item = document.createElement('div');
  item.className = 'queue-item';
  item.id = id;
  
  item.innerHTML = `
    <div class="queue-title">
      <span><i class="fa-solid fa-file-shield text-cyan"></i> ${fileName}</span>
      <span class="text-secondary">${sizeText}</span>
    </div>
    <div class="queue-status">Pending encryption queue...</div>
    <div class="progress-bar"><div class="progress-fill"></div></div>
  `;
  queueList.appendChild(item);

  // Background pipeline execution
  const fill = item.querySelector('.progress-fill');
  const status = item.querySelector('.queue-status');

  // Step 1: Local ZK encryption
  setTimeout(() => {
    fill.style.width = '25%';
    status.innerHTML = `<i class="fa-solid fa-key text-purple"></i> Local Encrypting (AES-GCM)...`;
  }, 1000);

  // Step 2: Hashing
  setTimeout(() => {
    fill.style.width = '50%';
    status.innerHTML = `<i class="fa-solid fa-calculator text-cyan"></i> Generating SHA-256 integrity hash...`;
  }, 2200);

  // Step 3: OCR
  setTimeout(() => {
    fill.style.width = '75%';
    status.innerHTML = `<i class="fa-solid fa-eye text-yellow"></i> Processing local OCR text extraction...`;
  }, 3500);

  // Step 4: AI sorting & completion
  setTimeout(() => {
    fill.style.width = '100%';
    status.innerHTML = `<i class="fa-solid fa-brain text-purple"></i> Gemini Auto-categorizing...`;
  }, 4800);

  // Complete & Add node to vault
  setTimeout(() => {
    item.remove();
    if (queueList.children.length === 0) {
      queueList.innerHTML = `<div class="queue-empty">Queue idle. Ready for memories.</div>`;
    }

    // Auto classify & push
    let category = 'Important Documents';
    let priority = 80;
    let tags = ['Imported'];
    let finalDesc = ocrTextOverride || 'OCR: Stored record details.';

    if (fileName.toLowerCase().includes('cert')) {
      category = 'Education';
      priority = 90;
      tags = ['Google', 'Coursera', 'Certificate'];
    } else if (fileName.toLowerCase().includes('invoice') || fileName.toLowerCase().includes('receipt')) {
      category = 'Finance';
      priority = 72;
      tags = ['Receipt', 'Billing'];
    }

    // Compute mock SHA-256
    let mockHash = Array.from({length: 64}, () => Math.floor(Math.random()*16).toString(16)).join('');

    // Check duplicate detection
    const isDuplicate = memories.some(m => m.title === fileName);
    if (isDuplicate) {
      alert(`⚠️ DUPLICATE DETECTED: A file named "${fileName}" is already registered. Vault health score compromised.`);
      document.getElementById('health-duplicates').innerHTML = `<i class="fa-solid fa-triangle-exclamation text-yellow"></i> 2 Duplicates Detected`;
      // Deduct health
      updateHealthScore(75);
    }

    // Add star node position in galaxy
    let angle = Math.random() * Math.PI * 2;
    let dist = 60 + Math.random() * 50;

    const newNode = {
      id: 'node-' + Date.now(),
      title: fileName,
      category: category,
      priority: priority,
      size: sizeText,
      hash: mockHash,
      desc: finalDesc,
      tags: tags,
      x: dist * Math.cos(angle),
      y: dist * Math.sin(angle),
      z: (Math.random() - 0.5) * 40
    };

    memories.push(newNode);
    showNodeDetails(newNode);

    // Auto-generate reminders if date context is found
    if (finalDesc.includes('Expiry') || finalDesc.includes('Expires')) {
      const remContainer = document.getElementById('reminders-list');
      const newRem = document.createElement('div');
      newRem.className = 'reminder-card urgent';
      newRem.innerHTML = `
        <div class="reminder-content">
          <p class="reminder-title">Credential Renewal: ${fileName}</p>
          <p class="reminder-desc">Reminder derived from extracted expiry dates.</p>
        </div>
        <span class="time-badge">Derived</span>
      `;
      remContainer.prepend(newRem);
    }

  }, 6000);
}

function updateHealthScore(newScore) {
  const circle = document.querySelector('.circle');
  const text = document.querySelector('.percentage');
  circle.setAttribute('stroke-dasharray', `${newScore}, 100`);
  text.innerText = newScore;
}

// Ingestion drag and drop events
const dropArea = document.getElementById('drop-area');
const fileInput = document.getElementById('file-input');

dropArea.addEventListener('click', () => fileInput.click());

fileInput.addEventListener('change', () => {
  for (let file of fileInput.files) {
    enqueueFile(file.name, `${(file.size / 1024).toFixed(0)} KB`, file.type);
  }
});

dropArea.addEventListener('dragover', (e) => {
  e.preventDefault();
  dropArea.classList.add('dragover');
});

dropArea.addEventListener('dragleave', () => {
  dropArea.classList.remove('dragover');
});

dropArea.addEventListener('drop', (e) => {
  e.preventDefault();
  dropArea.classList.remove('dragover');
  for (let file of e.dataTransfer.files) {
    enqueueFile(file.name, `${(file.size / 1024).toFixed(0)} KB`, file.type);
  }
});

// Quick Upload Shortcuts
const radialButtons = document.querySelectorAll('.quick-types button');
radialButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    const type = btn.getAttribute('data-type');
    if (type === 'photo') {
      enqueueFile('Screenshot_2026-06-18.png', '420 KB', 'image/png', 'OCR Text: Invoice amount due $45.00 for online services.');
    } else if (type === 'pdf') {
      enqueueFile('Academic_Transcript.pdf', '3.1 MB', 'application/pdf', 'OCR Text: University Academic Transcript. Course grades: A, A+, B.');
    } else if (type === 'link') {
      enqueueFile('Vite_Documentation.html', '45 KB', 'text/html', 'OCR Text: Vite Dev Server fast configs, React deployment pathways.');
    } else if (type === 'voice') {
      enqueueFile('VoiceRecord_002.wav', '1.8 MB', 'audio/wav', 'OCR Text: Remember to check PAN card expiration details next Friday.');
    }
  });
});

// Interactive AI Second Brain Chat Console
const chatInput = document.getElementById('chat-input');
const chatSend = document.getElementById('chat-send');
const chatMic = document.getElementById('chat-mic');
const chatMessages = document.getElementById('chat-messages');

function appendMessage(text, sender) {
  const msg = document.createElement('div');
  msg.className = `message ${sender}`;
  msg.innerText = text;
  chatMessages.appendChild(msg);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

function handleChatMessage() {
  const query = chatInput.value.trim();
  if (query === '') return;

  appendMessage(query, 'user');
  chatInput.value = '';

  // Trigger Orb animation
  setOrbState('processing');

  setTimeout(() => {
    setOrbState('speaking');
    let response = "I searched your decentralized node database but couldn't find matching parameters. Try asking about certificates, PAN cards, or transcripts.";
    
    const lowerQuery = query.toLowerCase();
    
    if (lowerQuery.includes('bls') || lowerQuery.includes('basic life support')) {
      response = "According to your Education vault, you completed the Basic Life Support (BLS) course. The certificate is stored under 'Basic_Life_Support_Cert.pdf'. Expiry is July 3, 2026.";
    } else if (lowerQuery.includes('cardiac') || lowerQuery.includes('perfusion')) {
      response = "Found 1 clinical record: 'Cardiac_Perfusion_Trainee.pdf' in your Career cluster. It registers your surgical training credits.";
    } else if (lowerQuery.includes('certificate') || lowerQuery.includes('transcripts')) {
      response = "I found 2 certificates in Education: 'Basic_Life_Support_Cert.pdf' and 'Google_Data_Analytics_Cert.pdf' (derived from capture assistant).";
    } else if (lowerQuery.includes('aadhaar') || lowerQuery.includes('identity')) {
      response = "Your identity nodes include 'Aadhaar_Card_Secure.png' with a priority rank of 98/100 (Highly critical). Decrypted locally on verification.";
    }

    appendMessage(response, 'ai');

    setTimeout(() => {
      setOrbState('idle');
    }, 2000);
  }, 1800);
}

chatSend.addEventListener('click', handleChatMessage);
chatInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') handleChatMessage();
});

// Speech-to-text simulation
chatMic.addEventListener('click', () => {
  setOrbState('listening');
  setTimeout(() => {
    chatInput.value = "When did I complete my BLS course?";
    setOrbState('processing');
    setTimeout(() => {
      handleChatMessage();
    }, 1000);
  }, 2500);
});

// Proactive AI Memory Capture Assistant Trigger (Magical screenshot pop)
const captureToast = document.getElementById('capture-assistant-toast');
const toastYes = document.getElementById('toast-yes');
const toastNo = document.getElementById('toast-no');

setTimeout(() => {
  captureToast.classList.remove('hidden');
}, 3000);

toastYes.addEventListener('click', () => {
  captureToast.classList.add('hidden');
  enqueueFile('Google_Data_Analytics_Cert.png', '1.4 MB', 'image/png', 'OCR Text: Google Data Analytics Professional Certificate completed. Score 100%.');
});

toastNo.addEventListener('click', () => {
  captureToast.classList.add('hidden');
});
