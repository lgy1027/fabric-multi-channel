package ledger

import (
	"crypto/x509"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"ledger/server/pkg/config"
	"ledger/server/pkg/model"
	"os"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"k8s.io/klog"
)

const (
	defaultClientMaxReceiveMessageSize = 1024 * 1024 * 100
)

var FabricMap = make(map[string]map[string]*Fabric)

var once sync.Once

func init() {
	once.Do(func() {
		for _, info := range config.GetConfig().Ledger {
			gw := NewGateway(info)
			FabricMap[info.OrgMsp] = gw
		}
	})

}

type LedgerInterface interface {
	TransferAsync(token *model.TokenReq, value []byte) (string, error)
	UpdateAsync(token *model.TokenReq, value []byte) (string, error)
	TraceabilityQuery(token *model.TokenReq, channel, action, id, localTime string) (interface{}, error)
	TraceabilityQueryHistory(token *model.TokenReq, id, localTime string) (interface{}, error)
}

type Fabric struct {
	clientConnection *grpc.ClientConn
	gateway          *client.Gateway
	network          *client.Network
	contract         *client.Contract
}

func containsAnyRegex(s string, substrings []string) bool {
	pattern := ""
	for i, substr := range substrings {
		if i > 0 {
			pattern += "|"
		}
		pattern += regexp.QuoteMeta(substr)
	}
	re, err := regexp.Compile(pattern)
	if err != nil {
		return false
	}
	return re.MatchString(s)
}

func GetFabric(token *model.TokenReq) LedgerInterface {
	var (
		org     string
		channel = token.Channel
		ok      bool
	)
	switch token.Channel {
	case model.ChannelA:
		ok = containsAnyRegex(token.Org, []string{"org1", "org4", "org7"})
		if ok {
			org = fmt.Sprintf("%s%sMSP", strings.ToUpper(token.Org[0:1]), token.Org[1:])
		}
	case model.ChannelB:
		ok = containsAnyRegex(token.Org, []string{"org1", "org2", "org3"})
		org = model.Org1Msp
	case model.ChannelC:
		ok = containsAnyRegex(token.Org, []string{"org4", "org5", "org6"})
		org = model.Org4Msp
	case model.ChannelD:
		ok = containsAnyRegex(token.Org, []string{"org7", "org8", "org9"})
		org = model.Org7Msp
	}
	if !ok {
		return nil
	}
	fabrics := FabricMap[org]
	if fabrics == nil {
		return nil
	}
	ledger := fabrics[channel]
	if ledger == nil {
		return nil
	}
	return ledger
}

func NewGateway(option *config.OrgConfig) map[string]*Fabric {
	clientConnection := newGrpcConnection(option)
	id := newIdentity(option.OrgMsp, option.CertPath)
	sign := newSign(option.KeyPath)

	gw, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		client.WithEvaluateTimeout(1*time.Minute),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}

	fabricMap := make(map[string]*Fabric)
	for _, action := range option.Contract {
		network := gw.GetNetwork(action.ChannelName)
		contract := network.GetContractWithName(action.ChaincodeName, action.ContractName)
		fabricMap[action.ChannelName] = &Fabric{
			clientConnection: clientConnection,
			gateway:          gw,
			network:          network,
			contract:         contract,
		}
	}

	return fabricMap
}

func newIdentity(mspID, certPath string) *identity.X509Identity {
	certificate, err := loadCertificate(certPath)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(mspID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

func newSign(keyPath string) identity.Sign {
	privateKeyPEM, err := ioutil.ReadFile(keyPath)

	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

func newGrpcConnection(option *config.OrgConfig) *grpc.ClientConn {
	certificate, err := loadCertificate(option.TlsCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, option.GatewayPeer)

	connection, err := grpc.Dial(option.PeerEndpoint, grpc.WithTransportCredentials(transportCredentials), grpc.WithDefaultCallOptions(grpc.MaxCallRecvMsgSize(defaultClientMaxReceiveMessageSize)))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}

func loadCertificate(filename string) (*x509.Certificate, error) {
	certificatePEM, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

func CloseConn() {
	for _, fabrics := range FabricMap {
		for _, ledger := range fabrics {
			_ = ledger.clientConnection.Close()
			_ = ledger.gateway.Close()
		}
	}

}

func (ledger *Fabric) UpdateAsync(token *model.TokenReq, value []byte) (string, error) {
	var (
		err             error
		transactionName string
		withArguments   client.ProposalOption
	)
	switch token.Channel {
	case model.ChannelA:

	case model.ChannelB:
		var vehicleStatus model.VehicleStatus
		err = json.Unmarshal(value, &vehicleStatus)
		if err == nil {
			transactionName = model.ChannelBUpdateVehicleStatus
			withArguments = client.WithArguments(vehicleStatus.VehicleID, vehicleStatus.Location,
				strconv.Itoa(vehicleStatus.Speed), strconv.Itoa(vehicleStatus.FuelLevel),
				strconv.Itoa(vehicleStatus.Battery), vehicleStatus.Timestamp, vehicleStatus.IpfsCid)
		}
	case model.ChannelC:
		var insurancePolicy model.InsurancePolicy
		err = json.Unmarshal(value, &insurancePolicy)
		if err == nil {
			transactionName = model.ChannelCUpdateInsurancePolicy
			withArguments = client.WithArguments(insurancePolicy.PolicyID, insurancePolicy.VehicleID,
				insurancePolicy.Owner, insurancePolicy.Provider, insurancePolicy.CoverageType, insurancePolicy.StartDate,
				insurancePolicy.EndDate, strconv.FormatFloat(insurancePolicy.PremiumAmount, 'f', 6, 64),
				insurancePolicy.Status, insurancePolicy.IpfsCid)
		}
	case model.ChannelD:
		var parkingFacility model.ParkingFacility
		err = json.Unmarshal(value, &parkingFacility)
		if err == nil && parkingFacility.FacilityID != "" {
			transactionName = model.ChannelDUpdateParkingFacility
			withArguments = client.WithArguments(parkingFacility.FacilityID, parkingFacility.Location,
				strconv.Itoa(parkingFacility.TotalSpots), strconv.Itoa(parkingFacility.AvailableSpots),
				strconv.FormatFloat(parkingFacility.PricePerHour, 'f', 6, 64), parkingFacility.IpfsCid)
		}
		var trafficCondition model.TrafficCondition
		err = json.Unmarshal(value, &trafficCondition)
		if err == nil && trafficCondition.Location != "" {
			transactionName = model.ChannelDUpdateTrafficCondition
			withArguments = client.WithArguments(trafficCondition.Location, trafficCondition.ConditionType, trafficCondition.Severity,
				trafficCondition.Timestamp, trafficCondition.Description, trafficCondition.IpfsCid)
		}
	}
	if err != nil || transactionName == "" {
		return "", fmt.Errorf("failed to submit transaction asynchronously: %w", err)
	}
	submitResult, commit, err := ledger.contract.SubmitAsync(transactionName, withArguments)
	if err != nil {
		return "", fmt.Errorf("failed to submit transaction asynchronously: %w", err)
	}

	if commitStatus, err := commit.Status(); err != nil {
		return "", fmt.Errorf("failed to get commit status: %w", err)
	} else if !commitStatus.Successful {
		return "", fmt.Errorf("transaction %s failed to commit with status: %d", commitStatus.TransactionID, int32(commitStatus.Code))
	} else {
		klog.Infof("*** Transaction committed successfully, %s", string(submitResult))
		return commit.TransactionID(), nil
	}
}

func (ledger *Fabric) TransferAsync(token *model.TokenReq, value []byte) (string, error) {
	var (
		err             error
		transactionName string
		withArguments   client.ProposalOption
	)
	switch token.Channel {
	case model.ChannelB:
		var vehicleStatus model.VehicleStatus
		err = json.Unmarshal(value, &vehicleStatus)
		if err == nil {
			transactionName = model.ChannelBCreateVehicleStatus
			withArguments = client.WithArguments(vehicleStatus.VehicleID, vehicleStatus.Location,
				strconv.Itoa(vehicleStatus.Speed), strconv.Itoa(vehicleStatus.FuelLevel),
				strconv.Itoa(vehicleStatus.Battery), vehicleStatus.Timestamp, vehicleStatus.IpfsCid)
		}
	case model.ChannelC:
		var insurancePolicy model.InsurancePolicy
		err = json.Unmarshal(value, &insurancePolicy)
		if err == nil {
			transactionName = model.ChannelCCreateInsurancePolicy
			withArguments = client.WithArguments(insurancePolicy.PolicyID, insurancePolicy.VehicleID,
				insurancePolicy.Owner, insurancePolicy.Provider, insurancePolicy.CoverageType, insurancePolicy.StartDate,
				insurancePolicy.EndDate, strconv.FormatFloat(insurancePolicy.PremiumAmount, 'f', 6, 64),
				insurancePolicy.Status, insurancePolicy.IpfsCid)
		}
	case model.ChannelD:
		var parkingFacility model.ParkingFacility
		err = json.Unmarshal(value, &parkingFacility)
		if err == nil && parkingFacility.FacilityID != "" {
			transactionName = model.ChannelDCreateParkingFacility
			withArguments = client.WithArguments(parkingFacility.FacilityID, parkingFacility.Location,
				strconv.Itoa(parkingFacility.TotalSpots), strconv.Itoa(parkingFacility.AvailableSpots),
				strconv.FormatFloat(parkingFacility.PricePerHour, 'f', 6, 64), parkingFacility.IpfsCid)
		}
		var trafficCondition model.TrafficCondition
		err = json.Unmarshal(value, &trafficCondition)
		if err == nil && trafficCondition.Timestamp != "" {
			transactionName = model.ChannelDCreateTrafficCondition
			if trafficCondition.ConditionType != "" {
				if _, ok := model.ConditionTypeMap[trafficCondition.ConditionType]; !ok {
					return "", fmt.Errorf("conditionType must eq (Congestion、 Accident、 Roadwork) option")
				}
			}
			if trafficCondition.Severity != "" {
				if _, ok := model.SeverityMap[trafficCondition.Severity]; !ok {
					return "", fmt.Errorf("severity must eq (Low、Medium、High) option")
				}
			}
			withArguments = client.WithArguments(trafficCondition.Location, trafficCondition.ConditionType, trafficCondition.Severity,
				trafficCondition.Timestamp, trafficCondition.Description, trafficCondition.IpfsCid)
		}
	}
	if err != nil || transactionName == "" {
		return "", fmt.Errorf("failed to submit transaction asynchronously: %w", err)
	}
	_, commit, err := ledger.contract.SubmitAsync(transactionName, withArguments)
	if err != nil {
		return "", fmt.Errorf("failed to submit transaction asynchronously: %w", err)
	}

	if commitStatus, err := commit.Status(); err != nil {
		return "", fmt.Errorf("failed to get commit status: %w", err)
	} else if !commitStatus.Successful {
		return "", fmt.Errorf("transaction %s failed to commit with status: %d", commitStatus.TransactionID, int32(commitStatus.Code))
	} else {
		return commit.TransactionID(), nil
	}
}

func (ledger *Fabric) TraceabilityQuery(token *model.TokenReq, channel string, action string, id, localTime string) (interface{}, error) {
	var (
		err             error
		transactionName string
		evaluateResult  []byte
	)
	if token.Channel == model.ChannelA {
		transactionName = model.ChannelAUnifiedQuery
		switch channel {
		case model.ChannelB:
			if _, ok := model.ChannelbAction[action]; !ok {
				return nil, fmt.Errorf("channelb action must eq (VehicleStatus、VehicleStatusHistory) option")
			}
		case model.ChannelC:
			if _, ok := model.ChannelcAction[action]; !ok {
				return nil, fmt.Errorf("channelc action must eq (InsurancePolicy、InsurancePolicyHistory) option")
			}
		case model.ChannelD:
			if _, ok := model.ChanneldAction[action]; !ok {
				return nil, fmt.Errorf("channeld action must eq (TrafficCondition、ParkingFacility、TrafficConditionHistory、ParkingFacilityHistory) option")
			}
		default:
			return nil, fmt.Errorf("channel must eq (channelb、channelc、channeld) option")
		}
		evaluateResult, err = ledger.contract.EvaluateTransaction(transactionName, channel, action, id, localTime)
	}
	if token.Channel == model.ChannelD {
		transactionName = model.ChannelDQueryParkingFacility
		if id != "" && localTime != "" {
			transactionName = model.ChannelDQueryTrafficCondition
			id = id + "-" + localTime
		}
		evaluateResult, err = ledger.contract.EvaluateTransaction(transactionName, id)
	}
	if token.Channel == model.ChannelB {
		transactionName = model.ChannelBQueryVehicleStatus
		evaluateResult, err = ledger.contract.EvaluateTransaction(transactionName, id)
	}
	if token.Channel == model.ChannelC {
		transactionName = model.ChannelCQueryInsurancePolicy
		evaluateResult, err = ledger.contract.EvaluateTransaction(transactionName, id)
	}

	if transactionName == "" {
		return nil, fmt.Errorf("no eq channel: %s", transactionName)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to evaluate transaction: %w", err)
	}

	var data interface{}
	err = json.Unmarshal(evaluateResult, &data)
	if err != nil {
		return nil, fmt.Errorf("failed to Unmarshal json: %w", err)
	}
	return data, nil
}

func (ledger *Fabric) TraceabilityQueryHistory(token *model.TokenReq, id, localTime string) (interface{}, error) {
	var (
		err             error
		transactionName string
	)
	switch token.Channel {
	case model.ChannelB:
		transactionName = model.ChannelBQueryVehicleHistory
	case model.ChannelC:
		transactionName = model.ChannelCQueryInsurancePolicyHistory
	case model.ChannelD:
		transactionName = model.ChannelDQueryParkingFacilityHistory
		if localTime != "" {
			id = id + "-" + localTime
			transactionName = model.ChannelDQueryTrafficConditionHistory
		}
	}
	if err != nil || transactionName == "" {
		return nil, fmt.Errorf("failed to submit transaction asynchronously: %w", err)
	}
	evaluateResult, err := ledger.contract.EvaluateTransaction(transactionName, id)
	if err != nil {
		return nil, fmt.Errorf("failed to evaluate transaction: %w", err)
	}

	data := []interface{}{}
	err = json.Unmarshal(evaluateResult, &data)
	if err != nil {
		return nil, fmt.Errorf("failed to Unmarshal json: %w", err)
	}
	return data, nil
}
