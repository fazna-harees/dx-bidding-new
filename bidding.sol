// SPDX-License-Identifier:UNLICENSED
pragma solidity >=0.4.24;

contract Auction {
    address internal auction_owner; 
    uint256 public auction_start; 
    uint256 public auction_end; 
    uint256 public highestBid; 
    address public highestBidder;
    uint256 public totalBid=0; 
    enum auction_state {
    CANCELLED, STARTED
    }
    
    address[] bidders;
    mapping(address => uint) public bids; 
    auction_state public STATE;
    constructor(uint _biddingTime, address _owner)
    { 
        auction_owner = _owner; 
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime* 1 minutes; STATE = auction_state.STARTED;
    } 
    modifier an_ongoing_auction() { 
        require(block.timestamp <= auction_end);
    _;
    }

    modifier only_owner() { 
        require(msg.sender == auction_owner);
    _;
    }

    modifier only_highestBidder() { 
        require(msg.sender == highestBidder);
    _;
    }

    function get_owner() public view returns(address) { 
        return auction_owner;
    } 
    // function getBids() public view returns

    
    function bid() public payable an_ongoing_auction returns (bool){ 
        require(bids[msg.sender] + msg.value > highestBid, "can't bid, Make a higher Bid");
        highestBidder = msg.sender; 
        highestBid = msg.value; 
        bidders.push(msg.sender);
        bids[msg.sender] = bids[msg.sender] + msg.value; 
        totalBid +=msg.value;
        emit BidEvent(highestBidder, highestBid);
        return true;
    } 

    function cancel_auction() only_owner an_ongoing_auction public returns (bool) { 
        STATE = auction_state.CANCELLED;
        emit CanceledEvent("Auction Cancelled", block.timestamp); 
        return true;
    } 


    function withdraw() only_highestBidder public returns (bool){
        require(block.timestamp > auction_end , "can't withdraw, Auction is still open");
        // uint amount = bids[msg.sender];
        // bids[msg.sender] = 0; 
        payable(msg.sender).transfer(totalBid); 
        emit WithdrawalEvent(msg.sender, totalBid); 
        return true;
    } 
    event BidEvent(address indexed highestBidder, uint256 highestBid); 
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);

}