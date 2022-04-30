// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract FetchVotes is ChainlinkClient {
    using Chainlink for Chainlink.Request;
  
    uint256 public votes;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    
    /**
     * Network: Kovan
     * Oracle: 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8 (Chainlink Devrel   
     * Node)
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
     */
    constructor() {
        setPublicChainlinkToken();
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId = "d5270d1c311941d0b08bead21fea7747";
        fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestVotes() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "https://hub.snapshot.org/graphql?operationName=Votes&query=query%20Votes%20%7B%0A%20%20proposal%20(id%3A%20%220xdc18efd665d776ef388aafa8385f3a63e6c2220641d04ec109a3c3c7d19e915d%22)%20%7B%0A%20%20%20%20scores%0A%20%20%20%20quorum%0A%20%20%7D%0A%7D%0A");
        
    
        //   "data": {
        //     "proposal": {
        //       "scores": [
        //         3,
        //         1,
        //         0
        //       ],
        //       "quorum": 0
        //     }
        //   }
        // }
        // request.add("path", "data,proposal,scores,1"); // Chainlink nodes prior to 1.0.0 support this format
        request.add("path", "data,proposal,scores,1"); // Chainlink nodes 1.0.0 and later support this format
        
        
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _votes) public recordChainlinkFulfillment(_requestId)
    {
        votes = _votes/100;
    }

}