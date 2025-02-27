'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class CreateVehicleStatusWorkload extends WorkloadModuleBase {
    constructor() {
        super();
        this.txIndex = 0; // 用于生成唯一的车辆ID
    }

    /**
     * Assemble TXs for the round.
     * @return {Promise<TxStatus[]>}
     */
    async submitTransaction() {
        this.txIndex++;
        const contractID = 'channelc_ledger';
        const contractFunction = 'CreateInsurancePolicy';
        const policyID = `Client${this.workerIndex}_channelc${this.txIndex}`; // 车辆唯一ID
        const vehicleID = `vehicle${Math.floor(Math.random() * 1000000)}`;
        const owner = 'testOwner';
        const provider = 'testProvider';
        const coverageType = 'Comprehensive';
        const startDate = '2025-01-01';
        const endDate = '2026-01-01';
        const premiumAmount = "500.0";
        const status = 'Active';
        const ipfsCid = `ipfs${Math.floor(Math.random() * 1000000)}`;

        let args = {
            contractId: contractID, // 智能合约ID
            contractVersion: 'v1', // 智能合约版本
            contractFunction: contractFunction, // 调用的函数
            contractArguments: [policyID, vehicleID, owner, provider, coverageType, startDate, endDate, premiumAmount, status, ipfsCid],
            timeout: 30 // 超时时间
        };

        await this.sutAdapter.sendRequests(args);
    }
}

/**
 * 创建工作负载模块实例
 */
function createWorkloadModule() {
    return new CreateVehicleStatusWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;
