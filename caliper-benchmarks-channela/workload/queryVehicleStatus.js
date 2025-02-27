'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

/**
 * 查询车辆状态工作负载模块
 */
class QueryVehicleStatusWorkload extends WorkloadModuleBase {
    constructor() {
        super();
        this.txIndex = 0;
        this.limitIndex = 0;
    }

    /**
     * 初始化工作负载模块
     * @param {number} workerIndex 工作负载实例的索引
     * @param {number} totalWorkers 总工作负载数
     * @param {number} roundIndex 当前执行的回合索引
     * @param {Object} roundArguments 来自配置文件的回合参数
     * @param {BlockchainInterface} sutAdapter 区块链适配器
     * @param {Object} sutContext 自定义的上下文对象
     */
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
        this.limitIndex = this.roundArguments.assets;
    }

    /**
     * 提交查询交易
     * @return {Promise<TxStatus[]>}
     */
    async submitTransaction() {
        this.txIndex++;
        // 设置查询的车辆ID
        let id = `Client${this.workerIndex}_channelb${this.txIndex}`; // 车辆唯一ID // 车辆ID可以从配置文件获取或动态生成
        let args = {
            contractId: 'channela_ledger', // 智能合约ID
            contractVersion: 'v1',  // 智能合约版本
            contractFunction: 'UnifiedQuery',  // 调用的链码函数
            contractArguments: ["channelb",id,"VehicleStatus","test"],  // 查询的车辆ID
            timeout: 30,  // 超时时间
            readOnly: true,
            targetOrganizations: ['Org1MSP'],
            targetPeers: ['peer0.org1.example.com']
        };

        if (this.txIndex === this.limitIndex) {
            this.txIndex = 0;
        }

        // 发送请求到区块链网络
        await this.sutAdapter.sendRequests(args);
    }
}

/**
 * 创建查询车辆状态的工作负载模块实例
 */
function createWorkloadModule() {
    return new QueryVehicleStatusWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;