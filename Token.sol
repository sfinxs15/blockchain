// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./MyNftContract.sol";
import "./MyToken.sol";

contract MyAuthorityContract is IERC721Receiver {
    address public immutable owner;
    MyToken private immutable _myToken;
    MyNftContract private immutable _myNftContract;
    uint256 public constant TIME_PER_DAY = 86400;
    uint256 public constant REWARD_PER_TOKEN = 10;

    mapping(uint256 => address) private _originalOwner;
    // track number of staked tokens and give proportional rewards
    mapping(address => uint256[]) private _ownerStakedTokenList;
    // track time of last claimed staking rewards
    mapping(address => uint256) private _lastClaimed;

    constructor(address myTokenAddress, address myNftContractAddress) {
        owner = msg.sender;
        _myToken = MyToken(myTokenAddress);
        _myNftContract = MyNftContract(myNftContractAddress);
    }

    function mintNft() external notOwner {
        _myToken.spendAllowance(msg.sender);
        _myNftContract.mint(msg.sender);
    }

    function stakeNft(uint256 tokenId) external notOwner {
        _originalOwner[tokenId] = msg.sender;
        _ownerStakedTokenList[msg.sender].push(tokenId);

        if (_lastClaimed[msg.sender] == 0) {
            _lastClaimed[msg.sender] = block.timestamp;
        }

        _myNftContract.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function unstakeNft(uint256 tokenId) external notOwner {
        address nftOwner = _originalOwner[tokenId];
        _myNftContract.safeTransferFrom(address(this), nftOwner, tokenId);
    }

    function claimStakingRewards() external notOwner {
        uint256 numberOfStakedNfts = _ownerStakedTokenList[msg.sender].length;
        require(numberOfStakedNfts > 0, "No NFTs have been staked!");

        uint256 timeLapsed = block.timestamp - _lastClaimed[msg.sender];
        // reward is given out for every 24 hrs instead of proportional
        uint256 daysOfUnclaimed = timeLapsed / uint256(TIME_PER_DAY);
        uint256 reward = daysOfUnclaimed *
            numberOfStakedNfts *
            REWARD_PER_TOKEN;
        // last claim is set to claimed number of days instead current timestamp
        // as leftover or unclaimed time is not factored in
        _lastClaimed[msg.sender] += daysOfUnclaimed * TIME_PER_DAY;

        _myToken.mint(msg.sender, reward);
    }

    // pre nft minting, token transfer approval
    function approveTokenTransfer() external notOwner {
        _myToken.approveTokenTransfer(msg.sender);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    modifier notOwner() {
        require(msg.sender != owner, "Owner cannot call this function!");
        _;
    }
}
