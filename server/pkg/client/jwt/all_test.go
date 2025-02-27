package jwt

import (
	"fmt"
	"ledger/server/pkg/model"
	"testing"
)

func Test_JWT(t *testing.T) {
	req := model.TokenReq{
		Org:     "example_org",
		Channel: "example_channel",
	}
	// 生成令牌
	token, err := GenerateToken(req)
	if err != nil {
		fmt.Println("Error generating token:", err)
		return
	}
	fmt.Println("Generated Token:", token)

	// 验证令牌
	verified, err := CheckToken(token)
	if err != nil {
		fmt.Println("Error verifying token:", err)
		return
	}
	fmt.Printf("Verified Org: %s, Verified Channel: %s\n", verified.Org, verified.Channel)
}
