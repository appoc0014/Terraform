locals {
  secrets = yamldecode(sops_decrypt_file("secrets/secrets.yaml"))
}

inputs = {
  PM_API_TOKEN_ID = local.secrets.PM_API_TOKEN_ID
  PM_API_TOKEN_SECRET = local.secrets.PM_API_TOKEN_SECRET
  SSH_KEY = local.secrets.SSH_KEY
}
