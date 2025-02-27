package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// VehicleStatus 共享汽车状态结构
type VehicleStatus struct {
	VehicleID string `json:"vehicleID"`
	Location  string `json:"location"`
	Speed     int    `json:"speed"`
	FuelLevel int    `json:"fuelLevel"`
	Battery   int    `json:"battery"`
	Timestamp string `json:"timestamp"`
	IpfsCid   string `json:"IpfsCid"`
}

// ChannelBContract 实现增删改查的智能合约
type ChannelBContract struct {
	contractapi.Contract
}

// CreateVehicleStatus 增加车辆状态信息
func (s *ChannelBContract) CreateVehicleStatus(ctx contractapi.TransactionContextInterface, vehicleID string, location string, speed int, fuelLevel int, battery int, timestamp, IpfsCid string) error {
	// 检查是否已经存在相同的VehicleID
	exists, err := s.VehicleStatusExists(ctx, vehicleID)
	fmt.Println(exists, "   ", vehicleID, "   ", location, "   ", speed, "   ", fuelLevel, "   ", battery, "   ", timestamp)
	if err != nil {
		return fmt.Errorf("failed to check if vehicle exists: %v", err)
	}
	if exists {
		return fmt.Errorf("the vehicle %s already exists", vehicleID)
	}

	// 创建新的VehicleStatus对象
	vehicleStatus := &VehicleStatus{
		VehicleID: vehicleID,
		Location:  location,
		Speed:     speed,
		FuelLevel: fuelLevel,
		Battery:   battery,
		Timestamp: timestamp,
		IpfsCid:   IpfsCid,
	}
	// 将结构体转换为JSON格式
	vehicleStatusAsBytes, err := json.Marshal(vehicleStatus)
	if err != nil {
		return fmt.Errorf("failed to marshal vehicle status: %v", err)
	}

	// 存储到链上
	return ctx.GetStub().PutState(vehicleID, vehicleStatusAsBytes)
}

// QueryVehicleStatus 查询车辆状态信息
func (s *ChannelBContract) QueryVehicleStatus(ctx contractapi.TransactionContextInterface, vehicleID string) (*VehicleStatus, error) {
	// 从链上获取状态数据
	vehicleStatusAsBytes, err := ctx.GetStub().GetState(vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if vehicleStatusAsBytes == nil {
		return nil, fmt.Errorf("vehicle with ID %s does not exist", vehicleID)
	}

	// 反序列化JSON数据为VehicleStatus结构体
	vehicleStatus := &VehicleStatus{}
	err = json.Unmarshal(vehicleStatusAsBytes, vehicleStatus)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal vehicle status: %v", err)
	}

	return vehicleStatus, nil
}

// UpdateVehicleStatus 更新车辆状态信息
func (s *ChannelBContract) UpdateVehicleStatus(ctx contractapi.TransactionContextInterface, vehicleID string, location string, speed int, fuelLevel int, battery int, timestamp, IpfsCid string) error {
	// 先查询现有的车辆状态信息
	vehicleStatus, err := s.QueryVehicleStatus(ctx, vehicleID)
	if err != nil {
		return err
	}

	// 更新车辆状态信息
	vehicleStatus.Location = location
	vehicleStatus.Speed = speed
	vehicleStatus.FuelLevel = fuelLevel
	vehicleStatus.Battery = battery
	vehicleStatus.Timestamp = timestamp
	vehicleStatus.IpfsCid = IpfsCid

	// 将更新后的数据序列化为JSON
	vehicleStatusAsBytes, err := json.Marshal(vehicleStatus)
	if err != nil {
		return fmt.Errorf("failed to marshal updated vehicle status: %v", err)
	}

	// 保存更新后的数据
	return ctx.GetStub().PutState(vehicleID, vehicleStatusAsBytes)
}

// DeleteVehicleStatus 删除车辆状态信息
func (s *ChannelBContract) DeleteVehicleStatus(ctx contractapi.TransactionContextInterface, vehicleID string) error {
	exists, err := s.VehicleStatusExists(ctx, vehicleID)
	if err != nil {
		return fmt.Errorf("failed to check if vehicle exists: %v", err)
	}
	if !exists {
		return fmt.Errorf("vehicle with ID %s does not exist", vehicleID)
	}

	// 删除状态信息
	return ctx.GetStub().DelState(vehicleID)
}

// VehicleStatusExists 检查车辆状态是否存在
func (s *ChannelBContract) VehicleStatusExists(ctx contractapi.TransactionContextInterface, vehicleID string) (bool, error) {
	vehicleStatusAsBytes, err := ctx.GetStub().GetState(vehicleID)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	fmt.Println(string(vehicleStatusAsBytes))
	return vehicleStatusAsBytes != nil, nil
}

// QueryVehicleHistory 溯源查询
func (s *ChannelBContract) QueryVehicleHistory(ctx contractapi.TransactionContextInterface, vehicleID string) ([]VehicleStatus, error) {
	// 获取给定车辆 ID 的历史记录
	historyIterator, err := ctx.GetStub().GetHistoryForKey(vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to get history for vehicleID %s: %s", vehicleID, err.Error())
	}
	defer historyIterator.Close()

	var history []VehicleStatus

	// 遍历历史记录并将每个条目附加到结果中
	for historyIterator.HasNext() {
		response, err := historyIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("failed to iterate history for vehicleID %s: %s", vehicleID, err.Error())
		}

		var vehicleStatus VehicleStatus
		if len(response.Value) > 0 {
			err := json.Unmarshal(response.Value, &vehicleStatus)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal vehicle status: %s", err.Error())
			}

			history = append(history, vehicleStatus)
		}
	}

	return history, nil
}

// main 函数启动链码
func main() {
	chaincode, err := contractapi.NewChaincode(new(ChannelBContract))
	if err != nil {
		fmt.Printf("Error creating VehicleStatus chaincode: %v", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting VehicleStatus chaincode: %v", err)
	}
}
