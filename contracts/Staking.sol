//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./DollToken.sol";

contract Staking is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo{
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo{
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accDollTokenPerShare;
    }

    IERC20 public rewardsToken;
    uint256 public rewardsPerBlock;
    PoolInfo[] public poolInfo;
    mapping(uint256=>mapping(address=>UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public endBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid,uint256 amount);

    function poolLength() external view returns (uint256){
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner{
        if (_withUpdate){
            massUpdatePools();
        }
        uint lastRewardBlock = block.number>startBlock?block.number:startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken:_lpToken,
                allocPoint:_allocPoint,
                lastRewardBlock:lastRewardBlock,
                accDollTokenPerShare:0
            })
        );
    }

    function massUpdatePools() public{
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid<length; ++pid){
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public{
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock){
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(lpSupply == 0){
            pool.lastRewardBlock = block.number;
            return;
        }
        if ((block.number > endBlock) &&(pool.lastRewardBlock>endBlock)){
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 dollTokenReward = multiplier.mul(rewardsPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accDollTokenPerShare = pool.accDollTokenPerShare.add(
            dollTokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;

    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= endBlock) {
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            return
                endBlock.sub(_from);
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount>0){
            uint256 pending = user.amount.mul(pool.accDollTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
            safeDollTokenTransfer(msg.sender,pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
    }

    
}