package jwt

import (
	"errors"
	"fmt"
	"ledger/server/pkg/model"
	"time"

	"github.com/dgrijalva/jwt-go"
)

// 定义一个密钥，用于签名和验证JWT
var jwtKey = []byte("l1wcRkyhRslHhy1vU23CTmr6y7pndz")

// Claims 定义JWT的声明结构体
type Claims struct {
	Org     string `json:"org"`
	Channel string `json:"channel"`
	jwt.StandardClaims
}

// GenerateToken 生成JWT令牌
func GenerateToken(req model.TokenReq) (string, error) {
	// 设置令牌的过期时间一个月
	expirationTime := time.Now().AddDate(0, 1, 0)
	// 创建Claims对象
	claims := &Claims{
		Org:     req.Org,
		Channel: req.Channel,
		StandardClaims: jwt.StandardClaims{
			// 设置过期时间
			ExpiresAt: expirationTime.Unix(),
		},
	}

	// 创建一个新的令牌对象，指定签名方法为HS256
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	// 使用密钥对令牌进行签名
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// CheckToken 验证JWT令牌
func CheckToken(tokenString string) (*model.TokenReq, error) {
	// 定义一个Claims对象
	claims := &Claims{}

	// 解析令牌
	tkn, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		// 验证签名方法
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return jwtKey, nil
	})

	if err != nil {
		return nil, err
	}

	if !tkn.Valid {
		return nil, errors.New("invalid token")
	}

	return &model.TokenReq{
		claims.Org, claims.Channel,
	}, nil
}
