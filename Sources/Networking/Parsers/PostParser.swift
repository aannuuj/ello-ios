////
///  PostParser.swift
//

import SwiftyJSON


class PostParser: IdParser {

    init() {
        super.init(table: .postsType)

        linkArray(.assetsType)
        linkArray(.categoryPostsType)

        linkObject(.usersType, "author")
        linkObject(.usersType, "repostAuthor")
        linkObject(.postsType, "repostedSource")
        linkObject(.artistInviteSubmissionsType)
    }

    override func flatten(json _json: JSON, identifier: Identifier, db: inout Database) {
        var json = _json
        let repostedSource = json["repostedSource"]
        if let repostIdentifier = self.identifier(json: repostedSource) {
            flatten(json: repostedSource, identifier: repostIdentifier, db: &db)
            json["links"] = [
                "reposted_source": [
                    "id": repostIdentifier.id, "type": MappingType.postsType.rawValue
                ]
            ]
        }

        super.flatten(json: json, identifier: identifier, db: &db)
    }

    override func parse(json: JSON) -> Post {
        let repostContent = RegionParser.graphQLRegions(json: json["repostContent"])
        let createdAt = json["createdAt"].dateValue

        let post = Post(
            id: json["id"].idValue,
            createdAt: createdAt,
            authorId: json["author"]["id"].idValue,
            token: json["token"].stringValue,
            isAdultContent: false,  // json["is_adult_content"].boolValue,
            contentWarning: "",  // json["content_warning"].stringValue,
            allowComments: true,  // json["allow_comments"].boolValue,
            isReposted: json["currentUserState"]["reposted"].bool ?? false,
            isLoved: json["currentUserState"]["loved"].bool ?? false,
            isWatching: json["currentUserState"]["watching"].bool ?? false,
            summary: RegionParser.graphQLRegions(json: json["summary"]),
            content: RegionParser.graphQLRegions(
                json: json["content"],
                isRepostContent: repostContent.count > 0
            ),
            body: RegionParser.graphQLRegions(
                json: json["body"],
                isRepostContent: repostContent.count > 0
            ),
            repostContent: repostContent
        )

        post.artistInviteId = json["artistInviteSubmission"]["artistInvite"]["id"].id
        post.viewsCount = json["postStats"]["viewsCount"].int
        post.commentsCount = json["postStats"]["commentsCount"].int
        post.repostsCount = json["postStats"]["repostsCount"].int
        post.lovesCount = json["postStats"]["lovesCount"].int

        post.mergeLinks(json["links"].dictionaryObject)

        return post
    }
}
