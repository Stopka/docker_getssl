# GetSSL docker
Docker implementation of [getssl script](https://github.com/srvrco/getssl). Script just obtains specified certificates with specified andditional SANS using ACME (LetsEncrypt) protocol. This container is made for http challenge.

## Dependencies
Running http server with mounted and exposed acme challenge directory.

## Environment
### ACCOUNT_EMAIL
Set an email address associated with your account
```
ACCOUNT_EMAIL=youremail@domain.tld
```

### DOMAINS
Space separated list of domains. If a domain certificate shoud have additional SANs, you can add them after the main domain separated by comma. For example, following value creates two certificates, one for domains `foo.tld`, `www.foo.tld` and `m.foo.tld` and second for `bar.tld` and `www.bar.tld`
```
DOMAINS=foo.tld,www.foo.tld,m.foo.tld bar.tld,www.bar.tld
```

### RELOAD_CONTAINERS
Space separated list of containers to reload on after certificate renewal.
```
RELOAD_CONTAINERS=container1 container2
```

## Volumes
### /root/.getssl
Directory must be writable. Here the script is storing all configuration data

### /root/ssl
Directory must be writable. This is the output direcotry, where all certificates are exported in following structure:
* _some.domain.name_
  * `ca.crt` CA certificate chain
  * `domain.crt` Domain certificate
  * `domain.key` Domain private key
  * `domain.pem` Domain bundle of all: key, certificate and CA chain
  * `chain.crt` Domain bundle of certificates: certificate and CA chain
  
### /root/acme-challenge
Directory must be writable.  Here the script saves acme challenge token. A web server should mount this volume (read only is enaugh) and expose data in this directory publicly on url `validated.domain.tld/.well-known/acme-challenge/`

### /var/run/docker.sock
To allow this container reload other containers, you must mount a docker socket here.

## Compose example
```
version: "3.3"
services:
  getssl:
    image: skorpils/getssl:latest
    volumes:
      - getssl-configs:/root/.getssl
      - getssl-certs:/root/ssl
      - getssl-acme:/root/acme-challenge
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - ACCOUNT_EMAIL=${GETSSL_EMAIL}
      # comma separated SANs, space separated certs
      - DOMAINS=${GETSSL_DOMAINS}
      # space separated container names
      - RELOAD_CONTAINERS=${GETSSL_CONTAINERS}
volumes:
  getssl-configs:
  getssl-acme:
  getssl-certs:
```
