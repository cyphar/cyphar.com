#!/bin/bash
# Copyright (C) 2022 Aleksa Sarai <cyphar@cyphar.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -Eeuxo pipefail

KEYSIZE="${KEYSIZE:-4096}"
KEY="${KEY:-rsa:$KEYSIZE}"

function bail() {
	echo "[!]" "$@" >&2
	exit 1
}

[ -d root ] && bail "Refusing to destroy existing CA directory root."

rm -rf root
mkdir -p root/{{new,}certsdb,private,crl,certreqs}
touch root/index.txt

cat >root/openssl.conf <<EOF
[ ca ]
default_ca = CA_rootca_dot_cyphar_com

[ CA_rootca_dot_cyphar_com ]
dir               = .
certs             = \$dir/certsdb
new_certs_dir     = \$dir/newcertsdb
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/rootca-dot.cyphar.com.key
certificate       = \$dir/rootca-dot.cyphar.com.crt

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crldir            = \$dir/crl
crl               = \$crldir/rootca-crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# Copy any requested extensions (which are safe).
copy_extensions = copy

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 3650
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of "man ca".
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the "req" tool ("man req").
default_bits        = $KEYSIZE
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See .
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = AU
stateOrProvinceName_default     = NSW
localityName_default            =
0.organizationName_default      = dot.cyphar.com
organizationalUnitName_default  =
emailAddress_default            = webmaster@cyphar.com

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
nameConstraints=critical,permitted;DNS:.dot.cyphar.com,permitted;IP:10.42.0.0/255.255.0.0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
subjectAltName = email:copy
crlDistributionPoints = URI:https://static.cyphar.com/ca/rootca-dot.cyphar.com.crl

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
nameConstraints=critical,permitted;DNS:.dot.cyphar.com,permitted;IP:10.42.0.0/255.255.0.0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
subjectAltName = email:copy
crlDistributionPoints = URI:https://static.cyphar.com/ca/rootca-dot.cyphar.com.crl

[ server_cert ]
################################################################################
# NOTE: We only include this profile for the root CA because some applicances  #
#       (notably my Cisco switch) do not support intermediate CAs and CA       #
#       bundles *at all* (meaning that the whole idea of using it properly is  #
#       impossible). As such, we need to sign said certificate with the root   #
#       CA. Such is life.                                                      #
################################################################################
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "INTERNAL dot.cyphar.com Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
crlDistributionPoints = URI:https://static.cyphar.com/ca/rootca-dot.cyphar.com.crl

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
EOF

pushd root/

openssl req -config ./openssl.conf \
	-subj "/C=AU/ST=NSW/O=dot.cyphar.com/CN=INTERNAL dot.cyphar.com Root CA/emailAddress=webmaster@cyphar.com" \
	-new -newkey "$KEY" -keyout private/rootca-dot.cyphar.com.key -out certreqs/rootca-dot.cyphar.com.req

openssl ca -config ./openssl.conf \
	-rand_serial -out rootca-dot.cyphar.com.crt -days 10981 -selfsign -extensions v3_ca -infiles certreqs/rootca-dot.cyphar.com.req

# For some reason, while we are recommended to use -rand_serial, there is no
# equivalent for crlnumber (which is the serial for the CRL).
echo 1000 > crlnumber
# Generate a CRL immediately.
openssl ca -config ./openssl.conf -gencrl -out "crl/rootca-crl.pem"
