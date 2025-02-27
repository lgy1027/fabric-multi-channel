package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

var (
	ConditionTypeMap = map[string]struct{}{
		Congestion: {},
		Accident:   {},
		Roadwork:   {},
	}
	SeverityMap = map[string]struct{}{
		Low:    {},
		Medium: {},
		High:   {},
	}
)

// 预定义的枚举值
const (
	Congestion = "Congestion"
	Accident   = "Accident"
	Roadwork   = "Roadwork"

	Low    = "Low"
	Medium = "Medium"
	High   = "High"
)

// ParkingFacility 周边设施（停车场）信息结构
type ParkingFacility struct {
	FacilityID     string  `json:"facilityID"`
	Location       string  `json:"location"`
	TotalSpots     int     `json:"totalSpots"`
	AvailableSpots int     `json:"availableSpots"`
	PricePerHour   float64 `json:"pricePerHour"`
	IpfsCid        string  `json:"IpfsCid"`
}

// TrafficCondition 路况信息结构
type TrafficCondition struct {
	Location      string `json:"location"`
	ConditionType string `json:"conditionType"` // e.g., Congestion, Accident, Roadwork
	Severity      string `json:"severity"`      // e.g., Low, Medium, High
	Timestamp     string `json:"timestamp"`
	Description   string `json:"description"`
	IpfsCid       string `json:"IpfsCid"`
}

// 校验ConditionType的合法性
func validateConditionType(conditionType string) error {
	_, ok := ConditionTypeMap[conditionType]
	if ok {
		return nil
	}
	return fmt.Errorf("invalid ConditionType: %s. Allowed values are Congestion, Accident, Roadwork", conditionType)
}

// 校验Severity的合法性
func validateSeverity(severity string) error {
	_, ok := SeverityMap[severity]
	if ok {
		return nil
	}
	return fmt.Errorf("invalid Severity: %s. Allowed values are Low, Medium, High", severity)
}

// ChannelDContract 实现增删改查的智能合约
type ChannelDContract struct {
	contractapi.Contract
}

// CreateParkingFacility 增加停车设施信息
func (s *ChannelDContract) CreateParkingFacility(ctx contractapi.TransactionContextInterface, facilityID string, location string, totalSpots int, availableSpots int, pricePerHour float64, IpfsCid string) error {
	// 检查是否已经存在相同的FacilityID
	exists, err := s.ParkingFacilityExists(ctx, facilityID)
	if err != nil {
		return fmt.Errorf("failed to check if parking facility exists: %v", err)
	}
	if exists {
		return fmt.Errorf("the parking facility %s already exists", facilityID)
	}

	// 创建新的ParkingFacility对象
	parkingFacility := ParkingFacility{
		FacilityID:     facilityID,
		Location:       location,
		TotalSpots:     totalSpots,
		AvailableSpots: availableSpots,
		PricePerHour:   pricePerHour,
		IpfsCid:        IpfsCid,
	}

	// 将结构体转换为JSON格式
	parkingFacilityAsBytes, err := json.Marshal(parkingFacility)
	if err != nil {
		return fmt.Errorf("failed to marshal parking facility: %v", err)
	}

	// 存储到链上
	return ctx.GetStub().PutState(facilityID, parkingFacilityAsBytes)
}

// QueryParkingFacilityHistory 溯源查询
func (s *ChannelDContract) QueryParkingFacilityHistory(ctx contractapi.TransactionContextInterface, facilityID string) ([]ParkingFacility, error) {
	historyIterator, err := ctx.GetStub().GetHistoryForKey(facilityID)
	if err != nil {
		return nil, fmt.Errorf("failed to get history for facilityID %s: %s", facilityID, err.Error())
	}
	defer historyIterator.Close()

	var history []ParkingFacility

	// 遍历历史记录并将每个条目附加到结果中
	for historyIterator.HasNext() {
		response, err := historyIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("failed to iterate history for facilityID %s: %s", facilityID, err.Error())
		}

		var parkingFacility ParkingFacility
		if len(response.Value) > 0 {
			err := json.Unmarshal(response.Value, &parkingFacility)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal ParkingFacility: %s", err.Error())
			}

			history = append(history, parkingFacility)
		}
	}

	return history, nil
}

// QueryParkingFacility 查询停车设施信息
func (s *ChannelDContract) QueryParkingFacility(ctx contractapi.TransactionContextInterface, facilityID string) (*ParkingFacility, error) {
	// 从链上获取状态数据
	parkingFacilityAsBytes, err := ctx.GetStub().GetState(facilityID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if parkingFacilityAsBytes == nil {
		return nil, fmt.Errorf("parking facility with ID %s does not exist", facilityID)
	}

	// 反序列化JSON数据为ParkingFacility结构体
	var parkingFacility ParkingFacility
	err = json.Unmarshal(parkingFacilityAsBytes, &parkingFacility)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal parking facility: %v", err)
	}

	return &parkingFacility, nil
}

// UpdateParkingFacility 更新停车设施信息
func (s *ChannelDContract) UpdateParkingFacility(ctx contractapi.TransactionContextInterface, facilityID string, location string, totalSpots int, availableSpots int, pricePerHour float64, IpfsCid string) error {
	// 先查询现有的停车设施信息
	parkingFacility, err := s.QueryParkingFacility(ctx, facilityID)
	if err != nil {
		return err
	}

	// 更新停车设施信息
	parkingFacility.Location = location
	parkingFacility.TotalSpots = totalSpots
	parkingFacility.AvailableSpots = availableSpots
	parkingFacility.PricePerHour = pricePerHour
	parkingFacility.IpfsCid = IpfsCid

	// 将更新后的数据序列化为JSON
	parkingFacilityAsBytes, err := json.Marshal(parkingFacility)
	if err != nil {
		return fmt.Errorf("failed to marshal updated parking facility: %v", err)
	}

	// 保存更新后的数据
	return ctx.GetStub().PutState(facilityID, parkingFacilityAsBytes)
}

// DeleteParkingFacility 删除停车设施信息
func (s *ChannelDContract) DeleteParkingFacility(ctx contractapi.TransactionContextInterface, facilityID string) error {
	exists, err := s.ParkingFacilityExists(ctx, facilityID)
	if err != nil {
		return fmt.Errorf("failed to check if parking facility exists: %v", err)
	}
	if !exists {
		return fmt.Errorf("parking facility with ID %s does not exist", facilityID)
	}

	// 删除状态信息
	return ctx.GetStub().DelState(facilityID)
}

// ParkingFacilityExists 检查停车设施信息是否存在
func (s *ChannelDContract) ParkingFacilityExists(ctx contractapi.TransactionContextInterface, facilityID string) (bool, error) {
	parkingFacilityAsBytes, err := ctx.GetStub().GetState(facilityID)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return parkingFacilityAsBytes != nil, nil
}

// CreateTrafficCondition 增加路况信息
func (s *ChannelDContract) CreateTrafficCondition(ctx contractapi.TransactionContextInterface, location string, conditionType string, severity string, timestamp string, description, IpfsCid string) error {
	// 校验ConditionType和Severity
	if err := validateConditionType(conditionType); err != nil {
		return err
	}
	if err := validateSeverity(severity); err != nil {
		return err
	}

	// 使用 location + timestamp 作为唯一键
	key := location + "-" + timestamp

	// 检查是否已经存在相同的路况信息
	exists, err := s.TrafficConditionExists(ctx, key)
	if err != nil {
		return fmt.Errorf("failed to check if traffic condition exists: %v", err)
	}
	if exists {
		return fmt.Errorf("the traffic condition at location %s already exists at time %s", location, timestamp)
	}

	// 创建新的TrafficCondition对象
	trafficCondition := TrafficCondition{
		Location:      location,
		ConditionType: conditionType,
		Severity:      severity,
		Timestamp:     timestamp,
		Description:   description,
		IpfsCid:       IpfsCid,
	}

	// 将结构体转换为JSON格式
	trafficConditionAsBytes, err := json.Marshal(trafficCondition)
	if err != nil {
		return fmt.Errorf("failed to marshal traffic condition: %v", err)
	}
	// 存储到链上
	// 带着时间
	err = ctx.GetStub().PutState(key, trafficConditionAsBytes)
	if err != nil {
		return fmt.Errorf("create TrafficCondition failed: %v", err.Error())
	}
	// 不带时间
	return ctx.GetStub().PutState(location, trafficConditionAsBytes)
}

// UpdateTrafficCondition 更新路况信息
func (s *ChannelDContract) UpdateTrafficCondition(ctx contractapi.TransactionContextInterface, location string, conditionType string, severity string, timestamp string, description, IpfsCid string) error {
	// 校验ConditionType和Severity
	if err := validateConditionType(conditionType); err != nil {
		return err
	}
	if err := validateSeverity(severity); err != nil {
		return err
	}

	// 使用 location + timestamp 作为唯一键
	key := location + "-" + timestamp

	// 先查询现有的路况信息
	trafficCondition, err := s.QueryTrafficCondition(ctx, location, timestamp)
	if err != nil {
		return err
	}

	// 更新路况信息
	trafficCondition.ConditionType = conditionType
	trafficCondition.Severity = severity
	trafficCondition.Description = description
	trafficCondition.IpfsCid = IpfsCid

	// 将更新后的数据序列化为JSON
	trafficConditionAsBytes, err := json.Marshal(trafficCondition)
	if err != nil {
		return fmt.Errorf("failed to marshal updated traffic condition: %v", err)
	}

	// 保存更新后的数据
	return ctx.GetStub().PutState(key, trafficConditionAsBytes)
}

// QueryTrafficConditionHistory 溯源查询

func (s *ChannelDContract) QueryTrafficConditionHistory(ctx contractapi.TransactionContextInterface, location, timestamp string) ([]TrafficCondition, error) {
	key := location + "-" + timestamp
	historyIterator, err := ctx.GetStub().GetHistoryForKey(key)
	if err != nil {
		return nil, fmt.Errorf("failed to get history for location %s: %s", key, err.Error())
	}
	defer historyIterator.Close()

	var history []TrafficCondition

	// 遍历历史记录并将每个条目附加到结果中
	for historyIterator.HasNext() {
		response, err := historyIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("failed to iterate history for location %s: %s", key, err.Error())
		}

		var parkingFacility TrafficCondition
		if len(response.Value) > 0 {
			err := json.Unmarshal(response.Value, &parkingFacility)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal TrafficCondition: %s", err.Error())
			}

			history = append(history, parkingFacility)
		}
	}

	return history, nil
}

// QueryTrafficCondition 查询路况信息
func (s *ChannelDContract) QueryTrafficCondition(ctx contractapi.TransactionContextInterface, location string, timestamp string) (*TrafficCondition, error) {
	// 使用 location + timestamp 作为唯一键
	key := location + "-" + timestamp

	// 从链上获取状态数据
	trafficConditionAsBytes, err := ctx.GetStub().GetState(key)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if trafficConditionAsBytes == nil {
		return nil, fmt.Errorf("traffic condition at location %s does not exist at time %s", location, timestamp)
	}

	// 反序列化JSON数据为TrafficCondition结构体
	var trafficCondition TrafficCondition
	err = json.Unmarshal(trafficConditionAsBytes, &trafficCondition)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal traffic condition: %v", err)
	}

	return &trafficCondition, nil
}

// TrafficConditionExists 检查路况信息是否存在
func (s *ChannelDContract) TrafficConditionExists(ctx contractapi.TransactionContextInterface, key string) (bool, error) {
	trafficConditionAsBytes, err := ctx.GetStub().GetState(key)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return trafficConditionAsBytes != nil, nil
}

// DeleteTrafficCondition 删除路况信息
func (s *ChannelDContract) DeleteTrafficCondition(ctx contractapi.TransactionContextInterface, location string, timestamp string) error {

	key := location + "-" + timestamp
	exists, err := s.TrafficConditionExists(ctx, key)
	if err != nil {
		return fmt.Errorf("failed to check if trafficCondition exists: %v", err)
	}
	if !exists {
		return fmt.Errorf("trafficCondition with ID %s does not exist", key)
	}

	// 删除状态信息
	return ctx.GetStub().DelState(key)
}

// main 函数启动链码
func main() {
	chaincode, err := contractapi.NewChaincode(new(ChannelDContract))
	if err != nil {
		fmt.Printf("Error creating Traffic and Parking chaincode: %v", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting Traffic and Parking chaincode: %v", err)
	}
}
