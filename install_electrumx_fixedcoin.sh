#!/bin/bash
################################################################################
# ElectrumX Installation Script for FixedCoin
# Ubuntu 22.04 / Debian 11-12
# Version: 1.0.4 - Production Ready
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
ELECTRUMX_USER="electrumx"
ELECTRUMX_DIR="/var/electrum"
ELECTRUMX_DB_DIR="${ELECTRUMX_DIR}/db"
ELECTRUMX_LOG_DIR="${ELECTRUMX_DIR}/logs"
ELECTRUMX_SSL_DIR="${ELECTRUMX_DIR}/ssl"
ELECTRUMX_VENV="/home/electrumx/electrumx-venv"
FIXEDCOIN_RPC_USER="rpcuser"
FIXEDCOIN_RPC_PASS="rpcpassword"
FIXEDCOIN_RPC_PORT="24761"
FIXEDCOIN_DATADIR="/var/fixedcoin/data"
FIXEDCOIN_CLI="/var/fixedcoin/bin/fixedcoin-cli"
LETSENCRYPT_SUCCESS=false

print_header() {
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║      ElectrumX Installation for FixedCoin                   ║"
    echo "║      Ubuntu 22.04 / Debian 11-12                            ║"
    echo "║      Version 1.0.4 - With Python Virtual Environment        ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_system() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect operating system"
        exit 1
    fi
    
    source /etc/os-release
    
    # Support Ubuntu 22.04 AND Debian 11/12
    if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "22.04" ]]; then
        print_success "System detected: Ubuntu $VERSION_ID"
    elif [[ "$ID" == "debian" && ("$VERSION_ID" == "11" || "$VERSION_ID" == "12") ]]; then
        print_success "System detected: Debian GNU/Linux $VERSION_ID"
    else
        print_warning "This script is designed for Ubuntu 22.04 or Debian 11/12"
        print_warning "Your system: $ID $VERSION_ID"
        read -p "Do you want to continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

get_fixedcoin_config() {
    print_header
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║      FixedCoin Configuration                                ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    read -p "Path to fixedcoin-cli [$FIXEDCOIN_CLI]: " input
    FIXEDCOIN_CLI="${input:-$FIXEDCOIN_CLI}"
    
    read -p "FixedCoin data directory [$FIXEDCOIN_DATADIR]: " input
    FIXEDCOIN_DATADIR="${input:-$FIXEDCOIN_DATADIR}"
    
    read -p "RPC Username [$FIXEDCOIN_RPC_USER]: " input
    FIXEDCOIN_RPC_USER="${input:-$FIXEDCOIN_RPC_USER}"
    
    read -sp "RPC Password [$FIXEDCOIN_RPC_PASS]: " input
    echo ""
    FIXEDCOIN_RPC_PASS="${input:-$FIXEDCOIN_RPC_PASS}"
    
    read -p "RPC Port [$FIXEDCOIN_RPC_PORT]: " input
    FIXEDCOIN_RPC_PORT="${input:-$FIXEDCOIN_RPC_PORT}"
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║      Configuration Summary                                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo "FixedCoin CLI: $FIXEDCOIN_CLI"
    echo "Data Directory: $FIXEDCOIN_DATADIR"
    echo "RPC User: $FIXEDCOIN_RPC_USER"
    echo "RPC Password: ********"
    echo "RPC Port: $FIXEDCOIN_RPC_PORT"
    echo ""
    
    read -p "Is this configuration correct? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Configuration cancelled"
        exit 1
    fi
}

check_fixedcoin() {
    print_status "Checking FixedCoin node..."
    
    if [[ ! -f "$FIXEDCOIN_CLI" ]]; then
        print_error "fixedcoin-cli not found at $FIXEDCOIN_CLI"
        print_error "FixedCoin must be installed before ElectrumX"
        exit 1
    fi
    
    if ! $FIXEDCOIN_CLI -datadir=$FIXEDCOIN_DATADIR getblockchaininfo &>/dev/null; then
        print_error "Cannot connect to FixedCoin node"
        print_error "Make sure FixedCoin is running"
        exit 1
    fi
    
    print_success "FixedCoin node accessible"
    
    # Check txindex
    local indexinfo=$($FIXEDCOIN_CLI -datadir=$FIXEDCOIN_DATADIR getindexinfo 2>/dev/null || echo "")
    
    if [[ -z "$indexinfo" ]] || ! echo "$indexinfo" | grep -q "txindex"; then
        print_error "txindex is not enabled in FixedCoin"
        print_error "Add 'txindex=1' to fixedcoin.conf and restart with -reindex"
        exit 1
    fi
    
    if ! echo "$indexinfo" | grep -q '"synced": true'; then
        print_warning "txindex is currently syncing..."
        print_warning "Installation can continue but ElectrumX won't start until sync completes"
    else
        print_success "txindex enabled"
    fi
    
    # Display block height
    local blocks=$($FIXEDCOIN_CLI -datadir=$FIXEDCOIN_DATADIR getblockcount 2>/dev/null || echo "unknown")
    print_success "Blockchain synced: $blocks blocks"
}

install_dependencies() {
    print_status "Installing system dependencies..."
    
    export DEBIAN_FRONTEND=noninteractive
    
    apt-get update -qq 2>&1 | grep -v "^W:" || true
    
    apt-get install -y \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        build-essential \
        git \
        libssl-dev \
        libleveldb-dev \
        librocksdb-dev \
        pkg-config \
        liblz4-dev \
        libsnappy-dev \
        zlib1g-dev \
        libbz2-dev \
        net-tools \
        netcat-openbsd \
        curl \
        wget \
        ufw \
        2>&1 | grep -v "^W:" || true
    
    print_success "Dependencies installed"
}

create_user() {
    print_status "Creating user $ELECTRUMX_USER..."
    
    if id -u $ELECTRUMX_USER &>/dev/null; then
        print_warning "User already exists"
    else
        useradd -r -m -s /bin/bash $ELECTRUMX_USER
        print_success "User created"
    fi
}

create_directories() {
    print_status "Creating directories..."
    
    mkdir -p $ELECTRUMX_DIR
    mkdir -p $ELECTRUMX_DB_DIR
    mkdir -p $ELECTRUMX_LOG_DIR
    mkdir -p $ELECTRUMX_SSL_DIR
    
    chown -R $ELECTRUMX_USER:$ELECTRUMX_USER $ELECTRUMX_DIR
    
    print_success "Directories created"
}

install_electrumx() {
    print_status "Installing ElectrumX with Python virtual environment..."
    
    # Clone repo in user's home
    if [[ ! -d /home/$ELECTRUMX_USER/electrumx-source ]]; then
        sudo -u $ELECTRUMX_USER git clone https://github.com/spesmilo/electrumx.git /home/$ELECTRUMX_USER/electrumx-source
    else
        cd /home/$ELECTRUMX_USER/electrumx-source
        sudo -u $ELECTRUMX_USER git fetch --all
    fi
    
    # Use stable version 1.16.0
    cd /home/$ELECTRUMX_USER/electrumx-source
    sudo -u $ELECTRUMX_USER git checkout 1.16.0
    
    print_success "Source code downloaded (version 1.16.0)"
    
    # Create Python virtual environment (SOLUTION for Debian 12)
    print_status "Creating Python virtual environment..."
    sudo -u $ELECTRUMX_USER python3 -m venv "$ELECTRUMX_VENV"
    print_success "Virtual environment created: $ELECTRUMX_VENV"
    
    # Install packages in virtual environment
    print_status "Installing Python packages in virtual environment..."
    
    sudo -u $ELECTRUMX_USER bash -c "
        source $ELECTRUMX_VENV/bin/activate
        pip install --upgrade pip setuptools wheel
        cd /home/$ELECTRUMX_USER/electrumx-source
        pip install -e .
    "
    
    print_success "ElectrumX installed in virtual environment"
    
    # Verify installation
    if [[ -f "$ELECTRUMX_VENV/bin/electrumx_server" ]]; then
        print_success "Binary electrumx_server found: $ELECTRUMX_VENV/bin/electrumx_server"
    else
        print_error "Binary electrumx_server not found after installation"
        exit 1
    fi
}

ask_ssl_configuration() {
    print_header
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║      SSL Configuration                                      ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Do you want to configure a Let's Encrypt SSL certificate?"
    echo "  [1] Yes - Let's Encrypt certificate (public server with domain)"
    echo "  [2] No - Self-signed certificate (local testing)"
    echo ""
    
    read -p "Your choice [1/2]: " ssl_choice
    
    if [[ "$ssl_choice" == "1" ]]; then
        USE_LETSENCRYPT=true
        read -p "Domain name (e.g., electrumx.yourdomain.com): " SSL_DOMAIN
        read -p "Email for Let's Encrypt: " SSL_EMAIL
        
        echo ""
        echo "SSL Configuration:"
        echo "  Domain: $SSL_DOMAIN"
        echo "  Email: $SSL_EMAIL"
        echo ""
        read -p "Is this information correct? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "SSL configuration cancelled"
            exit 1
        fi
    else
        USE_LETSENCRYPT=false
    fi
}

generate_ssl_certificate() {
    print_status "Generating self-signed SSL certificate..."
    
    openssl req -newkey rsa:2048 -sha256 -nodes \
        -keyout ${ELECTRUMX_SSL_DIR}/server.key \
        -x509 -days 3650 \
        -out ${ELECTRUMX_SSL_DIR}/server.crt \
        -subj "/C=US/ST=State/L=City/O=ElectrumX/CN=localhost" \
        2>/dev/null
    
    chown $ELECTRUMX_USER:$ELECTRUMX_USER ${ELECTRUMX_SSL_DIR}/*
    chmod 644 ${ELECTRUMX_SSL_DIR}/server.crt
    chmod 600 ${ELECTRUMX_SSL_DIR}/server.key
    
    print_success "Self-signed SSL certificate created"
}

setup_letsencrypt_ssl() {
    print_status "Setting up Let's Encrypt for $SSL_DOMAIN..."
    
    # Install nginx and certbot
    apt-get install -y nginx certbot python3-certbot-nginx &>/dev/null
    
    # Clean default nginx config
    rm -f /etc/nginx/sites-enabled/default
    
    # Minimal nginx configuration for Let's Encrypt
    mkdir -p /var/www/electrumx-fixedcoin
    
    cat > /etc/nginx/sites-available/electrumx << NGINX_CONFIG
server {
    listen 80;
    server_name ${SSL_DOMAIN};
    root /var/www/electrumx-fixedcoin;
    
    location /.well-known/acme-challenge/ {
        allow all;
    }
    
    location / {
        return 200 "ElectrumX FixedCoin Server\nSSL: ${SSL_DOMAIN}:50002\n";
        add_header Content-Type text/plain;
    }
}
NGINX_CONFIG
    
    ln -sf /etc/nginx/sites-available/electrumx /etc/nginx/sites-enabled/
    
    # Test and reload nginx
    if nginx -t &>/dev/null; then
        systemctl reload nginx
        print_success "Nginx configured"
    else
        print_error "Nginx configuration error"
        LETSENCRYPT_SUCCESS=false
        return 1
    fi
    
    # Obtain certificate
    print_status "Obtaining Let's Encrypt certificate..."
    if certbot certonly --nginx -d "$SSL_DOMAIN" \
        --email "$SSL_EMAIL" \
        --agree-tos \
        --non-interactive \
        --no-eff-email; then
        
        # Copy certificates for ElectrumX
        cp "/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem" "${ELECTRUMX_SSL_DIR}/server.crt"
        cp "/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem" "${ELECTRUMX_SSL_DIR}/server.key"
        chown $ELECTRUMX_USER:$ELECTRUMX_USER ${ELECTRUMX_SSL_DIR}/*
        chmod 644 ${ELECTRUMX_SSL_DIR}/server.crt
        chmod 600 ${ELECTRUMX_SSL_DIR}/server.key
        
        # Renewal hook
        mkdir -p /etc/letsencrypt/renewal-hooks/deploy
        cat > /etc/letsencrypt/renewal-hooks/deploy/electrumx.sh << HOOK
#!/bin/bash
cp "/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem" "${ELECTRUMX_SSL_DIR}/server.crt"
cp "/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem" "${ELECTRUMX_SSL_DIR}/server.key"
chown electrumx:electrumx ${ELECTRUMX_SSL_DIR}/*
systemctl restart electrumx
logger "SSL renewed for ElectrumX"
HOOK
        chmod +x /etc/letsencrypt/renewal-hooks/deploy/electrumx.sh
        
        LETSENCRYPT_SUCCESS=true
        print_success "Let's Encrypt certificate obtained and configured"
    else
        print_error "Failed to obtain Let's Encrypt certificate"
        print_warning "Using self-signed certificate instead"
        generate_ssl_certificate
        LETSENCRYPT_SUCCESS=false
    fi
}

add_fixedcoin_to_coins() {
    print_status "Adding FixedCoin class to coins.py..."
    
    # Version 1.16.0 uses old path
    local coins_file="/home/$ELECTRUMX_USER/electrumx-source/electrumx/lib/coins.py"
    
    if [[ ! -f "$coins_file" ]]; then
        print_error "File coins.py not found at $coins_file"
        exit 1
    fi
    
    print_status "File found: $coins_file"
    
    # Check if FixedCoin already exists
    if grep -q "class FixedCoin" "$coins_file"; then
        print_warning "FixedCoin already exists in coins.py"
        return 0
    fi
    
    # Backup original file
    local backup_file="$coins_file.backup-$(date +%s)"
    cp "$coins_file" "$backup_file"
    print_status "Backup created: $backup_file"
    
    # Use Python to add FixedCoin class
    sudo -u $ELECTRUMX_USER python3 << 'PYTHON_SCRIPT'
import re

coins_file = "/home/electrumx/electrumx-source/electrumx/lib/coins.py"

# Read file
with open(coins_file, 'r') as f:
    content = f.read()

# Define FixedCoin class
fixedcoin_class = '''

class FixedCoin(Bitcoin):
    """FixedCoin - Bitcoin v25 fork with custom addresses.
    
    FixedCoin uses inverted prefixes compared to standard Bitcoin:
    - P2PKH: 0x01 (decimal 1) -> Addresses start with "Q"
    - P2SH:  0x00 (decimal 0) -> Addresses start with "1"
    
    Source: FixedCoin chainparams.cpp
    base58Prefixes[PUBKEY_ADDRESS] = std::vector<unsigned char>(1,1);
    base58Prefixes[SCRIPT_ADDRESS] = std::vector<unsigned char>(1,0);
    """
    NAME = "FixedCoin"
    SHORTNAME = "FXD"
    NET = "mainnet"
    
    # Blockchain parameters
    GENESIS_HASH = ('000008e19a0f9124269e897bdcff8ef981fa2d563431df80ca27bc4a1373efd6')
    
    # Network parameters - same as Bitcoin v25
    P2PKH_VERBYTE = bytes.fromhex("01")      # Decimal 1 -> Addresses "Q..."
    P2SH_VERBYTES = [bytes.fromhex("00")]    # Decimal 0 -> Addresses "1..."
    WIF_BYTE = bytes.fromhex("80")           # Standard Bitcoin (128)
    
    # BIP32 - Standard Bitcoin
    XPUB_VERBYTES = bytes.fromhex("0488B21E")
    XPRV_VERBYTES = bytes.fromhex("0488ADE4")
    
    # Default ports
    RPC_PORT = 24761
    
    # Peer discovery
    PEERS = [
        "electrumx.fixedcoin.org s50002"
    ]
    
    @classmethod
    def header_hash(cls, header):
        """Return block header hash - same as Bitcoin."""
        return double_sha256(header)

'''

# Find position after Bitcoin class
bitcoin_match = re.search(r'(\nclass Bitcoin\([^)]+\):.*?)(?=\nclass |\Z)', content, re.DOTALL)

if bitcoin_match:
    # Insert after Bitcoin class
    insert_pos = bitcoin_match.end()
    content = content[:insert_pos] + fixedcoin_class + content[insert_pos:]
else:
    # If Bitcoin not found, add at end
    content += fixedcoin_class

# Write file
with open(coins_file, 'w') as f:
    f.write(content)

print("FixedCoin class added successfully")
PYTHON_SCRIPT
    
    # Verify class was added
    if grep -q "class FixedCoin" "$coins_file"; then
        print_success "FixedCoin class added to coins.py"
    else
        print_error "Failed to add FixedCoin class"
        print_error "You can restore original file: cp $backup_file $coins_file"
        exit 1
    fi
}

create_config() {
    print_status "Creating ElectrumX configuration..."
    
    cat > ${ELECTRUMX_DIR}/electrumx.conf << EOF
# ElectrumX Configuration for FixedCoin
COIN=FixedCoin
NET=mainnet

# Connection to FixedCoin node
DAEMON_URL=http://${FIXEDCOIN_RPC_USER}:${FIXEDCOIN_RPC_PASS}@127.0.0.1:${FIXEDCOIN_RPC_PORT}/

# Database
DB_DIRECTORY=${ELECTRUMX_DB_DIR}
DB_ENGINE=leveldb

# Network
SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://127.0.0.1:8000
SSL_CERTFILE=${ELECTRUMX_SSL_DIR}/server.crt
SSL_KEYFILE=${ELECTRUMX_SSL_DIR}/server.key

# Banner
BANNER_FILE=${ELECTRUMX_DIR}/banner.txt

# Performance
CACHE_MB=2000
MAX_SESSIONS=1000
MAX_RECV=2000000
MAX_SEND=2000000

# Logging
LOG_LEVEL=info

# Peer discovery - FixedCoin network only
PEER_DISCOVERY=self
PEER_ANNOUNCE=

# Report services (optional - customize for your domain)
# REPORT_SERVICES=ssl://your-domain.com:50002,wss://your-domain.com:50004
EOF
    
    chown $ELECTRUMX_USER:$ELECTRUMX_USER ${ELECTRUMX_DIR}/electrumx.conf
    
    print_success "Configuration created"
}

create_banner() {
    cat > ${ELECTRUMX_DIR}/banner.txt << 'EOF'
═══════════════════════════════════════════════════════════════
  ElectrumX Server for FixedCoin
  
  FixedCoin - Fixed supply of 10,000 coins
  Bitcoin v25 fork with custom addresses
  
  This server provides fast access to the FixedCoin blockchain
  for Electrum wallets.
═══════════════════════════════════════════════════════════════
EOF
    
    chown $ELECTRUMX_USER:$ELECTRUMX_USER ${ELECTRUMX_DIR}/banner.txt
}

create_systemd_service() {
    print_status "Creating systemd service..."
    
    cat > /etc/systemd/system/electrumx.service << EOF
[Unit]
Description=ElectrumX Server for FixedCoin
After=network.target
Wants=network.target

[Service]
Type=simple
User=$ELECTRUMX_USER
Group=$ELECTRUMX_USER
WorkingDirectory=$ELECTRUMX_DIR
EnvironmentFile=$ELECTRUMX_DIR/electrumx.conf

# Use binary in virtual environment
ExecStart=$ELECTRUMX_VENV/bin/electrumx_server

Restart=always
RestartSec=30
TimeoutStartSec=600
TimeoutStopSec=1800
StandardOutput=journal
StandardError=journal
KillMode=mixed
KillSignal=SIGTERM

# Security
NoNewPrivileges=true
PrivateTmp=true
ReadWritePaths=$ELECTRUMX_DIR

# Limits
LimitNOFILE=16384
MemoryMax=8G
CPUQuota=400%

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable electrumx
    
    print_success "Systemd service created and enabled"
}

configure_firewall() {
    print_status "Configuring firewall..."
    
    if command -v ufw &>/dev/null; then
        ufw allow 50001/tcp comment "ElectrumX TCP" &>/dev/null || true
        ufw allow 50002/tcp comment "ElectrumX SSL" &>/dev/null || true
        ufw allow 50004/tcp comment "ElectrumX WSS" &>/dev/null || true
        print_success "Firewall configured (UFW)"
    else
        print_warning "UFW not installed, firewall not configured"
    fi
}

create_logrotate() {
    print_status "Configuring log rotation..."
    
    cat > /etc/logrotate.d/electrumx << 'EOF'
/var/electrum/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 electrumx electrumx
    sharedscripts
    postrotate
        systemctl reload electrumx > /dev/null 2>&1 || true
    endscript
}
EOF
    
    print_success "Log rotation configured"
}

create_monitoring() {
    print_status "Configuring monitoring..."
    
    cat > /usr/local/bin/electrumx-monitor << 'EOF'
#!/bin/bash
if ! systemctl is-active --quiet electrumx; then
    systemctl start electrumx
    logger "ElectrumX automatically restarted"
fi
EOF
    
    chmod +x /usr/local/bin/electrumx-monitor
    
    echo "*/15 * * * * root /usr/local/bin/electrumx-monitor" > /etc/cron.d/electrumx-monitor
    
    print_success "Monitoring configured (check every 15 minutes)"
}

start_service() {
    print_status "Starting ElectrumX service..."
    
    systemctl start electrumx
    sleep 5
    
    if systemctl is-active --quiet electrumx; then
        print_success "ElectrumX started successfully!"
    else
        print_error "Service did not start"
        print_error "Check logs: journalctl -u electrumx -n 50"
        return 1
    fi
}

show_summary() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║   ✓ Installation Complete!                                 ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}ElectrumX is now running!${NC}"
    echo ""
    
    if [[ "$USE_LETSENCRYPT" == "true" && "$LETSENCRYPT_SUCCESS" == "true" ]]; then
        echo "🌐 Domain configured:"
        echo "  • ${SSL_DOMAIN}:50002 (SSL Let's Encrypt)"
        echo ""
        echo "🔗 Connect from wallet:"
        echo "  electrum --server ${SSL_DOMAIN}:50002:s"
        echo ""
    else
        echo "📊 Listening ports:"
        echo "  • TCP: 50001"
        echo "  • SSL: 50002 (self-signed certificate)"
        echo "  • WSS: 50004"
        echo ""
        if [[ "$USE_LETSENCRYPT" == "true" && "$LETSENCRYPT_SUCCESS" != "true" ]]; then
            echo -e "${YELLOW}⚠️  Let's Encrypt failed${NC}"
            echo "  Check your DNS and run: ./setup_letsencrypt.sh"
            echo ""
        fi
    fi
    
    echo "📁 Directories:"
    echo "  • Configuration: $ELECTRUMX_DIR/electrumx.conf"
    echo "  • Database: $ELECTRUMX_DB_DIR"
    echo "  • Logs: $ELECTRUMX_LOG_DIR"
    echo "  • SSL: $ELECTRUMX_SSL_DIR"
    echo "  • Python venv: $ELECTRUMX_VENV"
    echo ""
    echo "🔧 Useful commands:"
    echo "  • Status: systemctl status electrumx"
    echo "  • Logs: journalctl -u electrumx -f"
    echo "  • Restart: systemctl restart electrumx"
    echo ""
    echo "⚠️  Initial indexing may take several hours..."
    echo "    Monitor progress: journalctl -u electrumx -f | grep height"
    echo ""
    
    if [[ "$LETSENCRYPT_SUCCESS" == "true" ]]; then
        echo "🔐 SSL Certificate:"
        echo "    Let's Encrypt configured for ${SSL_DOMAIN}"
        echo "    Auto-renewal enabled (every 90 days)"
        echo "    Nginx listening on port 80 for renewal"
        echo ""
    fi
}

main() {
    print_header
    
    check_root
    check_system
    get_fixedcoin_config
    check_fixedcoin
    ask_ssl_configuration
    
    install_dependencies
    create_user
    create_directories
    install_electrumx
    add_fixedcoin_to_coins
    
    # SSL configuration according to choice
    if [[ "$USE_LETSENCRYPT" == "true" ]]; then
        setup_letsencrypt_ssl
    else
        generate_ssl_certificate
    fi
    
    create_config
    create_banner
    create_systemd_service
    configure_firewall
    create_logrotate
    create_monitoring
    
    if start_service; then
        show_summary
    else
        echo ""
        print_error "Installation completed but service did not start"
        print_error "Check logs: journalctl -u electrumx -n 50"
        exit 1
    fi
}

main "$@"
