////
///  Love.swift
//

import SwiftyJSON


let LoveVersion: Int = 1

@objc(Love)
final class Love: Model, PostActionable {
    let id: String
    var isDeleted: Bool
    let postId: String
    let userId: String

    var post: Post? { return getLinkObject("post") }
    var user: User? { return getLinkObject("user") }

    init(id: String,
        isDeleted: Bool,
        postId: String,
        userId: String)
    {
        self.id = id
        self.isDeleted = isDeleted
        self.postId = postId
        self.userId = userId
        super.init(version: LoveVersion)

        addLinkObject("post", id: postId, type: .postsType)
        addLinkObject("user", id: userId, type: .usersType)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.isDeleted = decoder.decodeKey("deleted")
        self.postId = decoder.decodeKey("postId")
        self.userId = decoder.decodeKey("userId")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(isDeleted, forKey: "deleted")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(userId, forKey: "userId")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Love {
        let json = JSON(data)

        let love = Love(
            id: json["id"].idValue,
            isDeleted: json["deleted"].boolValue,
            postId: json["post_id"].stringValue,
            userId: json["user_id"].stringValue
        )

        love.mergeLinks(data["links"] as? [String: Any])
        love.addLinkObject("post", id: love.postId, type: .postsType)
        love.addLinkObject("user", id: love.userId, type: .usersType)

        return love
    }
}

extension Love: JSONSaveable {
    var uniqueId: String? { return "Love-\(id)" }
    var tableId: String? { return id }
}
