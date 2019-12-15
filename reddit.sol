pragma solidity ^0.5.12;

contract Reddit {
    enum PostType {
        Text,
        Link,
        IPFS
    }
    
    struct Post {
        uint createdAt;
        uint postId;
        string title;
        address author;
        PostType postType;
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
        uint postCount;
        Post[] posts;
    }
    
    uint public totalPosts;
    mapping (uint => Post) posts;
    Post[] postList;
    
    uint public totalReplies;
    mapping (uint => Reply) public replies;
    
    uint public subCount;
    mapping (string => Sub) public subs;
    
    function createPost(string memory title, uint _postType, bytes memory content, string memory subName) public {
        PostType postType = PostType(_postType);
        Sub storage sub = subs[subName];
        
        uint newPostId = totalPosts++;
        
        Post storage post = posts[newPostId];
        post.createdAt = block.timestamp;
        post.title = title;
        post.author = msg.sender;
        post.postType = postType;
        post.content = content;
        post.subName = subName;
        
        sub.postCount++;
        sub.posts.push(post);
        
        posts[post.postId] = post;
        postList.push(post);
    }
    
    function createReply(uint parentPostId, bytes memory content) public {
        Post storage post = posts[parentPostId];
        
        require (post.createdAt > 0); // Make sure the post actually exists
        
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
    
    function getPost(uint postId) public view returns (uint createdAt, string memory title, address author, PostType postType, bytes memory content, uint upvotes, uint downvotes, string memory subName, uint[] memory replyIds) {
        Post storage post = posts[postId];
        
        return (
            post.createdAt,
            post.title,
            post.author,
            post.postType,
            post.content,
            post.upvotes,
            post.downvotes,
            post.subName,
            post.replyIds
        );
    }
    
    function getLastPostsBySub(string memory subName) public view {
        
    }
}