import assert from 'assert'

import { type DeployFunction } from 'hardhat-deploy/types'

const func: DeployFunction = async (hre) => {
  const { deployments, getNamedAccounts, network, ethers } = hre
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  assert(deployer, 'Missing named deployer account')

  console.log(`Network: ${network.name}`)
  console.log(`Deployer: ${deployer}`)

  // 获取 LayerZero EndpointV2 外部部署地址（由 toolbox-hardhat 注入）
  const endpointV2Deployment = await deployments.get('EndpointV2')
  const endpoint = endpointV2Deployment.address

  if (network.name === 'arbitrum-sepolia') {
    // Arbitrum Testnet: 仅部署 arbOApp
    const { address } = await deploy('arbOApp', {
      from: deployer,
      args: [endpoint, deployer],
      log: true,
      skipIfAlreadyDeployed: true,
    })

    console.log(`Deployed contract: arbOApp, network: ${network.name}, address: ${address}`)
    return
  }

  if (network.name === 'base-sepolia') {
    // Base Testnet: 部署 AckComposerOApp 与 baseOApp（存在互相依赖的构造参数）
    // 通过部署者当前 nonce 预测地址，确保彼此构造参数正确：
    // 第一个部署地址 = getContractAddress({ from, nonce })
    // 第二个部署地址 = getContractAddress({ from, nonce + 1 })
    const currentNonce = await ethers.provider.getTransactionCount(deployer)
    const composerPredicted = ethers.utils.getContractAddress({ from: deployer, nonce: currentNonce })
    const basePredicted = ethers.utils.getContractAddress({ from: deployer, nonce: currentNonce + 1 })

    // 先部署 AckComposerOApp，构造参数传入 baseOApp 的预测地址
    const composer = await deploy('AckComposerOApp', {
      from: deployer,
      args: [endpoint, deployer, basePredicted],
      log: true,
      skipIfAlreadyDeployed: true,
    })

    // 再部署 baseOApp，构造参数传入 AckComposerOApp 的预测地址
    const base = await deploy('baseOApp', {
      from: deployer,
      args: [endpoint, deployer, composerPredicted],
      log: true,
      skipIfAlreadyDeployed: true,
    })

    console.log(`Deployed contract: AckComposerOApp, network: ${network.name}, address: ${composer.address}`)
    console.log(`Deployed contract: baseOApp, network: ${network.name}, address: ${base.address}`)
    return
  }

  throw new Error(`Unsupported network for this deploy script: ${network.name}`)
}

func.tags = ['deploy-oapps']

export default func