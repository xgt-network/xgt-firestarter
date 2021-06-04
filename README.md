# xgt-firestarter
A tool :for provisioning XGT wallets

## Configuration
The following configuration fields are suggested to be set as environment 
variables.

`XGT_HOST` - Set this to be an XGT node. An example would be "http://node.example.com:8751"
`XGT_CHAIN_ID` - The chain ID on the XGT Node. XGT Mainnet is
4e08b752aff5f66e1339cb8c0a8bca14c4ebb238655875db7dade86349091197, and is
supplied by default. It can be overridden if you are attaching this tap to an
XGT testnet.
`XGT_NAME` - Set this to the wallet address of the tap wallet being used.
`XGT_WIFS` - Set this to be a list of wallet-address:recovery-private-key-wifs.
An example would be
"XGT0000000000000000000000000000000000000000:5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n"

## Run
See start.sh for an example of how to run and configure xgt-firestarter.

A Procfile is supplied for running an xgt-firestarter wallet tap on heroku.

