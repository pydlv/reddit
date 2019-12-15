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
        Reply[] replies;
        Sub sub;
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
    
    uint totalPosts;
    mapping (uint => Post) posts;
    Post[] postList;
    
    uint totalReplies;
    mapping (uint => Reply) replies;
    
    uint subCount;
    mapping (string => Sub) subs;
    
    function createPost(string memory title, uint _postType, bytes memory content, string memory subName) public {
        PostType postType = PostType(_postType);
        Sub storage sub = subs[subName];
        
        Post memory post = Post(
            block.timestamp, // createdAt
            ++totalPosts, // postId
            title,
            msg.sender, // author
            postType,
            content,
            0, // upvotes
            0, // downvotes
            new Reply[](0), // replies
            sub
        );
        
        sub.postCount++;
        sub.posts.push(post);
        
        posts[post.postId] = post;
        postList.push(post);
    }
    
    function createReply(uint parentPostId, bytes memory content) public {
        Post storage post = posts[parentPostId];
        
        require (post.createdAt > 0); // Make sure the post actually exists
        
        Reply memory reply = Reply(
            block.timestamp, // createdAt
            ++totalReplies, // replyId
            parentPostId,
            msg.sender, // author,
            content,
            0, // upvotes
            0 // downvotes
        );
        
        post.replies.push(reply);
        
        replies[reply.replyId] = reply;
    }
}