package router

import (
	"ledger/server/pkg/client/jwt"
	"ledger/server/pkg/handler"
	"ledger/server/pkg/model"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Server struct {
	*gin.Engine
}

func PreRun() *Server {
	server := NewServer()
	return server
}

func NewServer() *Server {
	s := &Server{}
	s.initRouter()
	return s
}

func (s *Server) initRouter() {
	r := gin.Default()
	r.Use(Cors())
	h := handler.NewApi()
	gr := r.Group("/v1").Use(checkToken())
	{
		gr.POST("/writer-ledger", h.WriteLedger)
		gr.GET("/read-ledger", h.ReadLedger)
		gr.PUT("/update-ledger", h.UpdateLedger)
		gr.GET("/read-ledger-history", h.ReadHistoryLedger)
		gr.POST("/upload-file", h.UploadHandler)
		gr.GET("/download-file", h.DownloadHandler)
	}

	r.POST("/token", h.Token)
	r.GET("/healthz", func(context *gin.Context) {
		context.String(http.StatusOK, "ok")
	})

	s.Engine = r
}

func checkToken() gin.HandlerFunc {
	return func(c *gin.Context) {
		jwtToken := c.Request.Header.Get("token")
		if jwtToken == "" {
			c.String(http.StatusForbidden, "Forbidden")
			c.Abort()
		}
		validateToken, err := jwt.CheckToken(jwtToken)
		if err != nil {
			c.String(http.StatusForbidden, err.Error())
		}
		c.Set(model.Token, validateToken)
		c.Next()
	}
}

func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		method := c.Request.Method
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Headers", "*")
		c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, UPDATE")
		c.Header("Access-Control-Expose-Headers", "*")
		c.Header("Access-Control-Allow-Credentials", "true")
		if method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
		}
		c.Next()
	}
}
