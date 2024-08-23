#!/bin/bash

# Define the repository URL
REPO_URL="https://github.com/chinadizi/bunkie06"

# Create a temporary directory to clone the repository
TEMP_DIR=$(mktemp -d)

# Clone the repository into the temporary directory
echo "Cloning the repository from $REPO_URL into a temporary directory..."
git clone $REPO_URL "$TEMP_DIR"

# Copy the contents of the cloned repository to the root of the Codespace
echo "Copying the contents to the root directory..."
cp -rT "$TEMP_DIR" .

# Remove the temporary directory
rm -rf "$TEMP_DIR"

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Prompt for the private key
read -p "Enter your private key: " PRIVATE_KEY

# Update the .env file with the private key
if [ -f .env ]; then
  echo "Updating .env file with the provided private key..."
  sed -i "s|PRIVATE_KEY=\"\"|PRIVATE_KEY=\"$PRIVATE_KEY\"|g" .env
else
  echo "PRIVATE_KEY=\"$PRIVATE_KEY\"" > .env
  echo ".env file created and updated."
fi

# Run the deployment script
echo "Running the deployment script..."
npm run script ./scripts/deploy-6.ts

# Prompt for the contract 1 address for verification
read -p "Enter the Contract 1 address for verification: " CONTRACT_ADDRESS

# Run the contract verification command
echo "Verifying the contract on the Swisstronik network..."
npx hardhat verify --network swisstronik --contract contracts/Hello_swtr.sol:Swisstronik "$CONTRACT_ADDRESS"

# Extract the Contract implementation replacement transaction URL and save it to implementation.txt
IMPLEMENTATION_URL=$(echo "$VERIFY_OUTPUT" | grep -oP '(?<=Transaction URL: ).*')
echo "Contract implementation replacement transaction URL: $IMPLEMENTATION_URL"
echo "$IMPLEMENTATION_URL" > implementation.txt

# Extract the deployed proxy contract address and save it to deployed.txt
DEPLOYED_PROXY_ADDRESS=$(echo "$VERIFY_OUTPUT" | grep -oP '(?<=Deployed proxy contract address: ).*')
echo "Deployed proxy contract address: $DEPLOYED_PROXY_ADDRESS"
echo "$DEPLOYED_PROXY_ADDRESS" > deployed.txt

# Remove the private key from the .env file
echo "Removing the private key from the .env file..."
sed -i 's|PRIVATE_KEY=.*||g' .env

# Final output
echo "👍👍 ALL DONE 👍👍"
echo ""
echo "Credit to AnonID.TOP for laying the groundwork 👏👏"
echo ""
echo "Join my Telegram channel for more updates: T.me/CryptoBunkie"