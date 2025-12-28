# GCP Setup for New Machines

After running the main setup script, you can configure Google Cloud Platform access with dev, test, and prod environments.

### Complete GCP Setup Process

#### 1. **Run the Ubuntu setup script** (installs gcloud CLI and other dependencies):

```bash
# For desktop setup (recommended for development machines)
./setup_ubuntu.sh desktop

# For minimal host setup
./setup_ubuntu.sh host

# For guest setup
./setup_ubuntu.sh guest
```

#### 2. **Authenticate with Google Cloud**:

```bash
gcloud auth login
```

**Note**: We use `gcloud auth login` instead of `gcloud init` because:

- `gcloud auth login` only handles authentication
- `gcloud init` is interactive and would try to set up a default configuration
- Your scripted setup creates custom dev/test/prod configurations

#### 3. **Run the GCP configuration script**:

```bash
./install_gcp_configs.sh
```

### What `install_gcp_configs.sh` does

- Verifies gcloud CLI is installed
- Checks authentication status
- Validates project access permissions
- Creates dev, test, and prod configurations
- Sets up project and account for each environment
- Sets dev as the default configuration

### Verification

After setup, you should be able to:

- Switch between environments: `gdev`, `gprod`, `gtest`
- See current config: `gconfig`
- List projects: `gprojects`

### Configuration Files Location

Your gcloud configurations are stored in:

- `~/.config/gcloud/configurations/` - Configuration files
- `~/.config/gcloud/active_config` - Currently active configuration
- `~/.config/gcloud/credentials.db` - Authentication credentials

### Troubleshooting

- **"gcloud CLI is not installed"**: Run `./setup_ubuntu.sh desktop` first
- **"No active authentication"**: Run `gcloud auth login`
- **"No access to project"**: Check your project IDs and permissions
- **"Configuration already exists"**: This is normal, the script handles it gracefully
- **"Environment variables not set"**: Set the GCP\_\*\_PROJECT_ID variables
