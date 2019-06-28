pragma solidity ^0.5.8;

import "../platform/registry/RegistryInterface.sol";
import "../platform/registry/Registry.sol";
import "../platform/bondage/BondageInterface.sol";
import "../platform/bondage/Bondage.sol";
import "../lib/ownership/ZapCoordinatorInterface.sol";
import "./MainMarketTokenInterface.sol";


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract MainMarket {
    using SafeMath for uint256;

    struct MainMarketHolder{
        uint256 tokensOwned;
    }

    RegistryInterface public registry;
    BondageInterface public bondage;
    ZapCoordinatorInterface public coordinator;
    MainMarketTokenInterface public mainMarketToken;

    bytes32 public endPoint = "Bond To Main Maket";
    int256[] curve1 = [1,1,1000];


    mapping (address => MainMarketHolder) holders;



    constructor(address _zapCoor) public {
        coordinator = ZapCoordinatorInterface(_zapCoor);
        address bondageAddr = coordinator.getContract("BONDAGE");
        address mainMarketAddress = coordinator.getContract("MAINMARKET");
        mainMarketToken = MainMarketTokenInterface(mainMarketAddress);
        bondage = BondageInterface(bondageAddr);

        address registryAddress = coordinator.getContract("REGISTRY");
        registry = RegistryInterface(registryAddress);

        // initialize in registry
        bytes32 title = "Main market";

        registry.initiateProvider(12345, title);
        registry.initiateProviderCurve(endPoint, curve1, address(0));

    }

    function buyAndBond(uint256 amount) payable external {
        uint zapSpent = bondage.delegateBond(msg.sender, address(this), endPoint, amount);
        mainMarketToken.transfer(msg.sender, amount);
    }

    function getMMTBalance(address _owner) external returns(uint256) {
        return mainMarketToken.balanceOf(_owner);
    }



    //Disperse 5% fees to all
    function payFee() public payable {}
    // Exchange Zap for MainMarket Token

    function getZapPrice() public view {}

    // User deposits Zap into Main Market
    function deposit() external payable {}
    // Withdraw
    function withdraw(address holder, uint256 amount) external returns(uint256) {
        uint256 fee = (amount.mul(5)).div(100);
        return fee;
    }

    // List all Auxiliary Markets
    function viewAuxiliaryMarkets() external view {}
    // checks if Auxiliary Market Exists
    function auxiliaryMarketExists() external view{}
    // Checks on a specific Auxiliary Market
    function getAuxiliaryMarket(address) external view{}

    // Destroys the contract when there is no more Zap
    function selfDestruct() private {}
}