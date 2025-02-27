#!/bin/bash

COMMAND="$1"
set -e

function generateCerts(){
    echo
        echo "##########################################################"
        echo "##### Generate certificates using cryptogen tool #########"
        echo "##########################################################"
        if [ -d ./crypto-config ]; then
                rm -rf ./crypto-config/*
        fi

    ../bin/cryptogen generate --config=./config/crypto-config.yaml --output ./crypto-config
    echo
}

function generateChannelArtifacts(){

    if [ ! -d ./channel-artifacts ]; then
                mkdir channel-artifacts
    fi

    echo
        echo "#################################################################"
        echo "### Generating channel configuration transaction 'channel.tx' ###"
        echo "#################################################################"
        ../bin/configtxgen -configPath ./config -profile SampleMultiNodeEtcdRaft -outputBlock ./channel-artifacts/orderer.genesis.block -channelID sys-channel

        ../bin/configtxgen -configPath ./config -profile ChannelA -channelID channela -outputCreateChannelTx ./channel-artifacts/channela.tx
        ../bin/configtxgen -configPath ./config -profile ChannelB -channelID channelb -outputCreateChannelTx ./channel-artifacts/channelb.tx
        ../bin/configtxgen -configPath ./config -profile ChannelC -channelID channelc -outputCreateChannelTx ./channel-artifacts/channelc.tx
        ../bin/configtxgen -configPath ./config -profile ChannelD -channelID channeld -outputCreateChannelTx ./channel-artifacts/channeld.tx


    echo
        echo "#################################################################"
        echo "#######    Generating anchor peer update for Org1MSP   ##########"
        echo "#################################################################"
        ../bin/configtxgen -configPath ./config  -profile ChannelA  -channelID channela -asOrg Org1MSP -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors-ChannelA.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelA  -channelID channela -asOrg Org4MSP -outputAnchorPeersUpdate ./channel-artifacts/Org4MSPanchors-ChannelA.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelA  -channelID channela -asOrg Org7MSP -outputAnchorPeersUpdate ./channel-artifacts/Org7MSPanchors-ChannelA.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelB  -channelID channelb -asOrg Org1MSP -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors-ChannelB.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelB  -channelID channelb -asOrg Org2MSP -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors-ChannelB.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelB  -channelID channelb -asOrg Org3MSP -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors-ChannelB.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelC  -channelID channelc -asOrg Org4MSP -outputAnchorPeersUpdate ./channel-artifacts/Org4MSPanchors-ChannelC.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelC  -channelID channelc -asOrg Org5MSP -outputAnchorPeersUpdate ./channel-artifacts/Org5MSPanchors-ChannelC.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelC  -channelID channelc -asOrg Org6MSP -outputAnchorPeersUpdate ./channel-artifacts/Org6MSPanchors-ChannelC.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelD  -channelID channeld -asOrg Org7MSP -outputAnchorPeersUpdate ./channel-artifacts/Org7MSPanchors-ChannelD.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelD  -channelID channeld -asOrg Org8MSP -outputAnchorPeersUpdate ./channel-artifacts/Org8MSPanchors-ChannelD.tx
        ../bin/configtxgen -configPath ./config  -profile ChannelD  -channelID channeld -asOrg Org9MSP -outputAnchorPeersUpdate ./channel-artifacts/Org9MSPanchors-ChannelD.tx

        echo
}

function createChannel() {
  echo
    echo "#################################################################"
    echo "####################    create channela tx   ####################"
    echo "#################################################################"
    export APP_CHANNEL=channela
    export TIMEOUT=30
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    peer channel create -o orderer1.example.com:7050 -c ${APP_CHANNEL} -f "/tmp/channel-artifacts/$APP_CHANNEL.tx" --timeout "${TIMEOUT}s" --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    echo

  echo
    echo "#################################################################"
    echo "#################    create channelb tx   #######################"
    echo "#################################################################"
    export APP_CHANNEL=channelb
    export TIMEOUT=30
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    peer channel create -o orderer1.example.com:7050 -c ${APP_CHANNEL} -f "/tmp/channel-artifacts/$APP_CHANNEL.tx" --timeout "${TIMEOUT}s" --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    echo

  echo
    echo "#################################################################"
    echo "###################    create channelc tx   #####################"
    echo "#################################################################"
    export APP_CHANNEL=channelc
    export CORE_PEER_LOCALMSPID=Org4MSP
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    peer channel create -o orderer1.example.com:7050 -c ${APP_CHANNEL} -f "/tmp/channel-artifacts/$APP_CHANNEL.tx" --timeout "${TIMEOUT}s" --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    echo

  echo
    echo "#################################################################"
    echo "####################    create channeld tx   ####################"
    echo "#################################################################"
    export APP_CHANNEL=channeld
    export CORE_PEER_LOCALMSPID=Org7MSP
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
    peer channel create -o orderer1.example.com:7050 -c ${APP_CHANNEL} -f "/tmp/channel-artifacts/$APP_CHANNEL.tx" --timeout "${TIMEOUT}s" --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    echo

  echo "#######   mv channel tx to /tmp/channel-artifacts   ##########"
    cp * /tmp/channel-artifacts/
    echo
}

function joinChannel() {
  echo
    echo "#################################################################"
    echo "###################    Org1-Org9 join channel   #################"
    echo "#################################################################"
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    peer channel join -b /tmp/channel-artifacts/channela.block

    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
    peer channel join -b /tmp/channel-artifacts/channela.block

    export CORE_PEER_LOCALMSPID="Org7MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
    peer channel join -b /tmp/channel-artifacts/channela.block

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    peer channel join -b /tmp/channel-artifacts/channelb.block

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:8051
    peer channel join -b /tmp/channel-artifacts/channelb.block

    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org3.example.com:9051
    peer channel join -b /tmp/channel-artifacts/channelb.block

    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
    peer channel join -b /tmp/channel-artifacts/channelc.block

    export CORE_PEER_LOCALMSPID="Org5MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org5.example.com:11051
    peer channel join -b /tmp/channel-artifacts/channelc.block

    export CORE_PEER_LOCALMSPID="Org6MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org6.example.com:12051
    peer channel join -b /tmp/channel-artifacts/channelc.block

    export CORE_PEER_LOCALMSPID="Org7MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
    peer channel join -b /tmp/channel-artifacts/channeld.block

    export CORE_PEER_LOCALMSPID="Org8MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/peers/peer0.org8.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/users/Admin@org8.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org8.example.com:14051
    peer channel join -b /tmp/channel-artifacts/channeld.block

    export CORE_PEER_LOCALMSPID="Org9MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/users/Admin@org9.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org9.example.com:15051
    peer channel join -b /tmp/channel-artifacts/channeld.block
    echo
}

function updateAnchors() {
  echo
    echo "#################################################################"
    echo "###############    Org1-Org9 update anchors   ###################"
    echo "#################################################################"
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    peer channel update -o orderer1.example.com:7050 -c channela -f /tmp/channel-artifacts/Org1MSPanchors-ChannelA.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
    peer channel update -o orderer1.example.com:7050 -c channela -f /tmp/channel-artifacts/Org4MSPanchors-ChannelA.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org7MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
    peer channel update -o orderer1.example.com:7050 -c channela -f /tmp/channel-artifacts/Org7MSPanchors-ChannelA.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    peer channel update -o orderer1.example.com:7050 -c channelb -f /tmp/channel-artifacts/Org1MSPanchors-ChannelB.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:8051
    peer channel update -o orderer1.example.com:7050 -c channelb -f /tmp/channel-artifacts/Org2MSPanchors-ChannelB.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org3.example.com:9051
    peer channel update -o orderer1.example.com:7050 -c channelb -f /tmp/channel-artifacts/Org3MSPanchors-ChannelB.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
    peer channel update -o orderer1.example.com:7050 -c channelc -f /tmp/channel-artifacts/Org4MSPanchors-ChannelC.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org5MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org5.example.com:11051
    peer channel update -o orderer1.example.com:7050 -c channelc -f /tmp/channel-artifacts/Org5MSPanchors-ChannelC.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org6MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org6.example.com:12051
    peer channel update -o orderer1.example.com:7050 -c channelc -f /tmp/channel-artifacts/Org6MSPanchors-ChannelC.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org7MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
    peer channel update -o orderer1.example.com:7050 -c channeld -f /tmp/channel-artifacts/Org7MSPanchors-ChannelD.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org8MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/peers/peer0.org8.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/users/Admin@org8.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org8.example.com:14051
    peer channel update -o orderer1.example.com:7050 -c channeld -f /tmp/channel-artifacts/Org8MSPanchors-ChannelD.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    export CORE_PEER_LOCALMSPID="Org9MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/users/Admin@org9.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org9.example.com:15051
    peer channel update -o orderer1.example.com:7050 -c channeld -f /tmp/channel-artifacts/Org9MSPanchors-ChannelD.tx --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    echo
}

function queryChannelInfo() {
  echo
    echo "#################################################################"
    echo "######################   Query channela info   ##################"
    echo "#################################################################"
    discover peers --channel channela --peerTLSCA /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem --userKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/priv_sk --userCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem --MSP Org1MSP --tlsCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt --tlsKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key --server peer0.org1.example.com:7051
    echo
sleep 3
  echo
    echo "#################################################################"
    echo "###################   Query channelb info   #####################"
    echo "#################################################################"
    discover peers --channel channelb --peerTLSCA /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem --userKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/priv_sk --userCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem --MSP Org1MSP --tlsCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt --tlsKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key --server peer0.org1.example.com:7051
    echo
sleep 3
  echo
    echo "#################################################################"
    echo "###################   Query channelc info   #####################"
    echo "#################################################################"
    discover peers --channel channelc --peerTLSCA /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/tlsca/tlsca.org4.example.com-cert.pem --userKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp/keystore/priv_sk --userCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp/signcerts/Admin@org4.example.com-cert.pem --MSP Org4MSP --tlsCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/tls/client.crt --tlsKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/tls/client.key --server peer0.org4.example.com:10051
    echo
sleep 3
  echo
    echo "#################################################################"
    echo "######################   Query channeld info   ##################"
    echo "#################################################################"
    discover peers --channel channeld --peerTLSCA /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/tlsca/tlsca.org7.example.com-cert.pem --userKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp/keystore/priv_sk --userCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp/signcerts/Admin@org7.example.com-cert.pem --MSP Org7MSP --tlsCert /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/tls/client.crt --tlsKey /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/tls/client.key --server peer0.org7.example.com:13051
    echo
sleep 3
}

function packageCC() {
    cd /etc/hyperledger/fabric/chaincodes
    echo
        echo "#################################################################"
        echo "#############  package channela-channeld chaincode ##############"
        echo "#################################################################"
        peer lifecycle chaincode package channela.tar.gz --path ./channelA/ --lang golang --label channela
        peer lifecycle chaincode package channelb.tar.gz --path ./channelB/ --lang golang --label channelb
        peer lifecycle chaincode package channelc.tar.gz --path ./channelC/ --lang golang --label channelc
        peer lifecycle chaincode package channeld.tar.gz --path ./channelD/ --lang golang --label channeld
        echo

}

function installChaincodeD() {
      cd /etc/hyperledger/fabric/chaincodes
      echo
      echo "################################################   install chaincodeD   ################################################"

      echo "#################################################################"
      echo "#######################   install chaincode   ###################"
      echo "#################################################################"
      export CORE_PEER_TLS_ENABLED=true
      export CORE_PEER_LOCALMSPID="Org7MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
      peer lifecycle chaincode install ./channeld.tar.gz

sleep 3

      export CORE_PEER_LOCALMSPID="Org8MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/peers/peer0.org8.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/users/Admin@org8.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org8.example.com:14051
      peer lifecycle chaincode install ./channeld.tar.gz

sleep 3

      export CORE_PEER_LOCALMSPID="Org9MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/users/Admin@org9.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org9.example.com:15051
      peer lifecycle chaincode install ./channeld.tar.gz

      echo
sleep 3

      export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)')

      echo

sleep 3

      echo "#################################################################"
      echo "##########  Org7MSP approve chaincode for channeld   ############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org7MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channeld --name channeld_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "############  Org8MSP approve chaincode for channeld   ##########"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org8MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/peers/peer0.org8.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/users/Admin@org8.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org8.example.com:14051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channeld --name channeld_ledger --version 1.0  --package-id $PACKAGE_ID --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "#########  Org9MSP approve chaincode for channeld   #############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org9MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/users/Admin@org9.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org9.example.com:15051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channeld --name channeld_ledger --version 1.0  --package-id $PACKAGE_ID --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "############### channeld approve org query  #####################"
      echo "#################################################################"
      peer lifecycle chaincode checkcommitreadiness \
      --channelID channeld --name channeld_ledger --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

      echo

sleep 3

      echo "#################################################################"
      echo "############## Submit the chaincodeD to the channeld   ##########"
      echo "#################################################################"
      peer lifecycle chaincode commit -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channeld --name channeld_ledger \
      --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      --peerAddresses peer0.org7.example.com:13051 \
      --peerAddresses peer0.org8.example.com:14051 \
      --peerAddresses peer0.org9.example.com:15051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org8.example.com/peers/peer0.org8.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt

      echo

sleep 3

      echo "#################################################################"
      echo "############### query the chaincodeD commit   ###################"
      echo "#################################################################"
      peer lifecycle chaincode querycommitted \
      --channelID channeld --name channeld_ledger \
      --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "#######################   invoke chaincodeD   ###################"
      echo "#################################################################"
      peer chaincode invoke \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      -C channeld -n channeld_ledger \
      --peerAddresses peer0.org9.example.com:15051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt \
      -c '{"function":"CreateParkingFacility","Args":["test-chaincodeD-org9-ParkingFacility","location","100","12","123.23","ipfs"]}'

      echo

sleep 3
      echo "#################################################################"
      echo "############   QueryParkingFacility chaincoded   ################"
      echo "#################################################################"
      peer chaincode query -C channeld -n channeld_ledger -c '{"Args":["QueryParkingFacility","test-chaincodeD-org9-ParkingFacility"]}'

      echo

sleep 3
      echo "#################################################################"
      echo "############   CreateTrafficCondition chaincoded   ###############"
      echo "#################################################################"
      peer chaincode invoke \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      -C channeld -n channeld_ledger \
      --peerAddresses peer0.org9.example.com:15051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org9.example.com/peers/peer0.org9.example.com/tls/ca.crt \
      -c '{"function":"CreateTrafficCondition","Args":["test-chaincodeD-org9-TrafficCondition","Accident","Low","20251115","sucess","ipfs"]}'

      echo

sleep 3

      echo "#################################################################"
      echo "############   QueryTrafficCondition chaincoded   ###############"
      echo "#################################################################"
      peer chaincode query -C channeld -n channeld_ledger -c '{"Args":["QueryTrafficCondition","test-chaincodeD-org9-TrafficCondition","20251115"]}'

      echo

sleep 3
}

function installChaincodeC() {
      cd /etc/hyperledger/fabric/chaincodes
      echo "################################################   install chaincodeC   ################################################"

      echo "#################################################################"
      echo "###################   install chaincodec   ######################"
      echo "#################################################################"
      export CORE_PEER_TLS_ENABLED=true
      export CORE_PEER_LOCALMSPID="Org4MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
      peer lifecycle chaincode install ./channelc.tar.gz

      echo

sleep 3

      export CORE_PEER_LOCALMSPID="Org5MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org5.example.com:11051
      peer lifecycle chaincode install ./channelc.tar.gz

      echo

sleep 3

      export CORE_PEER_LOCALMSPID="Org6MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org6.example.com:12051
      peer lifecycle chaincode install ./channelc.tar.gz

      echo

sleep 3
      export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)')

      echo

sleep 3

      echo "#################################################################"
      echo "#########  Org4MSP approve chaincode for channelc   #############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org4MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 --ordererTLSHostnameOverride orderer1.example.com --channelID channelc --name channelc_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "##########  Org5MSP approve chaincode for channelC   ############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org5MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org5.example.com:11051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 --ordererTLSHostnameOverride orderer1.example.com --channelID channelc --name channelc_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "##########  Org6MSP approve chaincode for channelc   ############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org6MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org6.example.com:12051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 --ordererTLSHostnameOverride orderer1.example.com --channelID channelc --name channelc_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "################## channelc approve org query  ##################"
      echo "#################################################################"
      peer lifecycle chaincode checkcommitreadiness \
      --channelID channelc --name channelc_ledger --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

      echo

sleep 3

      echo "#################################################################"
      echo "########### Submit the chaincodeC to the channelc   #############"
      echo "#################################################################"
      peer lifecycle chaincode commit -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channelc --name channelc_ledger \
      --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      --peerAddresses peer0.org4.example.com:10051 \
      --peerAddresses peer0.org5.example.com:11051 \
      --peerAddresses peer0.org6.example.com:12051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt

      echo

sleep 3

      echo "#################################################################"
      echo "################## query the chaincodec commit   ################"
      echo "#################################################################"
      peer lifecycle chaincode querycommitted \
      --channelID channelc --name channelc_ledger \
      --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "#######################   invoke chaincodeC   ###################"
      echo "#################################################################"
      peer chaincode invoke \
      -C channelc -n channelc_ledger \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      --peerAddresses peer0.org6.example.com:12051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt \
      -c '{"function":"CreateInsurancePolicy","Args":["test-chaincodeC-org6","this chaincodeC test","owner","provider","coverageType","20241111","20241115","12.54","status","ipfs"]}'

      echo

sleep 3
      echo "#################################################################"
      echo "#############  QueryInsurancePolicy for channelc   ##############"
      echo "#################################################################"
      peer chaincode query -C channelc -n channelc_ledger -c '{"Args":["QueryInsurancePolicy","test-chaincodeC-org6"]}'

      echo

sleep 3
      echo "#################################################################"
      echo "#############  UpdateInsurancePolicy for channelc   #############"
      echo "#################################################################"
      peer chaincode invoke \
      -C channelc -n channelc_ledger \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      --peerAddresses peer0.org6.example.com:12051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt \
      -c '{"function":"UpdateInsurancePolicy","Args":["test-chaincodeC-org6","update","update","provider","coverageType","20241111","20241115","12.54","status","ipfs"]}'

      echo

sleep 3

      echo "#################################################################"
      echo "#############  QueryInsurancePolicy for channelc   ##############"
      echo "#################################################################"
      peer chaincode query -C channelc -n channelc_ledger -c '{"Args":["QueryInsurancePolicy","test-chaincodeC-org6"]}'

      echo

sleep 3
      echo "#################################################################"
      echo "#########  QueryInsurancePolicyHistory for channelc   ###########"
      echo "#################################################################"
      peer chaincode query -C channelc -n channelc_ledger -c '{"Args":["QueryInsurancePolicyHistory","test-chaincodeC-org6"]}'

      echo

sleep 3
}

function installChaincodeB() {
      cd /etc/hyperledger/fabric/chaincodes
      echo "################################################   install chaincodeB   ################################################"

      echo "#################################################################"
      echo "####################   install chaincodeB   #####################"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org1MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      peer lifecycle chaincode install ./channelb.tar.gz

      export CORE_PEER_LOCALMSPID="Org2MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org2.example.com:8051
      peer lifecycle chaincode install ./channelb.tar.gz

      export CORE_PEER_LOCALMSPID="Org3MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org3.example.com:9051
      peer lifecycle chaincode install ./channelb.tar.gz

sleep 3

      export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)')

      echo "#################################################################"
      echo "###########  Org1MSP approve chaincode for channelb   ###########"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org1MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 --ordererTLSHostnameOverride orderer1.example.com --channelID channelb --name channelb_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sleep 3

      echo "#################################################################"
      echo "##########  Org2MSP approve chaincode for channelb   ############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org2MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org2.example.com:8051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 --ordererTLSHostnameOverride orderer1.example.com --channelID channelb --name channelb_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sleep 3

      echo "#################################################################"
      echo "#########  Org3MSP approve chaincode for channelb   #############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org3MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org3.example.com:9051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 --ordererTLSHostnameOverride orderer1.example.com --channelID channelb --name channelb_ledger --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sleep 3

      echo "#################################################################"
      echo "############## channelb approve org query  ######################"
      echo "#################################################################"
      peer lifecycle chaincode checkcommitreadiness \
      --channelID channelb --name channelb_ledger --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

sleep 3
      echo "#################################################################"
      echo "########### Submit the chaincodeB to the channelb   #############"
      echo "#################################################################"
      peer lifecycle chaincode commit  \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channelb --name channelb_ledger \
      --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      --peerAddresses peer0.org1.example.com:7051 \
      --peerAddresses peer0.org2.example.com:8051 \
      --peerAddresses peer0.org3.example.com:9051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

sleep 3

      echo "#################################################################"
      echo "############## query the chaincodeB commit   ####################"
      echo "#################################################################"
      peer lifecycle chaincode querycommitted \
      --channelID channelb --name channelb_ledger \
      --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sleep 3

      echo "#################################################################"
      echo "##################   invoke chaincodeB   ########################"
      echo "#################################################################"
      peer chaincode invoke \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --tls \
      --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      -C channelb \
      -n channelb_ledger \
      --peerAddresses peer0.org1.example.com:7051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
      -c '{"function":"CreateVehicleStatus","Args":["test-chaincodeB-org1","this chaincodeB test","1","2","3","202411150912","ipfs"]}'

sleep 3
      echo "#################################################################"
      echo "#############  QueryVehicleStatus for channelb   ###############"
      echo "#################################################################"
      peer chaincode query -C channelb -n channelb_ledger -c '{"Args":["QueryVehicleStatus","test-chaincodeB-org1"]}'

sleep 3
      echo "#################################################################"
      echo "#############  UpdateVehicleStatus for channelb   ###############"
      echo "#################################################################"
      peer chaincode invoke \
      -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --tls \
      --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      -C channelb \
      -n channelb_ledger \
      --peerAddresses peer0.org1.example.com:7051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
      -c '{"function":"UpdateVehicleStatus","Args":["test-chaincodeB-org1","this chaincodeB test","100","100","100","202411150912","ipfs"]}'

      echo
sleep 3
      echo "#################################################################"
      echo "#############  QueryVehicleStatus for channelb   ################"
      echo "#################################################################"
      peer chaincode query -C channelb -n channelb_ledger -c '{"Args":["QueryVehicleStatus","test-chaincodeB-org1"]}'

      echo
sleep 3
      echo "#################################################################"
      echo "#############  QueryVehicleHistory for channelb   ###############"
      echo "#################################################################"
      peer chaincode query -C channelb -n channelb_ledger -c '{"Args":["QueryVehicleHistory","test-chaincodeB-org1"]}'
      echo
sleep 3
}

function installChaincodeA() {
      cd /etc/hyperledger/fabric/chaincodes
      echo "################################################   install chaincodeA   ################################################"

      echo "#################################################################"
      echo "####################   install chaincodeA   ######################"
      echo "#################################################################"
      export CORE_PEER_TLS_ENABLED=true
      export CORE_PEER_LOCALMSPID="Org1MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      peer lifecycle chaincode install ./channela.tar.gz

sleep 3

      export CORE_PEER_LOCALMSPID="Org4MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
      peer lifecycle chaincode install ./channela.tar.gz

sleep 3

      export CORE_PEER_LOCALMSPID="Org7MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
      peer lifecycle chaincode install ./channela.tar.gz

sleep 3

      export PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[] | select(.label == "channela") | .package_id')

sleep 3

      echo "#################################################################"
      echo "##########  Org1MSP approve chaincode for channela   ############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org1MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channela --name channela_ledger --version 1.0 --package-id $PACKAGE_ID \
      --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "#########  Org4MSP approve chaincode for channela   #############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org4MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channela --name channela_ledger --version 1.0 --package-id $PACKAGE_ID \
      --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "##########  Org7MSP approve chaincode for channela   ############"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org7MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
      peer lifecycle chaincode approveformyorg -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channela --name channela_ledger --version 1.0 --package-id $PACKAGE_ID \
      --sequence 1 --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3

      echo "#################################################################"
      echo "################ channela approve org query  ####################"
      echo "#################################################################"
      peer lifecycle chaincode checkcommitreadiness \
      --channelID channela --name channela_ledger --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

      echo

sleep 3

      echo "#################################################################"
      echo "########### Submit the chaincodeA to the channela   #############"
      echo "#################################################################"
      peer lifecycle chaincode commit -o orderer1.example.com:7050 \
      --ordererTLSHostnameOverride orderer1.example.com \
      --channelID channela --name channela_ledger \
      --version 1.0 --sequence 1 \
      --tls --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
      --peerAddresses peer0.org1.example.com:7051 \
      --peerAddresses peer0.org4.example.com:10051 \
      --peerAddresses peer0.org7.example.com:13051 \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt \
      --tlsRootCertFiles /etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt

      echo

sleep 3

      echo "#################################################################"
      echo "############## query the chaincodeA commit   ####################"
      echo "#################################################################"
      peer lifecycle chaincode querycommitted \
      --channelID channela --name channela_ledger \
      --cafile /etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      echo

sleep 3
      echo "#################################################################"
      echo "################   UnifiedQuery for  channelb  ##################"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org1MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      peer chaincode query -C channela -n channela_ledger -c '{"Args":["UnifiedQuery","channelb","VehicleStatus","test-chaincodeB-org1",""]}'

      echo

sleep 3

      echo "#################################################################"
      echo "################   UnifiedQuery for  channelc  ##################"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org4MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org4.example.com:10051
      peer chaincode query -C channela -n channela_ledger -c '{"Args":["UnifiedQuery","channelc","InsurancePolicy","test-chaincodeC-org6",""]}'

      echo

sleep 3
      echo "#################################################################"
      echo "################   UnifiedQuery for  channeld  ##################"
      echo "#################################################################"
      export CORE_PEER_LOCALMSPID="Org7MSP"
      export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp
      export CORE_PEER_ADDRESS=peer0.org7.example.com:13051
      peer chaincode query -C channela -n channela_ledger -c '{"Args":["UnifiedQuery","channeld","TrafficCondition","test-chaincodeD-org9-TrafficCondition","20251115"]}'

      echo

      peer chaincode query -C channela -n channela_ledger -c '{"Args":["UnifiedQuery","channeld","ParkingFacility","test-chaincodeD-org9-ParkingFacility",""]}'

      echo

sleep 3
}

function up() {
  echo
    echo "#################################################################"
    echo "##############    create docker network   #######################"
    echo "#################################################################"
    if ! docker network inspect fabric-network >/dev/null 2>&1; then
        echo "Network 'fabric-network' does not exist. Creating..."
        docker network create fabric-network
        echo "Network 'fabric-network' created successfully."
    else
      echo "Network 'fabric-network' already exists. Skipping creation."
    fi
    echo
  sleep 2
  echo
    echo "#################################################################"
    echo "###################   deploy raft orderer   #####################"
    echo "#################################################################"
    docker compose -f orderer.yaml up -d
    echo
  sleep 3
  echo
    echo "#################################################################"
    echo "###################   deploy Org1-Org9   ########################"
    echo "#################################################################"
    docker compose -f peer.yaml up -d
    echo
  sleep 3
}

function down() {
  echo
    echo "#################################################################"
    echo "###################   down raft orderer   #####################"
    echo "#################################################################"
    docker compose -f orderer.yaml down -v
    echo
    sleep 3
  echo
    echo "#################################################################"
    echo "###################   down Org1-Org9   ########################"
    echo "#################################################################"
    docker compose -f peer.yaml down -v
    echo
    sleep 3
  echo
    echo "#################################################################"
    echo "###################    down ipfs and ledger   ##################"
    echo "#################################################################"
    docker compose -f ledger.yaml down -v
    docker compose -f ipfs/docker-ipfs.yaml down -v
    echo
    sleep 2
  echo
    echo "#################################################################"
    echo "###################    down docker network   ##################"
    echo "#################################################################"
    docker network rm fabric-network
    echo
    sleep 2
    rm -rf channel-artifacts/
    rm -rf crypto-config/
}

function ipfs() {
    cd ipfs/
    docker compose -f docker-ipfs.yaml up -d
    cd ../
}

function ledger() {
    docker compose -f ledger.yaml up -d
}

# Network operations
case $COMMAND in
    "generate")           #   属实话证书、区块
        generateCerts
        generateChannelArtifacts
        ;;
    "up")                 #   启动容器
        up
        ;;
    "create")             #   创建通道、加入通道、更新锚节点
        createChannel
        joinChannel
        updateAnchors
        ;;
    "query-channel")      #   查询通道成员
        queryChannelInfo
        ;;
    "package")            #   链码打包
        packageCC
        ;;
    "install")            #   链码批准、链码提交、链码调用
        installChaincodeB
        installChaincodeC
        installChaincodeD
        installChaincodeA
        ;;
    "ipfs")
        ipfs
        ;;
    "ledger")
        ledger
        ;;
    "down")
        down
        ;;
    *)
        echo "Useage: create.sh generate | up | create | query-channel | package | install | ipfs | ledger | down"
        exit 1;
esac
