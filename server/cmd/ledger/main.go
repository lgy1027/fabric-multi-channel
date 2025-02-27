package main

import (
	"fmt"
	"ledger/server/pkg/client/ledger"
	"ledger/server/pkg/config"
	"ledger/server/pkg/router"
	"math/rand"
	"time"
)

func main() {
	rand.Seed(time.Now().UnixNano())
	server := router.PreRun()
	if err := server.Run(fmt.Sprintf("%s:%d", config.GetConfig().Common.ListenIP, config.GetConfig().Common.ListenPort)); err != nil {
		panic(err)
	}
	ledger.CloseConn()
}
