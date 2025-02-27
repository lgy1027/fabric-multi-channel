'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

// 一些预定义的随机值
const locations = ['NY', 'SF', 'LA', 'TX', 'CHI'];
const timestamps = ['2024-12-01T10:00:00Z', '2024-12-01T10:10:00Z', '2024-12-01T10:20:00Z'];
const maxSpeed = 120;
const maxFuelLevel = 100;
const maxBatteryLevel = 100;

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
        let facilityID = `Facility${this.workerIndex}_channeld${this.txIndex}`; // 设施唯一ID
        let location = locations[Math.floor(Math.random() * locations.length)]; // 随机位置
        let totalSpots = Math.floor(Math.random() * maxFuelLevel); // 随机总停车位
        let availableSpots = Math.min(Math.floor(Math.random() * maxBatteryLevel), totalSpots); // 随机可用停车位
        let pricePerHour = (Math.random() * maxSpeed).toFixed(2); // 随机每小时价格
        let ipfscid = timestamps[Math.floor(Math.random() * timestamps.length)];

        let args = {
            contractId: 'channeld_ledger', // 智能合约ID
            contractVersion: 'v1', // 智能合约版本
            contractFunction: 'CreateParkingFacility', // 调用的函数
            contractArguments: [facilityID, location, totalSpots.toString(), availableSpots.toString(), pricePerHour, ipfscid],
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
