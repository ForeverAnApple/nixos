# Moonsnatcher infrastructure

Run from the repository root with AWS profile `nixos-dev` configured:

```sh
nix shell nixpkgs#opentofu nixpkgs#awscli2
tofu -chdir=infra/moonsnatcher init
tofu -chdir=infra/moonsnatcher plan -var-file=local.tfvars
tofu -chdir=infra/moonsnatcher apply -var-file=local.tfvars
```

Create ignored `infra/moonsnatcher/local.tfvars` with `ssh_cidr` set to the operator's public IPv4 `/32` and `public_key_path` pointing to their SSH public key. Normal SSH access uses the tailnet on port 22022. Keep `bootstrap_ssh = false`; the security group permits only UDP port 41641 for encrypted Tailscale peer connections.

State stays local and ignored. Back up `terraform.tfstate` securely; losing it breaks resource tracking. The instance rejects termination and its encrypted root volume survives termination. Stop/start preserves the disk and Elastic IP:

```sh
instance_id=$(tofu -chdir=infra/moonsnatcher output -raw instance_id)
aws --profile nixos-dev --region us-west-2 ec2 stop-instances --instance-ids "$instance_id"
aws --profile nixos-dev --region us-west-2 ec2 start-instances --instance-ids "$instance_id"
```

Stopping ends compute charges. Disk and public IPv4 charges continue. For recovery, set `bootstrap_ssh = true`, update `ssh_cidr`, and apply. Public SSH also requires the NixOS firewall to allow its port; normal access uses the tailnet.

The pinned AMI is a private, encrypted NixOS machine image in the same region. Keep its backing snapshot while the image is needed for recovery. Never run two copies with the same Tailscale state simultaneously.

Migration records are kept separately under ignored `.migration/`. Recovery uses the retained private AMI; stop the active instance before starting another copy with the same Tailscale identity.
