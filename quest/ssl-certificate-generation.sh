#!/bin/bash

# Check if region is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <region>"
    exit 1
fi

REGION=$1

# Define file paths for certificate and private key
CERTIFICATE_FILE="certificate.crt"
PRIVATE_KEY_FILE="private.key"

# Install OpenSSL
sudo apt update
sudo apt install openssl

# Generate the certificate using OpenSSL
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $PRIVATE_KEY_FILE -out $CERTIFICATE_FILE <<EOF
US
State
City
Organization
.
quest.local
.
EOF

# Check if OpenSSL command was successful
if [ $? -ne 0 ]; then
    echo "Error generating the certificate."
    exit 1
fi

echo "Certificate and private key generated successfully."

# Import the certificate into AWS ACM
IMPORT_OUTPUT=$(aws acm import-certificate --certificate fileb://$CERTIFICATE_FILE \
                                           --private-key fileb://$PRIVATE_KEY_FILE \
                                           --region $REGION)

# Extract the certificate ID from the output
CERTIFICATE_ID=$(echo $IMPORT_OUTPUT | grep -oP '(?<=CertificateArn": ")[^"]*')

# Check if Certificate ID extraction was successful
if [ -z "$CERTIFICATE_ID" ]; then
    echo "Error extracting Certificate ID."
    exit 1
fi

echo "Certificate successfully imported into AWS ACM."

ALB_INGRESS_FILE="alb-ingress.yaml"

echo "Certificate ID: $CERTIFICATE_ID"

sed -i "s|PLACEHOLDER_CERTIFICATE_ARN|$CERTIFICATE_ID|g" $ALB_INGRESS_FILE
