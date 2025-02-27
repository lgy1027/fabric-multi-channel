package model

const (
	ChannelA = "channela"
	ChannelB = "channelb"
	ChannelC = "channelc"
	ChannelD = "channeld"
)

const (
	Org1Msp = "Org1MSP"
	Org2Msp = "Org2MSP"
	Org3Msp = "Org3MSP"
	Org4Msp = "Org4MSP"
	Org5Msp = "Org5MSP"
	Org6Msp = "Org6MSP"
	Org7Msp = "Org7MSP"
	Org8Msp = "Org8MSP"
	Org9Msp = "Org9MSP"
)

var OrgMap = map[string]struct{}{
	"org1": struct{}{},
	"org2": struct{}{},
	"org3": struct{}{},
	"org4": struct{}{},
	"org5": struct{}{},
	"org6": struct{}{},
	"org7": struct{}{},
	"org8": struct{}{},
	"org9": struct{}{},
}

var ChannelMap = map[string]struct{}{
	"channela": struct{}{},
	"channelb": struct{}{},
	"channelc": struct{}{},
	"channeld": struct{}{},
}

var (
	ChannelbAction = map[string]struct{}{
		"VehicleStatus":        struct{}{},
		"VehicleStatusHistory": struct{}{},
	}

	ChannelcAction = map[string]struct{}{
		"InsurancePolicy":        struct{}{},
		"InsurancePolicyHistory": struct{}{},
	}

	ChanneldAction = map[string]struct{}{
		"TrafficCondition":        struct{}{},
		"ParkingFacility":         struct{}{},
		"TrafficConditionHistory": struct{}{},
		"ParkingFacilityHistory":  struct{}{},
	}
)

const (
	// ChannelA
	ChannelAUnifiedQuery = "UnifiedQuery"

	// ChannelB
	ChannelBCreateVehicleStatus = "CreateVehicleStatus"
	ChannelBQueryVehicleStatus  = "QueryVehicleStatus"
	ChannelBUpdateVehicleStatus = "UpdateVehicleStatus"
	ChannelBDeleteVehicleStatus = "DeleteVehicleStatus"
	ChannelBQueryVehicleHistory = "QueryVehicleHistory"

	// channelC
	ChannelCCreateInsurancePolicy       = "CreateInsurancePolicy"
	ChannelCQueryInsurancePolicy        = "QueryInsurancePolicy"
	ChannelCUpdateInsurancePolicy       = "UpdateInsurancePolicy"
	ChannelCDeleteInsurancePolicy       = "DeleteInsurancePolicy"
	ChannelCQueryInsurancePolicyHistory = "QueryInsurancePolicyHistory"

	// channelD
	ChannelDCreateParkingFacility        = "CreateParkingFacility"
	ChannelDQueryParkingFacilityHistory  = "QueryParkingFacilityHistory"
	ChannelDQueryParkingFacility         = "QueryParkingFacility"
	ChannelDUpdateParkingFacility        = "UpdateParkingFacility"
	ChannelDDeleteParkingFacility        = "DeleteParkingFacility"
	ChannelDCreateTrafficCondition       = "CreateTrafficCondition"
	ChannelDUpdateTrafficCondition       = "UpdateTrafficCondition"
	ChannelDQueryTrafficConditionHistory = "QueryTrafficConditionHistory"
	ChannelDQueryTrafficCondition        = "QueryTrafficCondition"
	ChannelDDeleteTrafficCondition       = "DeleteTrafficCondition"
)

const (
	Token = "token"
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

type TokenReq struct {
	Org     string `json:"org"`
	Channel string `json:"channel"`
}
