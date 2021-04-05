output "tls_private_key" {
  value       = tls_private_key.leszek_ssh.private_key_pem
  description = "TLS private key"
}