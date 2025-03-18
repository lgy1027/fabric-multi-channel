## 一、项目概述
本项目专注于构建一个 Hyperledger Fabric 区块链网络，整合了多通道机制、多组织协作、跨通道信息共享以及 IPFS 文件存储与哈希上链等先进功能。借助此项目，用户能够迅速搭建起一个高度灵活、安全且高效的区块链环境，以适应各种复杂的业务场景。

## 二、主要功能
### 2.1 区块链网络搭建
成功搭建 Hyperledger Fabric 区块链网络，为后续的通道创建、组织加入以及数据交互等操作提供基础支撑。

### 2.2 通道创建
创建了四个独立的通道，分别为 `channela`、`channelb`、`channelc` 和 `channeld`。每个通道可独立处理交易和存储数据，满足不同业务场景下的数据隔离需求。

### 2.3 组织加入通道
- **`channelb`、`channelc`、`channeld`**：九个组织（`org1` - `org9`）分别加入到这三个通道中，实现多组织在不同通道内的协作与数据交互。
- **`channela`**：`org1`、`org4` 和 `org7` 加入 `channela` 通道，该通道作为共享查询平台，允许这些组织查询其他通道的相关信息，增强了信息的流通性和透明度。

### 2.4 IPFS 文件存储与哈希上链
集成 IPFS（InterPlanetary File System）作为分布式文件存储系统。用户可将文件上传至 IPFS 网络，并将文件的哈希值记录到区块链上，既保障了文件的安全性和可追溯性，又避免了在区块链上直接存储大量文件导致的性能问题。

## 三、安装与部署

### 3.1 环境准备
- **操作系统**：推荐使用 Linux 系统（如 Ubuntu 18.04 及以上版本）。
- **软件依赖**：
    - Docker 和 Docker Compose
    - Go 语言环境（版本 1.18 及以上）

### 3.2 克隆项目
```bash
git clone https://github.com/your-repo/fabric-project.git
cd fabric-project
```

### 3.3 生成加密材料和配置文件
```bash
./create.sh generate
```

### 3.4 启动区块链网络
```bash
./create.sh up
```

### 3.5 创建通道、加入通道
```bash
docker exec -it fabric-cli bash
./create.sh create
```

### 3.6 查询通道详情
```bash
./create.sh query-channel
```

### 3.7 打包链码、安装链码
```bash
./create.sh package
./create.sh install
```

### 3.8 启动 IPFS 服务
```bash
./create.sh ipfs
```

### 3.9 启动记账服务
```bash
./create.sh ledger
```

## 四、接口文档
[记账服务.md](https://github.com/lgy1027/fabric-multi-channel/blob/main/%E8%AE%B0%E8%B4%A6%E6%9C%8D%E5%8A%A1.md)

## 五、贡献指南
如果您对本项目感兴趣，欢迎参与贡献。以下是一些贡献的方式：
- **提交问题**：若您发现项目中存在问题或有改进建议，请在 GitHub 上提交 Issue。
- **提交代码**：若您想为项目添加新功能或修复 bug，请提交 Pull Request。在提交前，请确保您的代码符合项目的编码规范，并添加必要的测试。
