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
        string subName;
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
        mapping (uint => uint) postIds;
        uint postIdsSize;
    }
    
    uint public totalPosts;
    mapping (uint => Post) posts;
    
    uint public totalReplies;
    mapping (uint => Reply) public replies;
    
    uint public subCount;
    mapping (string => Sub) public subs;
    
    function createPost(string memory title, bytes memory content, string memory subName) public {
        Sub storage sub = subs[subName];
        
        uint newPostId = totalPosts++;
        
        Post storage post = posts[newPostId];
        post.postId = newPostId;
        post.createdAt = block.timestamp;
        post.title = title;
        post.author = msg.sender;
        post.content = content;
        post.subName = subName;
        
        sub.postIds[sub.postIdsSize++] = newPostId;
        
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
    
    function getPost(uint pid) public view returns (uint createdAt, uint postId, string memory title, address author, bytes memory content, uint upvotes, uint downvotes, string memory subName, uint[] memory replyIds) {
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