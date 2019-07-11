const MainMarket = artifacts.require('./MainMarket.sol');
const AuxiliaryMarket = artifacts.require('./AuxiliaryMarket.sol');
const ZapCoordinator = artifacts.require('./ZapCoordinator.sol');
const MainMarketToken = artifacts.require('./MainMarketToken.sol');
const AuxiliaryMarketToken = artifacts.require('./AuxiliaryMarketToken.sol');
const ZapToken = artifacts.require('./ZapToken.sol');

module.exports = async function(deployer) {
  const coordinator = await ZapCoordinator.deployed();
  const zapToken = await ZapToken.deployed();
  await deployer.deploy(MainMarketToken);
  await deployer.deploy(AuxiliaryMarketToken);
  const mmt = await MainMarketToken.deployed();
  const amt = await AuxiliaryMarketToken.deployed();
  await coordinator.addImmutableContract('MAINMARKET_TOKEN', mmt.address);
  await coordinator.addImmutableContract('AUXILIARYMARKET_TOKEN', amt.address);
  await deployer.deploy(MainMarket, ZapCoordinator.address);
  const mm = await MainMarket.deployed();
  await coordinator.addImmutableContract('MAINMARKET', mm.address);
  await deployer.deploy(AuxiliaryMarket, ZapCoordinator.address);
  const am = await AuxiliaryMarket.deployed();
  await coordinator.addImmutableContract('AUXMARKET', am.address);

  var accounts = web3.eth.getAccounts();
  var secondAccount = accounts[1];
  var thirdAccount = accounts[2];

  //Mint initial 100 million MMT Tokens for Main Market to disperse to users who bond
  var mintAmount = 100000000;

  //turn to 18 decimal precision
  let mmtWei = web3.utils.toWei(mintAmount.toString(), 'ether');
  let amtWei = web3.utils.toWei(mintAmount.toString(), 'ether');
  //mmtWei is used for more precise transactions.
  await mmt.mint(mm.address, mmtWei);
  await amt.mint(am.address, amtWei);

  let allocate = 2000000;
  let allocateInWeiMMT = web3.utils.toWei(allocate.toString(), 'ether');

  //Allocate 500 Zap to user for testing purposes locally
  await mm.allocateZap(allocateInWeiMMT);

  //100 zap
  let approved = 2000000;
  let approveWeiZap = web3.utils.toWei(approved.toString(), 'ether');

  //Approve MainMarket an allowance of 100 Zap to use on behalf of msg.sender(User)
  await zapToken.approve(mm.address, approveWeiZap);
  await zapToken.approve(am.address, approveWeiZap);

  //Setting up second account with zap and approving zap to withdraw
  // await mm.allocateZap(allocateInWeiMMT, {from: secondAccount});
  // await zapToken.approve(mm.address, approveWeiZap, {from: secondAccount});
  // await mm.depositZap(approveWeiZap, {from: secondAccount});
  // await mm.bond(10, {from: secondAccount});
  //
  //
  // //Setting up third account with zap and approving zap to withdraw
  // await mm.allocateZap(allocateInWeiMMT, {from: thirdAccount});
  // await zapToken.approve(mm.address, approveWeiZap, {from: thirdAccount});
  // await mm.depositZap(approveWeiZap, {from: thirdAccount});
  // await mm.bond(50, {from: thirdAccount});
};
