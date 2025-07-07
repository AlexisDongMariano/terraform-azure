# Terraform Variables

This project uses the following variables that must be set in a `terraform.tfvars` file or via the command line:

- `host_os`: The host operating system. Default is `linux`.
- `allowed_ip`: The allowed source IP address (in CIDR notation) for the security rule. Example: `"104.157.31.51/32"`

Create a `terraform.tfvars` file in the root of your project with values like:

```
host_os   = "linux"
allowed_ip = "104.157.31.51/32"
```

**Note:** Do not commit your real IP addresses or sensitive values to version control. The `.gitignore` is set up to exclude `terraform.tfvars` by default.
