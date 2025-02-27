package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// InsurancePolicy 共享汽车保险信息结构
type InsurancePolicy struct {
	PolicyID      string  `json:"policyID"`
	VehicleID     string  `json:"vehicleID"`
	Owner         string  `json:"owner"`
	Provider      string  `json:"provider"`
	CoverageType  string  `json:"coverageType"`
	StartDate     string  `json:"startDate"`
	EndDate       string  `json:"endDate"`
	PremiumAmount float64 `json:"premiumAmount"`
	Status        string  `json:"status"`
	IpfsCid       string  `json:"IpfsCid"`
}

// ChannelCContract 实现增删改查的智能合约
type ChannelCContract struct {
	contractapi.Contract
}

// CreateInsurancePolicy 增加保险信息
func (s *ChannelCContract) CreateInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string, vehicleID string, owner string, provider string, coverageType string, startDate string, endDate string, premiumAmount float64, status, IpfsCid string) error {
	// 检查是否已经存在相同的PolicyID
	exists, err := s.InsurancePolicyExists(ctx, policyID)
	if err != nil {
		return fmt.Errorf("failed to check if policy exists: %v", err)
	}
	if exists {
		return fmt.Errorf("the insurance policy %s already exists", policyID)
	}

	// 创建新的InsurancePolicy对象
	insurancePolicy := InsurancePolicy{
		PolicyID:      policyID,
		VehicleID:     vehicleID,
		Owner:         owner,
		Provider:      provider,
		CoverageType:  coverageType,
		StartDate:     startDate,
		EndDate:       endDate,
		PremiumAmount: premiumAmount,
		Status:        status,
		IpfsCid:       IpfsCid,
	}

	// 将结构体转换为JSON格式
	insurancePolicyAsBytes, err := json.Marshal(insurancePolicy)
	if err != nil {
		return fmt.Errorf("failed to marshal insurance policy: %v", err)
	}

	// 存储到链上
	return ctx.GetStub().PutState(policyID, insurancePolicyAsBytes)
}

// QueryInsurancePolicy 查询保险信息
func (s *ChannelCContract) QueryInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string) (*InsurancePolicy, error) {
	// 从链上获取状态数据
	insurancePolicyAsBytes, err := ctx.GetStub().GetState(policyID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if insurancePolicyAsBytes == nil {
		return nil, fmt.Errorf("insurance policy with ID %s does not exist", policyID)
	}

	// 反序列化JSON数据为InsurancePolicy结构体
	var insurancePolicy InsurancePolicy
	err = json.Unmarshal(insurancePolicyAsBytes, &insurancePolicy)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal insurance policy: %v", err)
	}

	return &insurancePolicy, nil
}

// UpdateInsurancePolicy 更新保险信息
func (s *ChannelCContract) UpdateInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string, vehicleID string, owner string, provider string, coverageType string, startDate string, endDate string, premiumAmount float64, status, IpfsCid string) error {
	// 先查询现有的保险信息
	insurancePolicy, err := s.QueryInsurancePolicy(ctx, policyID)
	if err != nil {
		return err
	}

	// 更新保险信息
	insurancePolicy.VehicleID = vehicleID
	insurancePolicy.Owner = owner
	insurancePolicy.Provider = provider
	insurancePolicy.CoverageType = coverageType
	insurancePolicy.StartDate = startDate
	insurancePolicy.EndDate = endDate
	insurancePolicy.PremiumAmount = premiumAmount
	insurancePolicy.Status = status
	insurancePolicy.IpfsCid = IpfsCid

	// 将更新后的数据序列化为JSON
	insurancePolicyAsBytes, err := json.Marshal(insurancePolicy)
	if err != nil {
		return fmt.Errorf("failed to marshal updated insurance policy: %v", err)
	}

	// 保存更新后的数据
	return ctx.GetStub().PutState(policyID, insurancePolicyAsBytes)
}

// DeleteInsurancePolicy 删除保险信息
func (s *ChannelCContract) DeleteInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string) error {
	exists, err := s.InsurancePolicyExists(ctx, policyID)
	if err != nil {
		return fmt.Errorf("failed to check if policy exists: %v", err)
	}
	if !exists {
		return fmt.Errorf("insurance policy with ID %s does not exist", policyID)
	}

	// 删除状态信息
	return ctx.GetStub().DelState(policyID)
}

// QueryInsurancePolicyHistory 溯源查询
func (s *ChannelCContract) QueryInsurancePolicyHistory(ctx contractapi.TransactionContextInterface, policyID string) ([]InsurancePolicy, error) {
	historyIterator, err := ctx.GetStub().GetHistoryForKey(policyID)
	if err != nil {
		return nil, fmt.Errorf("failed to get history for policyID %s: %s", policyID, err.Error())
	}
	defer historyIterator.Close()

	var history []InsurancePolicy

	// 遍历历史记录并将每个条目附加到结果中
	for historyIterator.HasNext() {
		response, err := historyIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("failed to iterate history for policyID %s: %s", policyID, err.Error())
		}

		var insurancePolicy InsurancePolicy
		if len(response.Value) > 0 {
			err := json.Unmarshal(response.Value, &insurancePolicy)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal InsurancePolicy: %s", err.Error())
			}

			history = append(history, insurancePolicy)
		}
	}

	return history, nil
}

// InsurancePolicyExists 检查保险信息是否存在
func (s *ChannelCContract) InsurancePolicyExists(ctx contractapi.TransactionContextInterface, policyID string) (bool, error) {
	insurancePolicyAsBytes, err := ctx.GetStub().GetState(policyID)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return insurancePolicyAsBytes != nil, nil
}

// main 函数启动链码
func main() {
	chaincode, err := contractapi.NewChaincode(new(ChannelCContract))
	if err != nil {
		fmt.Printf("Error creating InsurancePolicy chaincode: %v", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting InsurancePolicy chaincode: %v", err)
	}
}
