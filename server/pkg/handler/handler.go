package handler

import (
	"fmt"
	"io"
	"io/ioutil"
	"ledger/server/pkg/client/jwt"
	"ledger/server/pkg/client/ledger"
	"ledger/server/pkg/config"
	"ledger/server/pkg/model"
	"net/http"

	"github.com/gin-gonic/gin"
	ipfsapi "github.com/ipfs/go-ipfs-api"
)

type LedgerApi struct {
	*gin.Context
	IPFS *ipfsapi.Shell
}

func NewApi() *LedgerApi {
	return &LedgerApi{
		IPFS: ipfsapi.NewShell(config.GetConfig().IPFSConfig.URL),
	}
}

// uploadHandler 处理文件上传请求
func (api *LedgerApi) UploadHandler(c *gin.Context) {
	if c.Request.Method != http.MethodPost {
		c.String(http.StatusMethodNotAllowed, "只支持 POST 请求")
		return
	}

	// 解析表单数据
	err := c.Request.ParseMultipartForm(32 << 20) // 最大 32MB
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 获取上传的文件
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 打开文件
	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer src.Close()

	// 上传文件到 IPFS
	cid, err := api.IPFS.Add(src, ipfsapi.Pin(true))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 返回 CID
	c.JSON(http.StatusOK, gin.H{"cid": cid, "filename": file.Filename})
}

func (api *LedgerApi) DownloadHandler(c *gin.Context) {
	if c.Request.Method != http.MethodGet {
		c.JSON(http.StatusMethodNotAllowed, gin.H{"error": "只支持 GET 请求"})
		return
	}

	// 获取 CID 参数
	cid := c.Query("cid")
	if cid == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "缺少 CID 参数"})
		return
	}

	// 从 IPFS 获取文件内容
	reader, err := api.IPFS.Cat(cid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer reader.Close()

	// 设置响应头
	c.Writer.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", cid))
	c.Writer.Header().Set("Content-Type", "application/octet-stream")

	// 将文件内容写入响应
	_, err = io.Copy(c.Writer, reader)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
}

func (api *LedgerApi) Token(c *gin.Context) {
	var req model.TokenReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.String(http.StatusBadRequest, "ok")
		return
	}
	if req.Org == "" || req.Channel == "" {
		c.String(http.StatusBadRequest, "org or channel must is not empty")
		return
	}
	if _, ok := model.OrgMap[req.Org]; !ok {
		c.String(http.StatusBadRequest, fmt.Sprintf("org invalid,option[org1 | org2 | org3 | org4 | org5 | org6 | org7 | org8 | org9]"))
		return
	}
	if _, ok := model.ChannelMap[req.Channel]; !ok {
		c.String(http.StatusBadRequest, fmt.Sprintf("channel invalid,option[channela | channelb | channelc | channeld]"))
		return
	}
	token, err := jwt.GenerateToken(req)
	if err != nil {
		c.String(http.StatusBadRequest, "generate token failed")
		return
	}
	c.String(http.StatusOK, token)
}
func (api *LedgerApi) WriteLedger(c *gin.Context) {
	bodyBytes, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.String(http.StatusBadRequest, err.Error())
		return
	}
	user, _ := c.Get(model.Token)
	validateToken := user.(*model.TokenReq)
	fabric := ledger.GetFabric(validateToken)
	if fabric == nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("no fabric client, org: %s", validateToken.Org))
		return
	}
	txHash, err := fabric.TransferAsync(validateToken, bodyBytes)
	if err != nil {
		c.String(http.StatusBadRequest, err.Error())
		return
	}
	c.String(http.StatusOK, txHash)
}

func (api *LedgerApi) UpdateLedger(c *gin.Context) {
	bodyBytes, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.String(http.StatusBadRequest, err.Error())
		return
	}
	user, _ := c.Get(model.Token)
	validateToken := user.(*model.TokenReq)
	fabric := ledger.GetFabric(validateToken)
	if fabric == nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("no fabric client, org: %s", validateToken.Org))
		return
	}
	txHash, err := fabric.UpdateAsync(validateToken, bodyBytes)
	if err != nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("update ledger is err:%s", err.Error()))
		return
	}
	c.JSON(http.StatusOK, txHash)
}

func (api *LedgerApi) ReadLedger(c *gin.Context) {
	user, _ := c.Get(model.Token)
	validateToken := user.(*model.TokenReq)
	fabric := ledger.GetFabric(validateToken)
	if fabric == nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("no fabric client, org: %s", validateToken.Org))
		return
	}

	result, err := fabric.TraceabilityQuery(validateToken, c.Query("channel"), c.Query("action"), c.Query("id"), c.Query("localTime"))
	if err != nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("read ledger is err:%s", err.Error()))
		return
	}
	c.JSON(http.StatusOK, result)
}
func (api *LedgerApi) ReadHistoryLedger(c *gin.Context) {
	user, _ := c.Get(model.Token)
	validateToken := user.(*model.TokenReq)
	fabric := ledger.GetFabric(validateToken)
	if fabric == nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("no fabric client, org: %s", validateToken.Org))
		return
	}
	result, err := fabric.TraceabilityQueryHistory(validateToken, c.Query("id"), c.Query("localTime"))
	if err != nil {
		c.String(http.StatusBadRequest, fmt.Sprintf("read ledger is err:%s", err.Error()))
		return
	}
	c.JSON(http.StatusOK, result)
}
