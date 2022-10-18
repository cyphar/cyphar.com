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

INAME="${1:-i1}"

KEYSIZE="${KEYSIZE:-4096}"
KEY="${KEY:-rsa:$KEYSIZE}"

function bail() {
	echo "[!]" "$@" >&2
	exit 1
}

[ -d "$INAME" ] && bail "Refusing to destroy existing CA directory $INAME."

rm -rf "$INAME"
mkdir -p "$INAME"/{{new,}certsdb,private,crl,certreqs}
touch "$INAME/index.txt"

cat >"$INAME/openssl.conf" <<EOF
[ ca ]
default_ca = CA_${INAME}ca_dot_cyphar_com

[ CA_${INAME}ca_dot_cyphar_com ]
dir               = .
certs             = \$dir/certsdb
new_certs_dir     = \$dir/newcertsdb
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/${INAME}ca-dot.cyphar.com.key
certificate       = \$dir/${INAME}ca-dot.cyphar.com.crt

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crldir            = \$dir/crl
crl               = \$crldir/${INAME}ca-crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# Copy any requested extensions (which are safe).
copy_extensions = copy

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 395
preserve          = no

# Sadly we cannot use match for stateOrProvinceName or organizationName because
# OpenSSL treats utf8 and ascii strings as different even if they are
# byte-identical. So we need to use a relaxed policy.
#   <https://github.com/openssl/openssl/issues/18339>
policy            = policy_relaxed

[ policy_strict ]
# This intermediate CA only signs internal objects.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_relaxed ]
countryName             = optional
stateOrProvinceName     = optional
organizationName        = optional
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
x509_extensions     = server_cert

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

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "INTERNAL dot.cyphar.com Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
crlDistributionPoints = URI:https://static.cyphar.com/ca/${INAME}ca-dot.cyphar.com.crl

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "INTERNAL dot.cyphar.com Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
crlDistributionPoints = URI:https://static.cyphar.com/ca/${INAME}ca-dot.cyphar.com.crl

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
EOF

pushd "$INAME"
# Generate our keys and a CSR for the root to sign.
openssl req -config ./openssl.conf \
	-subj "/C=AU/ST=NSW/O=dot.cyphar.com/CN=INTERNAL dot.cyphar.com Intermediate CA ${INAME}/emailAddress=webmaster@cyphar.com" \
	-new -newkey "$KEY" -keyout "private/${INAME}ca-dot.cyphar.com.key" -out "../root/certreqs/${INAME}ca-dot.cyphar.com.req"

# Sign the CSR.
pushd ../root/
openssl ca -config ./openssl.conf \
	-rand_serial -out "../${INAME}/${INAME}ca-dot.cyphar.com.crt" -days 3681 -extensions v3_intermediate_ca -infiles "certreqs/${INAME}ca-dot.cyphar.com.req"
popd

# For some reason, while we are recommended to use -rand_serial, there is no
# equivalent for crlnumber (which is the serial for the CRL).
echo 1000 > crlnumber
# Generate a CRL immediately.
openssl ca -config ./openssl.conf -gencrl -out "crl/${INAME}ca-crl.pem"
popd

# Double-check the certificate works.
openssl verify -CAfile root/rootca-dot.cyphar.com.crt "${INAME}/${INAME}ca-dot.cyphar.com.crt"
