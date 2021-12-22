// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CCCT is ERC20Burnable, Ownable {

//    uint amountToEmmit = 0.125 ether; //0.125 FTM
//    uint time = 86400; // time in sec = 24hr = 1 day
//    // 0.125 ether/86400 sec = 0.000001467592592592592/10**22=14467592592592592
//    // this is the calculation for emission rate
//     uint256 public EMISSIONS_RATE = 14467592592592592; 

// uint amountToEmmit = 5 ether; // 5 token =5 *10**18
//    uint time = 86400; // time in sec = 24hr = 1 day
//    // 5 ether/86400 sec = 5.787037e+12/10**22=
//    // this is the calculation for emission rate
//     uint256 public EMISSIONS_RATE = ; 
 
    uint256 public MAX_CCCTNFT_STAKED = 10;
    uint256 public EMISSIONS_RATE = 11574070000000;
    
    // uint256 public CLAIM_END_TIME = 1641013200;



    address nullAddress = 0x0000000000000000000000000000000000000000;

    address[] public CCCTAddress;
    address[] public NFTaddress;
    
    mapping(uint256 => uint256) internal tokenIdToTimeStaked;

    
    mapping(uint256 => address) internal tokenIdToStaker;


    mapping(address => uint256[]) internal stakerToTokenIds;

    constructor() ERC20("STEAK", "STK") {}

    function setCCCTAddress(address _CCCTAddress) public  {
        CCCTAddress.push( _CCCTAddress);
       //  IERC721(CCCTAddress[1]).setApprovalForAll(address(this), true);
        return;
    }

    function setAddress(address _NftAddrress) public returns(address){
        NFTaddress.push(_NftAddrress);
        // for (uint i = 0; i < NFTaddress.length; i++){
        //      IERC721(NFTaddress[i]).setApprovalForAll(address(this), true);
        // }
        
    }

    function getTokensStaked(address staker) public view returns (uint256[] memory)
    {
        return stakerToTokenIds[staker];
    }

    function remove(address staker, uint256 index) internal {
        if (index >= stakerToTokenIds[staker].length) return;
        for (uint256 i = index; i < stakerToTokenIds[staker].length - 1; i++) {
            stakerToTokenIds[staker][i] = stakerToTokenIds[staker][i + 1];
        }
        stakerToTokenIds[staker].pop();
    }

    function removeTokenIdFromStaker(address staker, uint256 tokenId) internal {
        for (uint256 i = 0; i < stakerToTokenIds[staker].length; i++) {
            if (stakerToTokenIds[staker][i] == tokenId) {
                remove(staker, i);
            }
        }
    }

    function stakeByIds(uint256[] memory tokenIds, uint AddressId) public {
        require( stakerToTokenIds[msg.sender].length + tokenIds.length <= MAX_CCCTNFT_STAKED,
            "Must have less than 11 ccct staked!");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require( IERC721(CCCTAddress[AddressId]).ownerOf(tokenIds[i]) == msg.sender,"Token must be stakable by you!");
            IERC721(CCCTAddress[AddressId]).transferFrom( msg.sender,address(this),tokenIds[i]);
            stakerToTokenIds[msg.sender].push(tokenIds[i]);
            tokenIdToTimeStaked[tokenIds[i]] = block.timestamp;
            tokenIdToStaker[tokenIds[i]] = msg.sender;
        }
    }

    function unstakeAll(uint AddressId ) public  {
        require( stakerToTokenIds[msg.sender].length > 0,"Must have at least one token staked!");
        uint256 totalRewards = 0;
        for (uint256 i = stakerToTokenIds[msg.sender].length; i > 0; i--) {
            uint256 tokenId = stakerToTokenIds[msg.sender][i - 1];
            IERC721(CCCTAddress[AddressId]).transferFrom(address(this),msg.sender,tokenId);
            totalRewards = totalRewards + ((block.timestamp - tokenIdToTimeStaked[tokenId]) * EMISSIONS_RATE);
            removeTokenIdFromStaker(msg.sender, tokenId);
            tokenIdToStaker[tokenId] = nullAddress;
        }

        _mint(msg.sender, totalRewards);
    }
    function unstakeByIds(uint256[] memory tokenIds,uint AddressId) public {
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIdToStaker[tokenIds[i]] == msg.sender,"Message Sender was not original staker!");
            IERC721(CCCTAddress[AddressId]).transferFrom(address(this),msg.sender,tokenIds[i]);
            totalRewards = totalRewards + ((block.timestamp - tokenIdToTimeStaked[tokenIds[i]]) * EMISSIONS_RATE);
            removeTokenIdFromStaker(msg.sender, tokenIds[i]);
            tokenIdToStaker[tokenIds[i]] = nullAddress;
        }
        _mint(msg.sender, totalRewards);
    }

    function claimByTokenId(uint256 tokenId) public onlyOwner {
        require( tokenIdToStaker[tokenId] == msg.sender, "Token is not claimable by you!");
        // require(block.timestamp < CLAIM_END_TIME, "Claim period is over!");
        _mint(msg.sender,((block.timestamp - tokenIdToTimeStaked[tokenId]) * EMISSIONS_RATE));
        tokenIdToTimeStaked[tokenId] = block.timestamp;
    }

    function claimAll() public    {
        // require(block.timestamp < CLAIM_END_TIME, "Claim period is over!");
        uint256[] memory tokenIds = stakerToTokenIds[msg.sender];
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIdToStaker[tokenIds[i]] == msg.sender,"Token is not claimable by you!");
            totalRewards =totalRewards + ((block.timestamp - tokenIdToTimeStaked[tokenIds[i]]) * EMISSIONS_RATE);
            tokenIdToTimeStaked[tokenIds[i]] = block.timestamp;
        }
        _mint(msg.sender, totalRewards);
    }

    function getAllRewards(address staker) public view returns (uint256) {
        uint256[] memory tokenIds = stakerToTokenIds[staker];
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) { 
        totalRewards = totalRewards + ((block.timestamp - tokenIdToTimeStaked[tokenIds[i]]) * EMISSIONS_RATE);
        }
        return totalRewards;
    }

    function getRewardsByTokenId(uint256 tokenId) public view returns (uint256) {
        require( tokenIdToStaker[tokenId] != nullAddress, "Token is not staked!");
        uint256 secondsStaked = block.timestamp - tokenIdToTimeStaked[tokenId];
        return secondsStaked * EMISSIONS_RATE;
    }

    function getStaker(uint256 tokenId) public view returns (address) {
        return tokenIdToStaker[tokenId];
    }
}