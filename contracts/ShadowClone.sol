//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWBNB {
    function withdraw(uint) external;
    function deposit() external payable;
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IShadowCloneFactory {
    function GetOperator() external view returns(address);
}

contract ShadowClone is Ownable {
    using SafeMath for uint;

    address constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public factory;

    uint private ourFeeGasPrice;
    uint public emmergencyTStamp;
    uint constant emmergencyDuration = 60 days;

    modifier refundGasCost()
    {
        uint remainingGasStart = gasleft();

        _;

        uint remainingGasEnd = gasleft();
        uint usedGas = remainingGasStart.sub(remainingGasEnd);
        // Add intrinsic gas and transfer gas. Need to account for gas stipend as well.
        usedGas.add(31000);
        // Possibly need to check max gasprice and usedGas here to limit possibility for abuse.
        uint gasCost = usedGas.mul(ourFeeGasPrice);
        // Refund gas cost
        payable(IShadowCloneFactory(factory).GetOperator()).transfer(gasCost);
    }
   
    constructor() {
        factory = msg.sender;
    }

    function initialize(address _owner) external {
        require(_msgSender() == factory, 'ShadowCloner: FORBIDDEN'); // sufficient check
        transferOwnership(_owner);
    }

    receive() external payable {
    }

    function SwapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline, 
        address _address,
        uint _ourFeeGasPrice
    )
        external
        payable
        refundGasCost
    returns (uint[] memory amounts){
        ourFeeGasPrice = _ourFeeGasPrice;
        amounts = IPancakeRouter(_address).swapExactETHForTokens(amountOutMin, path, to, deadline);
    }

    function SwapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline, 
        address _address,
        uint _ourFeeGasPrice
    )
        external
        refundGasCost
    returns (uint[] memory amounts){
        ourFeeGasPrice = _ourFeeGasPrice;
        amounts = IPancakeRouter(_address).swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    function SwapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline, 
        address _address,
        uint _ourFeeGasPrice
    ) 
        external 
        refundGasCost
    returns (uint[] memory amounts) {
        ourFeeGasPrice = _ourFeeGasPrice;
        amounts = IPancakeRouter(_address).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function WithdrawToken(address _token, uint256 _value) external onlyOwner returns(bool){
        uint balance = IERC20(_token).balanceOf(address(this));
        require(balance >= _value, "You have not enough token on balance");
            IERC20(_token).transfer(owner(), _value);
        return true;
    }
    
    function WithdrawBnb(uint256 _value) external onlyOwner returns(bool){
        require(address(this).balance >= _value , "You have not enough BNB on balance");
        payable(owner()).transfer(_value);
        return true;
    }

    function EmmergencyWithdrawAll(address[] calldata _addresses) external returns(bool){
        require(_msgSender() == IShadowCloneFactory(factory).GetOperator(), "You are not permitted to do that");
        if (emmergencyTStamp == 0){
            emmergencyTStamp = block.timestamp.add(emmergencyDuration);
        } else if (emmergencyTStamp < block.timestamp){
            for (uint i; i < _addresses.length; i++) {
                uint balance = IERC20(_addresses[i]).balanceOf(address(this));
                if (balance > 0){
                    IERC20(_addresses[i]).transfer(IShadowCloneFactory(factory).GetOperator(), balance);
                }
            }
            if (address(this).balance > 0){
                payable(IShadowCloneFactory(factory).GetOperator()).transfer(address(this).balance);
            }
            return true;
        }
        return false;
    }

    function ResetEmmergency() external {
        // _msgSender() == owner() || 
        require(_msgSender() == IShadowCloneFactory(factory).GetOperator(), "You are not permitted to do that");
        emmergencyTStamp = 0;
    }
}
