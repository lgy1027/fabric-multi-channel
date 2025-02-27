package main

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

const (
	ChannelB = "channelb"
	ChannelC = "channelc"
	ChannelD = "channeld"
)

const (
	ChainCodeBName = "channelb_ledger"
	ChainCodeCName = "channelc_ledger"
	ChainCodeDName = "channeld_ledger"
)

const (
	ChannelBQuery                        = "QueryVehicleStatus"
	ChannelBHistoryQuery                 = "QueryVehicleHistory"
	ChannelCQuery                        = "QueryInsurancePolicy"
	ChannelCHistoryQuery                 = "QueryInsurancePolicyHistory"
	ChannelDQueryParkingFacility         = "QueryParkingFacility"
	ChannelDQueryParkingFacilityHistory  = "QueryParkingFacilityHistory"
	ChannelDQueryTrafficCondition        = "QueryTrafficCondition"
	ChannelDQueryTrafficConditionHistory = "QueryTrafficConditionHistory"
)

// ChannelAContract 跨通道查询链码
type ChannelAContract struct {
	contractapi.Contract
}

// QueryVehicleStatus 从 channelB 查询车辆状态信息
func (s *ChannelAContract) queryVehicleStatus(ctx contractapi.TransactionContextInterface, vehicleID string) (string, error) {
	args := [][]byte{[]byte(ChannelBQuery), []byte(vehicleID)} // 查询参数

	// 调用 channelB 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeBName, args, ChannelB)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query vehicle status from channelB: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryVehicleStatus 从 channelB 查询车辆状态信息溯源信息

func (s *ChannelAContract) queryVehicleStatusHistory(ctx contractapi.TransactionContextInterface, vehicleID string) (string, error) {
	args := [][]byte{[]byte(ChannelBHistoryQuery), []byte(vehicleID)} // 查询参数

	// 调用 channelB 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeBName, args, ChannelB)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query vehicle status history from channelB: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryInsurancePolicy 从 channelC 查询汽车保险信息
func (s *ChannelAContract) queryInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string) (string, error) {
	args := [][]byte{[]byte(ChannelCQuery), []byte(policyID)} // 查询参数 (保单ID)

	// 调用 channelC 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeCName, args, ChannelC)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query insurance policy from channelC: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryInsurancePolicyHistory 从 channelC 查询汽车保险溯源信息
func (s *ChannelAContract) queryInsurancePolicyHistory(ctx contractapi.TransactionContextInterface, policyID string) (string, error) {
	args := [][]byte{[]byte(ChannelCHistoryQuery), []byte(policyID)} // 查询参数 (保单ID)

	// 调用 channelC 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeCName, args, ChannelC)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query insurance policy from channelC: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryTrafficCondition 从 channelD 查询路况信息
func (s *ChannelAContract) queryTrafficCondition(ctx contractapi.TransactionContextInterface, location string, timestamp string) (string, error) {
	args := [][]byte{[]byte(ChannelDQueryTrafficCondition), []byte(location), []byte(timestamp)} // 查询参数 (位置)

	// 调用 channelD 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeDName, args, ChannelD)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query traffic condition from channelD: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryTrafficConditionHistory 路况溯源
func (s *ChannelAContract) queryTrafficConditionHistory(ctx contractapi.TransactionContextInterface, location, localTime string) (string, error) {
	args := [][]byte{[]byte(ChannelDQueryTrafficConditionHistory), []byte(location), []byte(localTime)} // 查询参数 (位置)

	// 调用 channelC 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeDName, args, ChannelD)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query insurance policy from channelC: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryParkingFacility 从 channelD 查询停车设施信息
func (s *ChannelAContract) queryParkingFacility(ctx contractapi.TransactionContextInterface, facilityID string) (string, error) {
	args := [][]byte{[]byte(ChannelDQueryParkingFacility), []byte(facilityID)} // 查询参数 (位置ID)

	// 调用 channelD 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeDName, args, ChannelD)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query parking facility from channelD: %s", response.Message)
	}

	return string(response.Payload), nil
}

// QueryParkingFacilityHistory 停车场溯源
func (s *ChannelAContract) queryParkingFacilityHistory(ctx contractapi.TransactionContextInterface, facilityID string) (string, error) {
	args := [][]byte{[]byte(ChannelDQueryParkingFacilityHistory), []byte(facilityID)} // 查询参数 (位置ID)

	// 调用 channelC 上的链码
	response := ctx.GetStub().InvokeChaincode(ChainCodeDName, args, ChannelD)
	if response.Status != 200 {
		return "", fmt.Errorf("failed to query insurance policy from channelC: %s", response.Message)
	}

	return string(response.Payload), nil
}

// UnifiedQuery 统一查询接口，根据通道和数据类型查询信息
func (s *ChannelAContract) UnifiedQuery(ctx contractapi.TransactionContextInterface, channel string, action string, id, localTime string) (string, error) {
	// 获取当前调用者的身份
	clientMSP, err := ctx.GetClientIdentity().GetMSPID()
	fmt.Println(err)
	fmt.Println(clientMSP)
	fmt.Println(channel)
	fmt.Println(action)
	fmt.Println(id)
	fmt.Println(localTime)
	// 判断调用的通道和MSP匹配
	if channel == ChannelB && clientMSP != "Org1MSP" {
		return "", fmt.Errorf("only Org1 can query channelB")
	} else if channel == ChannelC && clientMSP != "Org4MSP" {
		return "", fmt.Errorf("only Org4 can query channelC")
	} else if channel == ChannelD && clientMSP != "Org7MSP" {
		return "", fmt.Errorf("only Org7 can query channelD")
	}
	switch channel {
	case ChannelB:
		if action == "VehicleStatus" {
			return s.queryVehicleStatus(ctx, id)
		}
		if action == "VehicleStatusHistory" {
			return s.queryVehicleStatusHistory(ctx, id)
		}
	case ChannelC:
		if action == "InsurancePolicy" {
			return s.queryInsurancePolicy(ctx, id)
		}
		if action == "InsurancePolicyHistory" {
			return s.queryInsurancePolicyHistory(ctx, id)
		}
	case ChannelD:
		if action == "TrafficCondition" {
			return s.queryTrafficCondition(ctx, id, localTime)
		} else if action == "ParkingFacility" {
			return s.queryParkingFacility(ctx, id)
		} else if action == "TrafficConditionHistory" {
			return s.queryTrafficConditionHistory(ctx, id, localTime)
		} else if action == "ParkingFacilityHistory" {
			return s.queryParkingFacilityHistory(ctx, id)
		}
	}

	return "", fmt.Errorf("unsupported channel or data type: %s, %s", channel, action)
}

// main 函数启动链码
func main() {
	chaincode, err := contractapi.NewChaincode(new(ChannelAContract))
	if err != nil {
		fmt.Printf("Error creating chaincode: %v", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %v", err)
	}
}
