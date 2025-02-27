package config

import (
	"log"

	"github.com/spf13/viper"
)

// Contract 定义合约结构体
type Contract struct {
	ChannelName   string `mapstructure:"channelName"`
	ChaincodeName string `mapstructure:"chaincodeName"`
	ContractName  string `mapstructure:"contractName"`
}

// OrgConfig 定义组织配置结构体
type OrgConfig struct {
	OrgMsp       string     `json:"orgMsp"`
	Contract     []Contract `mapstructure:"contract"`
	PeerEndpoint string     `mapstructure:"peerEndpoint"`
	GatewayPeer  string     `mapstructure:"gatewayPeer"`
	CertPath     string     `mapstructure:"certPath"`
	KeyPath      string     `mapstructure:"keyPath"`
	TlsCertPath  string     `mapstructure:"tlsCertPath"`
}

// Config 定义总配置结构体
type Config struct {
	Common struct {
		ListenIP   string `mapstructure:"listenip"`
		ListenPort int    `mapstructure:"listenport"`
	} `mapstructure:"common"`
	Ledger     []*OrgConfig `json:"ledger"`
	IPFSConfig struct {
		URL string `mapstructure:"url"`
	} `mapstructure:"ipfsconfig"`
}

var (
	config *Config
)

const (
	// DefaultConfigurationName is the default name of configuration
	defaultConfigurationName = "ledger"
	// DefaultConfigurationPath the default location of the configuration file
	defaultConfigurationPath = "/etc/ledger"
)

func InitConfig() error {
	var conf Config
	viper.SetConfigType("yaml")
	viper.SetEnvKeyReplacer(nil)
	viper.SetConfigName(defaultConfigurationName)
	viper.AddConfigPath(defaultConfigurationPath)
	viper.AddConfigPath(".")
	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(*viper.ConfigFileNotFoundError); !ok {
			log.Fatalf("can't found config file %s", err)
		} else {
			log.Fatalf("error parsing configuration file %s", err)
		}
	}

	if err := viper.Unmarshal(&conf); err != nil {
		log.Fatal(err)
	}
	config = &conf

	return nil
}

func GetConfig() *Config {
	if config == nil {
		_ = InitConfig()
	}
	return config
}
