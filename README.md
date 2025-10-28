# GZCTF Demo - Docker Compose Management

A Docker Compose management script for GZCTF (Capture The Flag) platform.

> **⚠️ Important**: This is a **demo repository** for learning and testing purposes. For production deployments, please use the official [GZCTF platform](https://github.com/GZTimeWalker/GZCTF) and [gzcli](https://github.com/dimasma0305/gzcli) tools.

## 🚀 Features

- **Docker Compose Management**: Support for both Docker Compose v2 and docker-compose v1
- **Profile Support**: Run all profiles or specific profiles
- **Professional Logging**: Color-coded terminal output with clean logging system
- **Admin Initialization**: Automated user role management for database
- **Service Management**: Complete lifecycle management for containers
- **Error Handling**: Robust error handling with proper exit codes
- **Cross-platform**: Works on Linux, macOS, and Windows (WSL)

## 🏆 What is GZCTF?

[GZCTF](https://github.com/GZTimeWalker/GZCTF) is an open-source Capture The Flag (CTF) platform used by universities and organizations worldwide. It features:

- **Modern Web Interface**: Built with React and ASP.NET Core
- **Challenge Management**: Support for various challenge types (Web, Crypto, Reverse, etc.)
- **Real-time Scoring**: Live scoreboard and team rankings
- **Multi-language Support**: Internationalization support
- **Docker Integration**: Container-based challenge deployment
- **Professional Grade**: Used in major CTF competitions globally

This demo script helps you get started with GZCTF using Docker Compose, but for production deployments, consider using the official tools.

## 📋 Prerequisites

- Docker Engine
- Docker Compose (v1 or v2)
- Bash shell
- PostgreSQL client tools (for database operations)

## 🛠️ Installation

1. Clone this repository:
```bash
git clone <your-repo-url>
cd gzctf-demo
```

2. Make the script executable:
```bash
chmod +x thelol.sh
```

3. Configure your environment (optional):
```bash
# Override project name if needed
export PROJECT_NAME_OVERRIDE=my-gzctf-instance
```

## 📖 Usage

### Basic Commands

```bash
# Show help
./thelol.sh help

# Start all services
./thelol.sh up all

# Start specific profiles
./thelol.sh up api worker

# Stop all services
./thelol.sh down

# View service status
./thelol.sh status

# View logs
./thelol.sh logs -f gzctf
```

### Service Management

```bash
# Restart services
./thelol.sh restart gzctf

# Build images
./thelol.sh build

# Pull latest images
./thelol.sh pull

# Execute command in container
./thelol.sh exec db psql --user postgres -d gzctf

# Open shell in container
./thelol.sh shell gzctf
```

### Database Administration

```bash
# Initialize admin user
./thelol.sh init-admin username

# Example: Make user 'admin' an administrator
./thelol.sh init-admin admin
```

### Maintenance

```bash
# Clean up networks
./thelol.sh prune

# Full cleanup (destructive)
./thelol.sh clean --force

# List available profiles
./thelol.sh profiles

# Show compose files being used
./thelol.sh files
```

## 🏗️ Project Structure

```
gzctf-demo/
├── docker-compose.yml      # Main compose configuration
├── appsettings.json       # Application settings
├── thelol.sh             # Main management script
├── init_admin.sh         # Legacy admin init script
└── README.md             # This file
```

## 🔧 Configuration

### Docker Compose Files

The script automatically detects and uses:
- `docker-compose.yml` (required)
- `docker-compose.override.yml` (optional, if exists)

### Environment Variables

- `PROJECT_NAME_OVERRIDE`: Override the default project name
- `NO_COLOR`: Disable colored output

### Services

- **gzctf**: Main GZCTF application (port 8080)
- **db**: PostgreSQL database
- **cache**: Redis cache

## 🎯 Admin Management

The `init-admin` command provides automated user role management:

### What it does:
1. Verifies database service is running
2. Updates user role to admin in `AspNetUsers` table
3. Verifies the change was successful
4. Provides clear feedback on the operation

### Usage Examples:
```bash
# Make user 'admin' an administrator
./thelol.sh init-admin admin

# Make user 'dimas' an administrator  
./thelol.sh init-admin dimas
```

### Manual Database Access:
```bash
# Connect to database directly
./thelol.sh exec db psql --user postgres -d gzctf

# Check user roles
./thelol.sh exec db psql --user postgres -d gzctf -c "SELECT \"UserName\", \"Role\" FROM \"AspNetUsers\";"
```

## 🚨 Troubleshooting

### Common Issues

**Service not running:**
```bash
# Check service status
./thelol.sh status

# Start services
./thelol.sh up all
```

**Database connection issues:**
```bash
# Check database logs
./thelol.sh logs db

# Restart database
./thelol.sh restart db
```

**Permission issues:**
```bash
# Make script executable
chmod +x thelol.sh

# Run with proper permissions
sudo ./thelol.sh up all
```

### Logs and Debugging

```bash
# View all logs
./thelol.sh logs

# Follow logs in real-time
./thelol.sh logs -f

# View specific service logs
./thelol.sh logs -f gzctf
```

## 🔒 Security Notes

- The `init-admin` command modifies database directly
- Ensure proper database credentials are configured
- Use strong passwords for production environments
- Regularly backup your database

## 🌟 About GZCTF Platform

This demo script is built for the [GZCTF](https://github.com/GZTimeWalker/GZCTF) platform, an open-source Capture The Flag (CTF) platform.

### Official Resources

- **🏆 GZCTF Platform**: [https://github.com/GZTimeWalker/GZCTF](https://github.com/GZTimeWalker/GZCTF)
  - Official open-source CTF platform
  - Full-featured with web interface, challenge management, and scoring system
  - Used by universities and organizations worldwide
  - Licensed under AGPL-3.0

- **🛠️ gzcli**: [https://github.com/dimasma0305/gzcli](https://github.com/dimasma0305/gzcli)
  - **Highly recommended for production deployments**
  - Command-line interface for GZCTF management
  - Advanced deployment and configuration tools
  - Professional-grade automation and scripting

### Getting Started with Official Tools

1. **For Production CTF Events**:
   ```bash
   # Clone official GZCTF platform
   git clone https://github.com/GZTimeWalker/GZCTF.git
   
   # Use gzcli for deployment
   git clone https://github.com/dimasma0305/gzcli.git
   ```

2. **For Learning/Testing**:
   - Use this demo repository
   - Experiment with Docker Compose management
   - Learn GZCTF basics before production deployment

## 📝 License

This demo project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Note**: The GZCTF platform itself is licensed under AGPL-3.0. Please refer to the [official repository](https://github.com/GZTimeWalker/GZCTF) for licensing details.

## 🆘 Support

For issues and questions:
- **Demo Script Issues**: Create an issue in this repository
- **GZCTF Platform Issues**: Visit [official GZCTF repository](https://github.com/GZTimeWalker/GZCTF)
- **Production Deployment**: Check [gzcli documentation](https://github.com/dimasma0305/gzcli)
- **General CTF Questions**: Check the troubleshooting section above

*This demo script is not affiliated with the official GZCTF project. Use official tools for production deployments.*
