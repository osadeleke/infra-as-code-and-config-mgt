# Infrastructure as Code & Configuration Management

This repository contains Infrastructure as Code (IaC) and Configuration Management implementations.

## Repository Structure

The repository is configured to ignore the following files and directories:

- `.terraform/` - Terraform provider/module directory
- `inventory` - Ansible inventory files

## Prerequisites

- Terraform installed
- AWS CLI configured
- Ansible installed (for configuration management)

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/osadeleke/infra-as-code-and-config-mgt.git
```

2. Initialize Terraform:

```bash
terraform init
```

3. Review and plan infrastructure changes:

```bash
terraform plan
```

4. Apply infrastructure changes:

```bash
terraform apply
```

## Best Practices

- Keep sensitive information in `.env` files (which are gitignored)
- Use remote state storage for Terraform state files
- Version control your infrastructure code
- Document all major changes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License
