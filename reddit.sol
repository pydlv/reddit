pragma solidity ^0.5.12;

contract Reddit {
    struct Post {
        uint createdAt;
        uint postId;
        string title;
        address author;
        bytes content;
        uint upvotes;
        uint downvotes;
        bytes32 subName;
        uint[] replyIds;
    }
    
    struct Reply {
        uint createdAt;
        uint replyId;
        uint parentPostId;
        address author;
        bytes content;
        uint upvotes;
        uint downvotes;
    }
    
    struct Sub {
        uint[] postIds;
    }
    
    uint public totalPosts;
    mapping (uint => Post) posts;
    
    uint public totalReplies;
    mapping (uint => Reply) public replies;
    
    uint public subCount;
    mapping (bytes32 => Sub) subs;
    
    function createPost(string memory title, bytes memory content, bytes32 subName) public {
        Sub storage sub = subs[subName];
        
        uint newPostId = totalPosts++;
        
        Post storage post = posts[newPostId];
        post.postId = newPostId;
        post.createdAt = block.timestamp;
        post.title = title;
        post.author = msg.sender;
        post.content = content;
        post.subName = subName;
        
        sub.postIds.push(newPostId);
        
        posts[post.postId] = post;
    }
    
    function createReply(uint parentPostId, bytes memory content) public {
        Post storage post = posts[parentPostId];
        
        require (post.createdAt > 0, "Post does not exist."); // Make sure the post actually exists
        
        Reply memory reply = Reply({
            createdAt: block.timestamp,
            replyId: totalReplies++,
            parentPostId: parentPostId,
            author: msg.sender,
            content: content,
            upvotes: 0,
            downvotes: 0
        });
        
        post.replyIds.push(reply.replyId);
        
        replies[reply.replyId] = reply;
    }
    
    function getPost(uint pid) public view returns (uint createdAt, uint postId, string memory title, address author, bytes memory content, uint upvotes, uint downvotes, bytes32 subName, uint[] memory replyIds) {
        Post storage post = posts[pid];
        
        return (
            post.createdAt,
            post.postId,
            post.title,
            post.author,
            post.content,
            post.upvotes,
            post.downvotes,
            post.subName,
            post.replyIds
        );
    }
    
    function getRecentPostIdsInSub(bytes32 subName, uint offset, uint limit) public view returns (uint[] memory postIds) {
        Sub storage sub = subs[subName];
        
        uint numPostsInSub = sub.postIds.length;
        
        uint k = offset <= numPostsInSub ? numPostsInSub - offset : 0;
        
        uint numToReturn = k < limit ? k : limit;
        
        if (numToReturn == 0) {
            return new uint[](0);
        }
        
        uint[] memory result = new uint[](numToReturn);
        
        uint start = numPostsInSub - offset - 1;
        uint end = numPostsInSub - offset - limit; // Inclusive
        end = end > 0 && end <= start ? end : 0; // Must check end is less than start otherwise end can underflow which causes problems.
        
        uint j = 0;
        for (uint i=start; i >= end; i--) {
            result[j] = sub.postIds[i];
            
            if (i == 0) {
                break; // Necessary otherwise it will underflow
            }
            
            j++;
        }
        
        return result;
    }
    
    function getRecentlyActiveSubs() public view returns (bytes32[] memory) {
        bytes32[] memory result = new bytes32[](50);
        
        if (totalPosts == 0) {
            return result;
        }
        
        uint start = totalPosts > 49 ? 49 : totalPosts - 1;
        uint end = 0;
        
        uint j = 0;
        for (uint i = start; i >= end; i--) {
            result[j] = posts[i].subName;
            
            if (i == 0) {
                break;
            }
            
            j++;
        }
        
        return result;
    }
    
    function upvotePost(uint postId) public {
        Post storage post = posts[postId];
        
        require(post.createdAt > 0, "Post does not exist.");
        
        post.upvotes++;
    }
    
    function downvotePost(uint postId) public {
        Post storage post = posts[postId];
        
        require(post.createdAt > 0, "Post does not exist.");
        
        post.downvotes++;
    }
    
    function upvoteReply(uint replyId) public {
        Reply storage reply = replies[replyId];
        
        require(reply.createdAt > 0, "Reply does not exist.");
        
        reply.upvotes++;
    }
    
    function downvoteReply(uint replyId) public {
        Reply storage reply = replies[replyId];
        
        require(reply.createdAt > 0, "Reply does not exist.");
        
        reply.downvotes++;
    }
}