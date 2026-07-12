# nginx-azure-vm-with-terraform

This project provisions an Azure Ubuntu virtual machine with Nginx installed using Terraform. It is designed for a demo or learning scenario and uses an existing Azure resource group from the Pluralsight sandbox.

## What this deployment creates

The Terraform configuration provisions:
- An Azure virtual network and subnet
- A public IP address
- A network interface and security group
- An Ubuntu VM with Nginx pre-installed via the bootstrap script
- An output showing the VM public IP address

🔧 Configuration Details

Network Architecture

┌─────────────────────────────────────────┐
│         Azure Resource Group            │
├─────────────────────────────────────────┤
│  Virtual Network (10.0.0.0/16)          │
│  ┌───────────────────────────────────┐  │
│  │ Subnet (10.0.2.0/24)              │  │
│  │ ┌──────────────────────────────┐  │  │
│  │ │  VM: Ubuntu 22.04 LTS        │  │  │
│  │ │  ├─ NIC (Private IP)         │  │  │
│  │ │  └─ Nginx (Port 80)          │  │  │
│  │ └──────────────────────────────┘  │  │
│  │  ↓                                  │  │
│  │  Public IP (Static)                │  │
│  └───────────────────────────────────┘  │
│  NSG: Allow HTTP (80), SSH (22)         │
└─────────────────────────────────────────┘

## Files

Project Structure
.
├── provider.tf              # Azure provider configuration
├── azure_VM.tf              # Main infrastructure resources
├── install_nginx.sh         # Bash script for Nginx installation
├── terraform.tfstate        # Current state (don't commit to git!)
├── terraform_tfstate.backup # State backup file
└── README.md               # This file

## Prerequisites

- Azure CLI installed and authenticated
- Terraform installed
- Access to an Azure subscription/resource group

## Deployment steps

1. Sign in to Azure:
   ```bash
   az login
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. After deployment, open the VM public IP in your browser:
   ```bash
   http://<vm-public-ip>
   ```

## Cleanup

To remove the resources when you are done:

```bash
terraform destroy
```

## Notes

- The current configuration uses an existing resource group name from the sandbox environment.
- The VM uses a hardcoded admin username and password for demo purposes. Update these values before using the configuration in a real environment.
- The NSG allows inbound SSH and HTTP traffic for demonstration purposes.


